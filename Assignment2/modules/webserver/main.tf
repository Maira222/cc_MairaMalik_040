resource "aws_key_pair" "key" {
  key_name   = "${var.env_prefix}-${var.instance_suffix}"
  public_key = file(var.public_key)
}

resource "aws_instance" "server" {
  ami                    = "ami-0e2c8caa4b6378d8c"
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.key.key_name

  user_data = file(var.script_path)

  tags = merge(var.common_tags, {
    Name = "${var.env_prefix}-${var.instance_name}"
  })
}
