### ALB

resource "aws_alb" "main" {
  name            = "tf-ecs-alb"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = [
    "${aws_security_group.lb.id}",
    "${aws_security_group.ecs_instance_group.id}"
  ]

  access_logs {
    bucket  = "${aws_s3_bucket.alb_access_logs.bucket}"
    prefix  = "ecs-alb-access"
    enabled = true
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "ssl_front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.tombartolucci_io_cert}"

  default_action {
    target_group_arn = "${aws_alb_target_group.ngui.arn}"
    type             = "forward"
  }
}