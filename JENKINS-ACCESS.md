# Jenkins Access Guide

## ✅ **Jenkins is Successfully Installed and Running!**

### **Jenkins Web Interface**
**URL**: http://98.91.28.50:8080

### **Getting the Initial Admin Password**

Since SSH access has key issues, here are alternative methods:

#### **Method 1: AWS Systems Manager (Recommended)**
```bash
# Install AWS CLI Session Manager plugin first
aws ssm start-session --target i-0c147f8337de0a3b1 --region us-east-1

# Once connected, run:
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

#### **Method 2: User Data Logs via AWS Console**
1. Go to EC2 Console → Instance i-0c147f8337de0a3b1
2. Actions → Monitor and troubleshoot → Get system log
3. Look for Jenkins installation output

#### **Method 3: Fix SSH Key and Connect**
```bash
# If you have the correct private key for the existing "jenkins" key pair:
ssh -i /path/to/correct/jenkins.pem ec2-user@98.91.28.50
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### **Jenkins Setup Steps**

1. **Access Jenkins**: Open http://98.91.28.50:8080
2. **Enter Admin Password**: Use password from one of the methods above
3. **Install Plugins**: Choose "Install suggested plugins"
4. **Create Admin User**: Set up your admin account
5. **Start Using Jenkins**: Begin creating pipelines!

### **Pre-installed Software**
- ✅ Java 21 (Amazon Corretto)
- ✅ Docker (jenkins user added to docker group)
- ✅ Maven
- ✅ Git
- ✅ Jenkins LTS

### **Troubleshooting**

**Jenkins not accessible?**
```bash
# Check if ports are open
nc -zv 98.91.28.50 8080

# Check security group allows port 8080
aws ec2 describe-security-groups --group-ids sg-05e9cd8d2584e8e8f --region us-east-1
```

**Need to restart Jenkins?**
```bash
# Via Systems Manager or correct SSH key:
sudo systemctl restart jenkins
sudo systemctl status jenkins
```

### **Instance Details**
- **Instance ID**: i-0c147f8337de0a3b1
- **Public IP**: 98.91.28.50
- **Security Group**: sg-05e9cd8d2584e8e8f
- **Instance Type**: t3.large (2 vCPU, 8GB RAM, 40GB storage)

## 🚀 **Next Steps**
1. Access Jenkins web interface
2. Complete initial setup wizard  
3. Install additional plugins as needed
4. Create your first pipeline
5. Integrate with GitHub repositories