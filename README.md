# Deploy to AWS KOPS

> :warning: This workflow was created as a part of a DevOps Course and is not intended to be used in a production environment.

## Purpose

This workflow will:

- Build and push new container images to Amazon ECR
- Deploy a Kubernetes cluster using KOPS on AWS
- Deploy Kubernetes deployments and services
- Deploy MariaDB on the Kubernetes cluster
- Deploy Prometheus-stack on the Kubernetes cluster
- Deploy a React app on the Kubernetes cluster
- Export important deployment info and configuration to be uploaded as an artifact

The Docker images are based on the following repository: [React Java MySQL](https://github.com/lidorg-dev/react-java0mysql) by [@lidorg-dev](https://github.com/lidorg-dev).

## Setup

Before you can use this workflow, you need to complete the following steps:

1. **Create an ECR repository to store your images**
    - `aws ecr create-repository --repository-name my-ecr-repo --region us-east-1`
    - Do this for each image you want to create.
    - Replace the value of the `my-ecr-repo` in the build-image step.
    - Replace the value of the `AWS_REGION` environment variable in the workflow below with your repository's region.

2. **Create a KOPS S3 bucket to store your cluster state**
    - `aws s3api create-bucket --bucket my-kops-bucket --region us-east-1`
    - Replace the value of the `my-kops-bucket` in the workflow below.

3. **Store your environment variables in GitHub Actions secrets**
    - `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `KOPS_PUBLIC_KEY`, `KOPS_PRIVATE_KEY`.

4. **Store your KOPS variables in Github Actions Repository Variables**
    - `KOPS_CLUSTER_NAME`, `KOPS_PROVIDER`, `KOPS_BUCKET_STATE`, `KOPS_BUCKET_OIDC_STORE`, `KOPS_DNS_ZONE`, `KOPS_CLUSTER_ZONES`.

5. **Store your DB_PASSWORD in Github Actions Repository Secrets**
    - This is update the configMap.yaml file with the `DB_PASSWORD`.

6. **Configure AWS User with the correct IAM policies**
    - Create and manage ECR repositories, and KOPS clusters. You can read the documentation [here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create-permissions.html) and [here](https://kops.sigs.k8s.io/getting_started/aws/).

7. **Setup AWS Route53 DNS zone**
    - Update the value of the `KOPS_DNS_ZONE` environment variable in the workflow below with your DNS zone. You can read the documentation [here](https://kops.sigs.k8s.io/getting_started/aws/).

8. **Read the full documentation of KOPS before using this workflow**
    - You can read the documentation [here](https://kops.sigs.k8s.io/).

## Destroy the cluster

In the event you need to destroy the cluster but you don't have access to it. You can use the following command to delete the cluster, or run the Destroy KOPS Cluster workflow.

```shell
kops delete cluster --name ${KOPS_CLUSTER_NAME} --yes

## To delete other resources:

aws ecr delete-repository --repository-name my-ecr-repo --region us-east-1 --force
aws s3api delete-bucket --bucket my-kops-bucket --region us-east-1 --force
aws route53 delete-hosted-zone --id Z1234567890 --force
aws iam delete-user --user-name my-iam-user --force
aws iam delete-access-key --access-key-id ABCDEFGHIJKLMNOPQRST --user-name my-iam-user --force


## Authors
@zvimosh
# History
12/07/2023/ Initial release by @zvimosh