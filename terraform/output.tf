output "public_ip" {
  value = aws_instance.workflow.public_ip
}

output "vpc_id" {
  value = data.aws_vpc.main.id
}