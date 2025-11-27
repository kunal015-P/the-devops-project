# EKS Deployment Guide

This guide shows how to deploy your Flask application to Amazon EKS using eksctl.

## Prerequisites Installation

### macOS (using Homebrew)
```bash
# Install eksctl
brew install weaveworks/tap/eksctl

# Install kubectl
brew install kubectl

# Install AWS CLI (if not already installed)
brew install awscli

# Install Helm (for monitoring)
brew install helm
```

### Configure AWS CLI
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and default region (us-east-1)
```

## Deployment Options

### Option 1: Quick Cluster Creation
Creates just the EKS cluster using your exact specification:

```bash
chmod +x scripts/create-cluster.sh
./scripts/create-cluster.sh
```

This runs:
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

### Option 2: Complete Setup
Creates cluster + ECR + builds/deploys application + optional monitoring:

```bash
chmod +x scripts/setup-eks.sh
./scripts/setup-eks.sh
```

## Manual Deployment Steps

If you prefer to run commands manually:

### 1. Create EKS Cluster
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

### 2. Update kubeconfig
```bash
aws eks update-kubeconfig --region us-east-1 --name mycluster
```

### 3. Verify cluster
```bash
kubectl cluster-info
kubectl get nodes
```

### 4. Deploy Application (if using complete setup)
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
kubectl apply -f k8s/hpa.yaml
```

## Accessing Your Application

### Check service status
```bash
kubectl get services -n flask-app
```

### Get external IP/URL
```bash
kubectl get service flask-app-service -n flask-app -o wide
```

### Port forward for local testing
```bash
kubectl port-forward -n flask-app service/flask-app-service 8080:80
```
Then access: http://localhost:8080

## Monitoring (Optional)

The complete setup script can install Prometheus and Grafana:
- Grafana will be available at: http://localhost:3000 (after port-forward)
- Default login: admin/admin123

```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

## Cleanup

### Delete the cluster
```bash
eksctl delete cluster --name mycluster --region us-east-1
```

### Delete ECR repository (if created)
```bash
aws ecr delete-repository --repository-name devops-flask-app-flask-app --region us-east-1 --force
```

## Troubleshooting

### Check pod status
```bash
kubectl get pods -n flask-app
kubectl describe pod <pod-name> -n flask-app
```

### Check logs
```bash
kubectl logs -n flask-app deployment/flask-app
```

### Check cluster status
```bash
eksctl get cluster --region us-east-1
```

## Cost Optimization

The cluster uses:
- 2 x t3.medium instances (~$0.0416/hour each)
- EKS control plane (~$0.10/hour)
- Total: ~$0.18/hour or ~$130/month

Remember to delete the cluster when not in use to avoid charges!