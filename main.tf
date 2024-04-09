resource "aws_instance" "server" {
  ami           = "ami-033a1ebf088e56e81"
  instance_type = "t2.micro"
  key_name      = "freddy"
  tags = {
    Name = "Stella-server"
  }

}

resource "null_resource" "n1" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(local_file.ssh_key.filename)
    host        = aws_instance.server.public_ip
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.server.private_ip} >> serverIp.log"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo usergroup kornelius",
      "sudo useradd jonas",
      "sudo yum -y install httpd && sudo systemctl start httpd",
      "sudo yum systemctl enable httpd",
      "echo '<h1>My Test Website using Terraform Provisioner</h1>' > index.html",
      "sudo mv index.html /var/www/html/"
    ]
  }
  provisioner "file" {
    source      = "serverIp.log"
    destination = "/tmp/serverIp"
  }
  depends_on = [aws_instance.server, local_file.ssh_key]
}

