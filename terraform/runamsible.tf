resource "null_resource" "ansible-playbook01" {
  #  count = var.instance_count 
  provisioner "remote-exec" {
    inline = ["echo 'connect to ssh'"]
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/terraform/academia-key.pem")
    host = aws_instance.web-01.public_ip
  }
}
  provisioner "local-exec"{
    command = "ansible-playbook -i ${aws_instance.web-01.public_ip}, --private-key ${"~/terraform/academia-key.pem"} ansible.yml"
  }
  depends_on = [
     aws_instance.web-01
   ]
}



resource "null_resource" "ansible-playbook02" {
  #  count = var.instance_count 
  provisioner "remote-exec" {
    inline = ["echo 'connect to ssh'"]
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/terraform/academia-key.pem")
    host = aws_instance.web-02.public_ip
  }
}
  provisioner "local-exec"{
    command = "ansible-playbook -i ${aws_instance.web-02.public_ip}, --private-key ${"~/terraform/academia-key.pem"} ansible.yml"
  }
  depends_on = [
     aws_instance.web-02
   ]
}



  #  count = var.instance_count 
  resource "null_resource" "ansible-playbook03" {
  provisioner "remote-exec" {
    inline = ["echo 'connect to ssh'"]
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/terraform/academia-key.pem")
    host = aws_instance.web-03.public_ip
  }
}
  provisioner "local-exec"{
    command = "ansible-playbook -i ${aws_instance.web-03.public_ip}, --private-key ${"~/terraform/academia-key.pem"} ansible.yml"
  }
  depends_on = [
     aws_instance.web-03
   ]
}

