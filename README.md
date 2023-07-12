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
    - Create and manage ECR repositories, and KOPS clusters. You can read the documentation [here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create-permissions.html), [here](https://kops.sigs.k8s.io/getting_started/aws/) and [here](https://kops.sigs.k8s.io/operations/iam_permissions/).

7. **Setup AWS Route53 DNS zone**
    - Update the value of the `KOPS_DNS_ZONE` environment variable in the workflow below with your DNS zone. You can read the documentation [here](https://kops.sigs.k8s.io/getting_started/aws/).

8. **Read the full documentation of KOPS before using this workflow**
    - You can read the documentation [here](https://kops.sigs.k8s.io/).

## Destroy the cluster

In the event you need to destroy the cluster but you don't have access to it. You can use the following command to delete the cluster, or run the Destroy KOPS Cluster workflow.

```shell
kops delete cluster --name ${KOPS_CLUSTER_NAME} --yes

## To delete other resources:
```shell
aws ecr delete-repository --repository-name my-ecr-repo --region us-east-1 --force
aws s3api delete-bucket --bucket my-kops-bucket --region us-east-1 --force
aws route53 delete-hosted-zone --id Z1234567890 --force
aws iam delete-user --user-name my-iam-user --force
aws iam delete-access-key --access-key-id ABCDEFGHIJKLMNOPQRST --user-name my-iam-user --force

Authors
Zvi Moshkoviz
History
19/06/2023 - Initial release by Zvi Moshkoviz





## Compose sample application

### Use with Docker Development Environments

You can open this sample in the Dev Environments feature of Docker Desktop version 4.12 or later.

[Open in Docker Dev Environments <img src="../open_in_new.svg" alt="Open in Docker Dev Environments" align="top"/>](https://open.docker.com/dashboard/dev-envs?url=https://github.com/docker/awesome-compose/tree/master/react-java-mysql)

### React application with a Spring backend and a MySQL database

Project structure:
```
.
├── backend
│   ├── Dockerfile
│   ...
├── db
│   └── password.txt
├── compose.yaml
├── frontend
│   ├── ...
│   └── Dockerfile
└── README.md
```

[_compose.yaml_](compose.yaml)
```
services:
  backend:
    build: backend
    ...
  db:
    # We use a mariadb image which supports both amd64 & arm64 architecture
    image: mariadb:10.6.4-focal
    # If you really want to use MySQL, uncomment the following line
    #image: mysql:8.0.27
    ...
  frontend:
    build: frontend
    ports:
    - 3000:3000
    ...
```
The compose file defines an application with three services `frontend`, `backend` and `db`.
When deploying the application, docker compose maps port 3000 of the frontend service container to port 3000 of the host as specified in the file.
Make sure port 3000 on the host is not already being in use.

> ℹ️ **_INFO_**
> For compatibility purpose between `AMD64` and `ARM64` architecture, we use a MariaDB as database instead of MySQL.
> You still can use the MySQL image by uncommenting the following line in the Compose file
> `#image: mysql:8.0.27`

## Deploy with docker compose

```
$ docker compose up -d
Creating network "react-java-mysql-default" with the default driver
Building backend
Step 1/17 : FROM maven:3.6.3-jdk-11 AS builder
...
Successfully tagged react-java-mysql_frontend:latest
WARNING: Image for service frontend was built because it did not already exist. To rebuild this image you must use `docker-compose build` or `docker-compose up --build`.
Creating react-java-mysql-frontend-1 ... done
Creating react-java-mysql-db-1       ... done
Creating react-java-mysql-backend-1  ... done
```

## Expected result

Listing containers must show three containers running and the port mapping as below:
```
$ docker ps
ONTAINER ID        IMAGE                       COMMAND                  CREATED             STATUS              PORTS                  NAMES
a63dee74d79e        react-java-mysql-backend    "java -Djava.securit…"   39 seconds ago      Up 37 seconds                              react-java-mysql_backend-1
6a7364c0812e        react-java-mysql-frontend   "docker-entrypoint.s…"   39 seconds ago      Up 33 seconds       0.0.0.0:3000->3000/tcp react-java-mysql_frontend-1
b176b18fbec4        mysql:8.0.19                "docker-entrypoint.s…"   39 seconds ago      Up 37 seconds       3306/tcp, 33060/tcp    react-java-mysql_db-1
```

After the application starts, navigate to `http://localhost:3000` in your web browser to get a colorful message.
![page](./output.jpg)

Stop and remove the containers
```
$ docker compose down
Stopping react-java-mysql-backend-1  ... done
Stopping react-java-mysql-frontend-1 ... done
Stopping react-java-mysql-db-1       ... done
Removing react-java-mysql-backend-1  ... done
Removing react-java-mysql-frontend-1 ... done
Removing react-java-mysql-db-1       ... done
Removing network react-java-mysql-default
```

Grafana Metrics PromQL
## cpu metrics PromQL query

sum(rate(container_cpu_usage_seconds_total{namespace="default"}[5m])) by (pod_name)

## memory metrics PromQL query

sum(container_memory_usage_bytes{namespace="default"}) by (pod_name)

## network metrics PromQL query

sum(rate(container_network_receive_bytes_total{namespace="default"}[5m])) by (pod_name)

## node metrics PromQL query

100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
