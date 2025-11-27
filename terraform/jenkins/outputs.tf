output "jenkins_public_ip" {
  description = "EC2 Public IP"
  value       = aws_instance.jenkins.public_ip
}

output "ssh_connection_command" {
  description = "SSH into EC2"
  value       = "ssh -i jenkins.pem ec2-user@${aws_instance.jenkins.public_ip}"
}

output "jenkins_admin_password_command" {
  description = "SSH command to print the Jenkins initial admin password from the instance (run locally)"
  value       = "ssh -i jenkins.pem ec2-user@${aws_instance.jenkins.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
}

output "jenkins_url" {
  description = "URL for Jenkins web UI"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "jenkins_status_check" {
  description = "Check if Jenkins is accessible"
  value       = "curl -I http://${aws_instance.jenkins.public_ip}:8080"
}

output "jenkins_access_instructions" {
  description = "How to access Jenkins"
  value       = <<-EOT
    1. Open in browser: http://${aws_instance.jenkins.public_ip}:8080
    2. Get admin password via SSH: ssh -i jenkins.pem ec2-user@${aws_instance.jenkins.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'
    3. Alternative: Check AWS EC2 console system logs for the password
    EOT
}


