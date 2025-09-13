# eks-vpc-cluster

Two stacks with separate state:
- `vpc/` creates networking with terraform-aws-modules/vpc/aws
- `eks/` creates EKS with terraform-aws-modules/eks/aws and **reads VPC** via `terraform_remote_state`

## Prereqs
- AWS CLI configured (profile or env vars)
- kubectl
- Terraform >= 1.5

## 1) Deploy VPC
cd vpc
terraform init
terraform apply -auto-approve

## 2) Deploy EKS
cd ../eks
terraform init
terraform apply -auto-approve

## 3) Access the cluster
aws eks --region <REGION> --profile <PROFILE> update-kubeconfig --name <cluster_name>
kubectl get nodes

## Destroy (to avoid costs!)
cd eks && terraform destroy -auto-approve
cd ../vpc && terraform destroy -auto-approve
