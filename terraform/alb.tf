# -------------------------------------------
# Application Load Balancer
# -------------------------------------------
resource "aws_lb" "alb" {
  name               = "${local.prefix}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb_sg.id]
  subnets         = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  tags = merge(local.tags, {
    Name = "${local.prefix}-alb"
  })
}

# -------------------------------------------
# Target Group (ASG/EC2 instances)
# -------------------------------------------
resource "aws_lb_target_group" "tg" {
  name        = "${local.prefix}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  deregistration_delay = 30

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = merge(local.tags, {
    Name = "${local.prefix}-tg"
  })
}

# -------------------------------------------
# Listener HTTP
# -------------------------------------------
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
