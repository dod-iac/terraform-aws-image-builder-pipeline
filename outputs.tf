output "arn" {
  value       = aws_imagebuilder_image_pipeline.main.arn
  description = "The ARN of the EC2 Image Builder pipeline."
}
