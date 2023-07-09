provider "aws" {
  region = "us-east-1"
}
module "cluster" {
  source  = "weibeld/kubeadm/aws"
  version = "~> 0.2"
  private_key_file = var.private_key_file
  public_key_file = var.public_key_file
}
terraform {
  backend "s3" {
    bucket = "terraform-kube-foxyandpuff-com-state"
    key    = "prod/state/foxyandpuff.state"
    region = "us-east-1"
  }
}
