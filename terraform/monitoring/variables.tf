variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "devops-flask-app"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "devops-flask-cluster"
}