provider "aws" {
  region = "us-east-1"
}
module "cluster" {
  source  = "weibeld/kubeadm/aws"
  version = "~> 0.2"
}
terraform {
  backend "s3" {
    bucket = "terraform-kube-state"
    key    = "prod/state/kube.state"
    region = "us-east-1"
  }
}
