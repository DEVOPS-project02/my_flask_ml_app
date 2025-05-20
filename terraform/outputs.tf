output "ec2_instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.artifact_bucket.bucket
}

output "kubernetes_namespace" {
  description = "Kubernetes namespace created"
  value       = kubernetes_namespace.ml_app_namespace.metadata[0].name
}

output "kubernetes_deployment_name" {
  description = "Kubernetes deployment name"
  value       = kubernetes_deployment.flask_ml_app.metadata[0].name
}

output "kubernetes_service_name" {
  description = "Kubernetes service name"
  value       = kubernetes_service.flask_ml_service.metadata[0].name
}
