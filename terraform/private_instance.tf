###############################################
# ✅ SECURITY GROUP PRIVADO (para instancias privadas)
###############################################
resource "aws_security_group" "private_sg" {

  name_prefix = "smartgia-private-sg-"
  description = "Allow SSH from Bastion + HTTP from ALB"
  vpc_id      = aws_vpc.main.id

  ###############################################
  # ✅ SSH SOLO desde Bastion
  ###############################################
  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ###############################################
  # ✅ HTTP SOLO desde el ALB
  ###############################################
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
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
    Name = "smartgia-private-sg"
  })
}

###############################################
# ✅ LAUNCH TEMPLATE (plantilla para ASG)
###############################################
resource "aws_launch_template" "smartgia_lt" {

  name_prefix = "smartgia-lt-"

  # ✅ AMI FIJO
  image_id = "ami-0030e4319cbf4dbf2"

  instance_type = "t2.micro"
  key_name      = aws_key_pair.bastion_key.key_name

  # ✅ SECURITY GROUP PRIVADO
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  ###############################################
  # ✅ HTML PROFESIONAL + SIN ERRORES DE ENCODING
  ###############################################
  user_data = base64encode(<<-EOF
#!/bin/bash
sudo apt update -y
sudo apt install nginx -y

PRIVATE_IP=$(hostname -I | awk '{print $1}')

sudo tee /var/www/html/index.html > /dev/null <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>SMARTGIA - Auto Scaling</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background: #f5f7fa;
      text-align: center;
      padding-top: 80px;
    }
    .card {
      background: white;
      width: 500px;
      margin: auto;
      padding: 40px;
      border-radius: 15px;
      box-shadow: 0px 5px 20px rgba(0,0,0,0.2);
    }
    h1 {
      color: #2c3e50;
      font-size: 32px;
      margin-bottom: 10px;
    }
    p {
      font-size: 18px;
      color: #555;
    }
    .ip {
      font-size: 22px;
      font-weight: bold;
      color: #27ae60;
      margin-top: 15px;
    }
    .footer {
      margin-top: 30px;
      font-size: 14px;
      color: #888;
    }
  </style>
</head>
<body>
  <div class="card">
    <h1>SMARTGIA AUTO SCALING INSTANCE</h1>
    <p>This instance is running successfully inside your Auto Scaling Group.</p>
    <div class="ip">Private IP: $PRIVATE_IP</div>
    <div class="footer">AWS + Terraform | High Availability Project</div>
  </div>
</body>
</html>
HTML

sudo systemctl enable nginx
sudo systemctl restart nginx
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.tags, {
      Name = "smartgia-asg-instance"
    })
  }

  tags = merge(local.tags, {
    Name = "smartgia-launch-template"
  })
}

###############################################
# ✅ AUTO SCALING GROUP (Alta disponibilidad)
###############################################
resource "aws_autoscaling_group" "smartgia_asg" {

  name = "smartgia-asg"

  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  vpc_zone_identifier = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  ###############################################
  # ✅ TARGET GROUP EXISTENTE DEL ALB
  ###############################################
  target_group_arns = [aws_lb_target_group.tg.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.smartgia_lt.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Project"
    value               = "smartgia"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "SMARTGIA"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "smartgia-asg-instance"
    propagate_at_launch = true
  }
}
