###############################################
# ✅ ELASTIC IP PARA BASTION
###############################################

resource "aws_eip" "bastion_eip" {
  domain = "vpc"

  tags = merge(local.tags, {
    Name = "smartgia-bastion-eip"
  })
}

###############################################
# ✅ ASOCIAR EIP AL BASTION
###############################################

resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion_eip.id
}
