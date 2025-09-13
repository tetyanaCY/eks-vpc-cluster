eks-vpc-cluster — README (TEXT)
Author: tetyana CY
Submission: hw35_tetyana_CY

Baseline AWS infrastructure for ML services using Terraform:
- VPC via terraform-aws-modules/vpc/aws
- EKS via terraform-aws-modules/eks/aws with two node groups (CPU + GPU)
- Launch from the project root (eks consumes vpc outputs)
- Windows PowerShell–friendly commands

NOTE: Cloud costs are real. Destroy resources after testing (see 6. Cost & Destroy).

---------------------------------------------------------------------
1) Prerequisites
---------------------------------------------------------------------
- AWS CLI v2 authenticated:
  aws sts get-caller-identity

- Terraform >= 1.5

- kubectl (optional for verification)
  winget install Kubernetes.kubectl
  or: scoop install kubectl

- IAM user/role with permissions for EKS/EC2/IAM/CloudWatch/CloudFormation/S3/DynamoDB

Defaults used in examples:
- Region: eu-central-1
- Cluster name: ml-eks

Tip: Save .tf files as UTF-8 (no BOM).

---------------------------------------------------------------------
2) Project structure
---------------------------------------------------------------------
eks-vpc-cluster/
  main.tf             (root orchestration: provider + module "vpc" + module "eks")
  variables.tf        (root inputs: region/profile/cluster/etc.)
  outputs.tf          (root outputs: e.g., EKS endpoint)
  terraform.tf        (provider constraints and optional local backend)
  backend.tf          (optional: S3 + DynamoDB backend config)
  terraform.tfvars    (your environment values)
  vpc/
    main.tf
    variables.tf
    outputs.tf
    terraform.tf      (module constraints only; no provider block)
    backend.tf        (unused when launching from root)
  eks/
    main.tf
    variables.tf
    outputs.tf
    terraform.tf      (module constraints only; no provider block)
    backend.tf        (unused when launching from root)

IMPORTANT: Run terraform from the project root. Do NOT run separately in vpc/ or eks/.
The root module wires the outputs from vpc into eks.

---------------------------------------------------------------------
3) Configure backend
---------------------------------------------------------------------
Option A — Local state (simple for homework)
Root terraform.tf already defaults to local state. Nothing to change.

Initialize (or reinitialize if you changed backends):
  cd $HOME\eks-vpc-cluster
  terraform init -reconfigure

Option B — Remote state (S3 + DynamoDB) (optional)
Add/edit root backend.tf like:
  terraform {
    backend "s3" {
      bucket         = "my-tf-state-<account>-euc1"
      key            = "envs/dev/root/terraform.tfstate"
      region         = "eu-central-1"
      dynamodb_table = "tf-state-locks"
      encrypt        = true
    }
  }

Then re-init:
  terraform init -reconfigure

---------------------------------------------------------------------
4) Configure variables (root terraform.tfvars)
---------------------------------------------------------------------
Fill terraform.tfvars (example values shown; adjust to your account):

  AWS
  aws_region  = "eu-central-1"
  aws_profile = "default"

  Naming
  cluster_name = "ml-eks"
  vpc_name     = "ml-vpc"

  VPC settings
  vpc_cidr = "10.0.0.0/16"
  az_count = 3

  Node groups
  cpu_instance_types = ["t3.medium"]
  cpu_desired_size   = 2
  cpu_min_size       = 1
  cpu_max_size       = 4

  Cheapest workable GPU for labs (set desired_size=0 to save cost)
  gpu_instance_types = ["g4dn.xlarge"]
  gpu_desired_size   = 0     # start at zero to avoid charges
  gpu_min_size       = 0
  gpu_max_size       = 2

  KMS for secrets encryption (optional; set to "" to disable)
  kms_key_arn = "arn:aws:kms:eu-central-1:<ACCOUNT_ID>:key/<KEY_ID>"

  Public endpoint access (limit to your IP)
  public_access_cidrs = ["0.0.0.0/0"]  # better: ["<YOUR.PUBLIC.IP>/32"]

  Tags
  tags = {
    Project = "ml-platform"
    Stack   = "infra"
  }

---------------------------------------------------------------------
5) Deploy from root
---------------------------------------------------------------------
  cd $HOME\eks-vpc-cluster

  Format & validate
  terraform fmt -recursive
  terraform validate

  Plan & apply
  terraform plan -out tf.plan
  terraform apply tf.plan

5.1) Configure kubectl

----------------------
  aws eks --region eu-central-1 update-kubeconfig --name ml-eks
  kubectl cluster-info
  kubectl get nodes -o wide

If you see “the server has asked for the client to provide credentials” (new EKS access model), grant your IAM principal:

  $REGION    = "eu-central-1"
  $CLUSTER   = "ml-eks"
  $PRINCIPAL = "arn:aws:iam::<ACCOUNT_ID>:user/console_access"   # or your role ARN

  aws eks create-access-entry     --cluster-name $CLUSTER --region $REGION --principal-arn $PRINCIPAL
  aws eks associate-access-policy --cluster-name $CLUSTER --region $REGION ^
    --principal-arn $PRINCIPAL ^
    --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy ^
    --access-scope type=cluster

  aws eks --region $REGION update-kubeconfig --name $CLUSTER
  kubectl get nodes -o wide

---------------------------------------------------------------------
6) Cost & Destroy
---------------------------------------------------------------------
- Keep gpu_desired_size = 0 when GPUs aren’t needed.
- NAT Gateways cost money. If you need cheaper labs, switch to single NAT or disable NAT (internet egress will change).
- CloudWatch Log Group: the EKS module creates /aws/eks/<cluster>/cluster by default; if it already exists, set:
    create_cloudwatch_log_group = false
  inside the EKS module call.

Destroy (root will handle dependencies):
  terraform destroy -auto-approve

If you separate stacks, destroy EKS first, then VPC.


"/mnt/data/README.txt"


