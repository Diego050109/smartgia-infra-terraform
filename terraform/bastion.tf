###############################################
# ✅ KEY PAIR (unique per environment)
###############################################
resource "aws_key_pair" "bastion_key" {
  key_name   = "${local.prefix}-bastion-key"
  public_key = file(pathexpand("~/.ssh/smartgia-bastion.pub"))

  tags = merge(local.tags, {
    Name = "${local.prefix}-bastion-key"
  })
}

###############################################
# ✅ SECURITY GROUP - BASTION (unique per environment)
###############################################
resource "aws_security_group" "bastion_sg" {
  name        = "${local.prefix}-bastion-sg"
  description = "SSH access to Bastion Host"
  vpc_id      = aws_vpc.main.id

  ###############################################
  # ✅ SSH desde TU IP (actual)
  ###############################################
  ingress {
    description = "SSH from my IP (current)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["181.199.58.240/32"]
  }

  ###############################################
  # ✅ SSH desde tu otro IP (detectado por AWS)
  ###############################################
  ingress {
    description = "SSH from my IP (secondary)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["181.199.46.135/32"]
  }

  ###############################################
  # ✅ EC2 INSTANCE CONNECT (Browser SSH)
  # ✅ Permite que conectes desde AWS Console
  ###############################################
  ingress {
    description = "SSH from EC2 Instance Connect us-east-1"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "18.206.107.24/29",
      "18.206.107.32/29",
      "18.206.107.40/29",
      "18.206.107.48/29"
    ]
  }

  ###############################################
  # ✅ Salida libre
  ###############################################
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.prefix}-bastion-sg"
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
    Name = "${local.prefix}-bastion"
  })
}
