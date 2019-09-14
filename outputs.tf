output "public_ip" {
  value = "${aws_instance.pipeline-example.public_ip}"
}
