#!/bin/bash

# Manual Jenkins Installation Script
# Run this script on the EC2 instance to install Jenkins

set -e  # Exit on any error

echo "🚀 Starting Jenkins Installation..."

# Update system
echo "📦 Updating system packages..."
sudo yum update -y

# Install required packages
echo "📦 Installing dependencies (Git, Docker, Maven, Java)..."
sudo yum install -y git docker maven tree

# Start and enable Docker
echo "🐳 Starting Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Install Java 21
echo "☕ Installing Java 21..."
sudo dnf install -y java-21-amazon-corretto

# Verify Java installation
java --version

# Add Jenkins repository
echo "📋 Adding Jenkins repository..."
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

# Install Jenkins
echo "🏗️ Installing Jenkins..."
sudo yum upgrade -y
sudo yum install -y fontconfig java-21-openjdk
sudo yum install -y jenkins

# Add jenkins user to docker group
sudo usermod -aG docker jenkins

# Reload systemd and start Jenkins
echo "🎯 Starting Jenkins service..."
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Wait a moment for Jenkins to start
echo "⏳ Waiting for Jenkins to start..."
sleep 30

# Check Jenkins status
echo "✅ Checking Jenkins status..."
sudo systemctl status jenkins --no-pager

# Display Jenkins information
echo ""
echo "🎉 Jenkins Installation Complete!"
echo "================================"
echo "Jenkins URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo ""
echo "📋 Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Password file not ready yet, wait a moment and try: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo ""
echo "🔧 Useful Commands:"
echo "- Check status: sudo systemctl status jenkins"
echo "- View logs: sudo journalctl -u jenkins -f"
echo "- Restart: sudo systemctl restart jenkins"