#!/bin/bash

# EKS Cluster Setup Script using eksctl
# This script creates an EKS cluster and deploys the Flask application

set -e  # Exit on any error

# Configuration
CLUSTER_NAME="devops-flask-cluster"
REGION="us-east-1"
NODEGROUP_NAME="flask-nodes"
NODE_TYPE="t3.medium"
MIN_NODES=2
MAX_NODES=4
DESIRED_NODES=2
ECR_REPOSITORY="devops-flask-app-flask-app"
IMAGE_TAG="latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if eksctl is installed
    if ! command_exists eksctl; then
        print_error "eksctl is not installed. Please install eksctl first."
        echo "Installation instructions: https://eksctl.io/installation/"
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command_exists kubectl; then
        print_error "kubectl is not installed. Please install kubectl first."
        echo "Installation instructions: https://kubernetes.io/docs/tasks/tools/install-kubectl/"
        exit 1
    fi
    
    # Check if AWS CLI is installed and configured
    if ! command_exists aws; then
        print_error "AWS CLI is not installed. Please install and configure AWS CLI first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        print_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    print_success "All prerequisites satisfied!"
}

# Function to create EKS cluster
create_eks_cluster() {
    print_status "Creating EKS cluster: $CLUSTER_NAME"
    
    # Check if cluster already exists
    if eksctl get cluster --name "$CLUSTER_NAME" --region "$REGION" >/dev/null 2>&1; then
        print_warning "Cluster $CLUSTER_NAME already exists in region $REGION"
        read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Deleting existing cluster..."
            eksctl delete cluster --name "$CLUSTER_NAME" --region "$REGION" --wait
        else
            print_status "Using existing cluster..."
            return 0
        fi
    fi
    
    print_status "Creating new EKS cluster (this may take 15-20 minutes)..."
    eksctl create cluster \
        --name "$CLUSTER_NAME" \
        --region "$REGION" \
        --nodegroup-name "$NODEGROUP_NAME" \
        --node-type "$NODE_TYPE" \
        --nodes "$DESIRED_NODES" \
        --nodes-min "$MIN_NODES" \
        --nodes-max "$MAX_NODES" \
        --managed \
        --with-oidc \
        --ssh-access \
        --ssh-public-key ~/.ssh/id_rsa.pub \
        --tags Environment=production,Project=devops-flask-app,ManagedBy=eksctl
    
    if [ $? -eq 0 ]; then
        print_success "EKS cluster created successfully!"
    else
        print_error "Failed to create EKS cluster"
        exit 1
    fi
}

# Function to update kubeconfig
update_kubeconfig() {
    print_status "Updating kubeconfig..."
    aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"
    
    # Verify cluster connection
    if kubectl cluster-info >/dev/null 2>&1; then
        print_success "Successfully connected to cluster!"
        kubectl get nodes
    else
        print_error "Failed to connect to cluster"
        exit 1
    fi
}

# Function to create ECR repository
create_ecr_repository() {
    print_status "Creating ECR repository if it doesn't exist..."
    
    # Check if repository exists
    if aws ecr describe-repositories --repository-names "$ECR_REPOSITORY" --region "$REGION" >/dev/null 2>&1; then
        print_warning "ECR repository $ECR_REPOSITORY already exists"
    else
        aws ecr create-repository \
            --repository-name "$ECR_REPOSITORY" \
            --region "$REGION" \
            --image-scanning-configuration scanOnPush=true \
            --encryption-configuration encryptionType=AES256
        
        # Set lifecycle policy
        aws ecr put-lifecycle-policy \
            --repository-name "$ECR_REPOSITORY" \
            --region "$REGION" \
            --lifecycle-policy-text '{
                "rules": [
                    {
                        "rulePriority": 1,
                        "description": "Keep last 10 images",
                        "selection": {
                            "tagStatus": "any",
                            "countType": "imageCountMoreThan",
                            "countNumber": 10
                        },
                        "action": {
                            "type": "expire"
                        }
                    }
                ]
            }'
        
        print_success "ECR repository created!"
    fi
}

# Function to build and push Docker image
build_and_push_image() {
    print_status "Building and pushing Docker image..."
    
    # Get ECR login token
    aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.$REGION.amazonaws.com"
    
    # Build image
    print_status "Building Docker image..."
    docker build -t "$ECR_REPOSITORY:$IMAGE_TAG" .
    
    # Tag image for ECR
    ECR_URI="$(aws sts get-caller-identity --query Account --output text).dkr.ecr.$REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG"
    docker tag "$ECR_REPOSITORY:$IMAGE_TAG" "$ECR_URI"
    
    # Push image
    print_status "Pushing image to ECR..."
    docker push "$ECR_URI"
    
    print_success "Image pushed successfully!"
    echo "ECR Image URI: $ECR_URI"
}

# Function to deploy application to Kubernetes
deploy_application() {
    print_status "Deploying Flask application to Kubernetes..."
    
    # Get account ID and construct ECR URI
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG"
    
    # Update deployment YAML with ECR image URI
    sed "s|IMAGE_URI_PLACEHOLDER|$ECR_URI|g" k8s/deployment.yaml > k8s/deployment-temp.yaml
    
    # Apply Kubernetes manifests
    print_status "Applying Kubernetes manifests..."
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/deployment-temp.yaml
    kubectl apply -f k8s/service.yaml
    kubectl apply -f k8s/ingress.yaml
    kubectl apply -f k8s/hpa.yaml
    kubectl apply -f k8s/configmap.yaml
    
    # Clean up temporary file
    rm k8s/deployment-temp.yaml
    
    # Wait for deployment to be ready
    print_status "Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/flask-app -n flask-app
    
    print_success "Application deployed successfully!"
    
    # Get service information
    print_status "Service information:"
    kubectl get services -n flask-app
    kubectl get ingress -n flask-app
}

# Function to setup monitoring (optional)
setup_monitoring() {
    read -p "Do you want to setup monitoring (Prometheus/Grafana)? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Setting up monitoring stack..."
        
        # Add Prometheus Helm repository
        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        helm repo update
        
        # Install Prometheus and Grafana
        kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
        
        helm install prometheus prometheus-community/kube-prometheus-stack \
            --namespace monitoring \
            --set grafana.adminPassword=admin123 \
            --wait
        
        print_success "Monitoring stack installed!"
        print_status "Grafana admin password: admin123"
        
        # Port forward instructions
        echo "To access Grafana locally, run:"
        echo "kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
    fi
}

# Function to display cluster information
display_cluster_info() {
    print_success "EKS Cluster Setup Complete!"
    echo "======================================"
    echo "Cluster Name: $CLUSTER_NAME"
    echo "Region: $REGION"
    echo "Node Group: $NODEGROUP_NAME"
    echo "Nodes: $DESIRED_NODES (min: $MIN_NODES, max: $MAX_NODES)"
    echo "======================================"
    
    print_status "Useful commands:"
    echo "View cluster info: kubectl cluster-info"
    echo "View nodes: kubectl get nodes"
    echo "View pods: kubectl get pods -n flask-app"
    echo "View services: kubectl get services -n flask-app"
    echo "Delete cluster: eksctl delete cluster --name $CLUSTER_NAME --region $REGION"
    echo "======================================"
}

# Main execution
main() {
    print_status "Starting EKS cluster setup..."
    
    check_prerequisites
    create_ecr_repository
    build_and_push_image
    create_eks_cluster
    update_kubeconfig
    deploy_application
    setup_monitoring
    display_cluster_info
    
    print_success "All done! Your Flask application is now running on EKS!"
}

# Handle script arguments
case "${1:-}" in
    "create-cluster")
        check_prerequisites
        create_eks_cluster
        update_kubeconfig
        ;;
    "build-push")
        check_prerequisites
        create_ecr_repository
        build_and_push_image
        ;;
    "deploy")
        check_prerequisites
        deploy_application
        ;;
    "delete")
        print_warning "This will delete the entire EKS cluster: $CLUSTER_NAME"
        read -p "Are you sure? Type 'yes' to confirm: " -r
        if [[ $REPLY == "yes" ]]; then
            eksctl delete cluster --name "$CLUSTER_NAME" --region "$REGION" --wait
            print_success "Cluster deleted successfully!"
        else
            print_status "Operation cancelled."
        fi
        ;;
    "status")
        kubectl cluster-info
        kubectl get nodes
        kubectl get pods -n flask-app
        kubectl get services -n flask-app
        ;;
    *)
        main
        ;;
esac