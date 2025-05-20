variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "ec2_ami" {
  description = "AMI ID for EC2 instance (Ubuntu 22.04 LTS)"
  type        = string
  default     = "ami-0bdf93799014acdc4"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.large"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for artifacts (must be globally unique)"
  type        = string
  default     = "ml-app-static-uploads"
}

variable "kubeconfig_path" {
  description = "Path to Kubernetes kubeconfig"
  type        = string
  default     = "~/.kube/config"
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for the app"
  type        = string
  default     = "flask-ml-namespace"
}

variable "docker_image" {
  description = "Docker image with tag to deploy on Kubernetes"
  type        = string
  default     = "balesunilkumar/my-flask-ml-app:latest"
}
