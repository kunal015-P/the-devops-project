# DevOps Project - Flask App with Complete CI/CD Pipeline

This project demonstrates a complete DevOps pipeline with:
- Python Flask web application with UI
- Docker containerization
- AWS ECR for container registry
- Amazon EKS deployment using eksctl
- Jenkins CI/CD pipeline using Terraform
- Monitoring with Grafana & Prometheus
- Kubernetes YAML templates

## Project Structure

```
the-devops-project/
├── app/                    # Flask application
├── k8s/                    # Kubernetes YAML templates
├── scripts/                # Deployment scripts
│   ├── setup-eks.sh       # Complete EKS setup with app deployment
│   └── create-cluster.sh   # Simple cluster creation
├── terraform/              # Infrastructure as Code
│   ├── jenkins/           # Jenkins setup
│   └── monitoring/        # Grafana & Prometheus
├── jenkins/               # Jenkins pipeline configurations
└── monitoring/            # Monitoring configurations
```

## Quick Start

### Option 1: Simple Cluster Creation
```bash
# Create EKS cluster using your exact specification
./scripts/create-cluster.sh
```

### Option 2: Complete Setup with Application Deployment
```bash
# Complete setup: cluster + ECR + application deployment + monitoring
./scripts/setup-eks.sh
```

## Prerequisites

- AWS CLI configured with appropriate permissions
- eksctl installed (`brew install weaveworks/tap/eksctl`)
- kubectl installed (`brew install kubectl`)
- Docker installed and running
- Helm installed (for monitoring setup)

## EKS Cluster Configuration

The cluster is created with the following specifications:
- **Name**: mycluster (simple) or devops-flask-cluster (complete)
- **Region**: us-east-1
- **Node Type**: t3.medium
- **Nodes**: 2 (managed node group)
- **Auto Scaling**: Min 2, Max 2 (simple) or Min 2, Max 4 (complete)

## Deployment Options

### Simple Deployment
Just creates the EKS cluster using eksctl:
```bash
eksctl create cluster \
--name mycluster \
--region us-east-1 \
--nodegroup-name mynodes \
--node-type t3.medium \
--nodes 2 \
--nodes-min 2 \
--nodes-max 2 \
--managed
```

### Complete Deployment
Includes cluster creation, ECR setup, Docker build/push, and application deployment.

## Managing Your Cluster

### View cluster status
```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods -n flask-app
```

### Delete cluster
```bash
eksctl delete cluster --name mycluster --region us-east-1
```

## Application Access

Once deployed, the Flask application will be accessible through:
- LoadBalancer service (external IP will be provided)
- Ingress controller (if configured)

Check service status:
```bash
kubectl get services -n flask-app
```