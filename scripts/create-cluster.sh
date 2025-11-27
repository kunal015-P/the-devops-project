#!/bin/bash

# Simple EKS Cluster Creation - Exact command as requested
# Creates cluster only - no app deployment

echo "🚀 Creating EKS cluster with your exact specification..."
echo "This will create:"
echo "  - Cluster: mycluster"
echo "  - Region: us-east-1" 
echo "  - Nodes: 2 x t3.medium (managed)"
echo ""

# Check prerequisites
if ! command -v eksctl &> /dev/null; then
    echo "❌ eksctl not found. Install with: brew install weaveworks/tap/eksctl"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Install with: brew install kubectl"
    exit 1
fi

# Your exact eksctl command
eksctl create cluster \
--name mycluster \
--region us-east-1 \
--nodegroup-name mynodes \
--node-type t3.medium \
--nodes 2 \
--nodes-min 2 \
--nodes-max 2 \
--managed

# Check if cluster creation was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ EKS cluster 'mycluster' created successfully!"
    
    # Update kubeconfig
    echo "📋 Updating kubeconfig..."
    aws eks update-kubeconfig --region us-east-1 --name mycluster
    
    # Show cluster info
    echo ""
    echo "🔍 Cluster Information:"
    kubectl cluster-info
    kubectl get nodes
    
    echo ""
    echo "✅ Setup complete! Your cluster is ready."
    echo ""
    echo "💡 Next steps:"
    echo "   - Deploy apps: kubectl apply -f k8s/"
    echo "   - View nodes: kubectl get nodes"
    echo "   - Delete cluster: eksctl delete cluster --name mycluster --region us-east-1"
    echo ""
    echo "💰 Cost: ~$0.18/hour (~$130/month)"
    echo "🚨 Don't forget to delete when done: eksctl delete cluster --name mycluster --region us-east-1"
else
    echo "❌ Failed to create EKS cluster"
    exit 1
fi