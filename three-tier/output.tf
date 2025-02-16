output "ip" {
  value = aws_instance.web.id
}
output "state" {
  value = aws_instance.web.instance_state
}
output "instance_id" {
  value = aws_instance.web.id
}
