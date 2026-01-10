output "webserver_public_ip" {
  value = module.myapp-webserver.aws_instance.public_ip
}
