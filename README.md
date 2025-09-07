eks-vpc-cluster — README (TEXT)
Author: tetyana CY
Submission: hw35_tetyana_CY

Baseline AWS infrastructure for ML services using Terraform:
- VPC via terraform-aws-modules/vpc/aws
- EKS via terraform-aws-modules/eks/aws with two node groups (CPU + GPU)
- Remote state in S3 + locking in DynamoDB
- Windows PowerShell–friendly commands

NOTE: Cloud costs are real. Destroy resources after testing (see 6. Cost & Destroy).

------------------------------------------------------------
1) Prerequisites
------------------------------------------------------------
- AWS CLI v2 logged in:
  aws sts get-caller-identity
- Terraform >= 1.13
- kubectl (optional): scoop install kubectl
- IAM user with permissions for EKS/EC2/IAM/CloudFormation/S3/DynamoDB

Defaults used here:
- Region: eu-central-1
- State bucket: my-tf-state-762416913134-euc1
- Lock table: tf-state-locks

Tip: Save .tf files as UTF-8 without BOM.

------------------------------------------------------------
2) Project structure
------------------------------------------------------------
eks-vpc-cluster/
  backend.tf
  terraform.tf
  variables.tf
  main.tf
  outputs.tf
  vpc/
    backend.tf, terraform.tf, variables.tf, main.tf, outputs.tf
  eks/
    backend.tf, terraform.tf, variables.tf, main.tf, outputs.tf

------------------------------------------------------------
3) Backend (S3 + DynamoDB)
------------------------------------------------------------
Created once and reused across environments:
- S3: my-tf-state-762416913134-euc1 (versioning + encryption)
- DynamoDB: tf-state-locks (PAY_PER_REQUEST)

------------------------------------------------------------
4) Deploy VPC (folder: vpc/)
------------------------------------------------------------
cd .\vpc
$StateKey = "envs/dev/vpc/terraform.tfstate"

terraform init -reconfigure ^
  -backend-config="bucket=my-tf-state-762416913134-euc1" ^
  -backend-config="key=$StateKey" ^
  -backend-config="region=eu-central-1" ^
  -backend-config="dynamodb_table=tf-state-locks"

# Optional cost controls in vpc/main.tf:
# single_nat_gateway = true      # one NAT for all AZs (cheaper)
# enable_nat_gateway = false     # disable NAT for labs

terraform validate
terraform plan -out vpc.plan
terraform apply vpc.plan

Remember outputs: vpc_id, private_subnets[], public_subnets[].

------------------------------------------------------------
5) Deploy EKS (folder: eks/)
------------------------------------------------------------
cd ..\eks
$EksStateKey = "envs/dev/eks/terraform.tfstate"
$VpcStateKey = "envs/dev/vpc/terraform.tfstate"

terraform init -reconfigure ^
  -backend-config="bucket=my-tf-state-762416913134-euc1" ^
  -backend-config="key=$EksStateKey" ^
  -backend-config="region=eu-central-1" ^
  -backend-config="dynamodb_table=tf-state-locks"

# First apply with GPU scaled to 0 to save cost
terraform validate
terraform plan -out eks.plan ^
  -var "vpc_state_bucket=my-tf-state-762416913134-euc1" ^
  -var "vpc_state_region=eu-central-1" ^
  -var "vpc_state_key=$VpcStateKey" ^
  -var "gpu_desired_size=0"
terraform apply eks.plan

5.1) Connect kubectl
--------------------
aws eks --region eu-central-1 update-kubeconfig --name ml-eks
kubectl cluster-info
kubectl get nodes -o wide

If you see “the server has asked for the client to provide credentials”, grant access:
$REGION    = "eu-central-1"
$CLUSTER   = "ml-eks"
$PRINCIPAL = "arn:aws:iam::762416913134:user/console_access"

aws eks create-access-entry     --cluster-name $CLUSTER --region $REGION --principal-arn $PRINCIPAL
aws eks associate-access-policy --cluster-name $CLUSTER --region $REGION ^
  --principal-arn $PRINCIPAL ^
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy ^
  --access-scope type=cluster

aws eks --region $REGION update-kubeconfig --name $CLUSTER
kubectl get nodes -o wide

5.2) Node labels & taints
-------------------------
CPU node group: labels workload=cpu
GPU node group: labels workload=gpu, accelerator=nvidia; taint nvidia.com/gpu=present:NoSchedule

Quick checks:
kubectl get nodes --show-labels
kubectl get nodes -l workload=cpu -o wide
kubectl get nodes -l workload=gpu -o wide

------------------------------------------------------------
6) Cost & Destroy
------------------------------------------------------------
- Keep gpu_desired_size=0 when GPUs are not needed.
- NAT Gateways cost money; use single_nat_gateway=true or disable in labs.

Destroy order:
# Destroy EKS first
cd .\eks
$VpcStateKey = "envs/dev/vpc/terraform.tfstate"
terraform destroy -auto-approve ^
  -var "vpc_state_bucket=my-tf-state-762416913134-euc1" ^
  -var "vpc_state_region=eu-central-1" ^
  -var "vpc_state_key=$VpcStateKey"

# Then destroy VPC
cd ..\vpc
terraform destroy -auto-approve

------------------------------------------------------------
