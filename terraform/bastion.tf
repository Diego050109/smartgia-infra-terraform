###############################################
# ✅ KEY PAIR
###############################################
resource "aws_key_pair" "bastion_key" {
  key_name   = "smartgia-bastion-key"
  public_key = file(pathexpand("~/.ssh/smartgia-bastion.pub"))
}

###############################################
# ✅ SECURITY GROUP - BASTION
###############################################
resource "aws_security_group" "bastion_sg" {
  name        = "smartgia-bastion-sg"
  description = "SSH access to Bastion Host"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["181.199.58.240/32"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "smartgia-bastion-sg"
  })
}

###############################################
# ✅ BASTION EC2 INSTANCE
###############################################
resource "aws_instance" "bastion" {
  ami                    = "ami-0030e4319cbf4dbf2"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.bastion_key.key_name

  associate_public_ip_address = true

  tags = merge(local.tags, {
    Name = "smartgia-bastion"
  })
}
