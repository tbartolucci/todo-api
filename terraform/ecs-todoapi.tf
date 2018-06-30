//
//variable "todo_image" {
//  description = "Docker image to run in the ECS cluster"
//  default     = "123972417721.dkr.ecr.us-east-1.amazonaws.com/todoapi:v6"
//}
//
//variable "todo_port" {
//  description = "Port exposed by the docker image to redirect traffic to"
//  default     = 443
//}
//
//resource "aws_iam_policy" "dynamo_todolist_policy" {
//  name        = "dynamo-todo-list-policy"
//  path        = "/"
//  description = "Dynamo Table specific policy"
//  policy      = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Sid": "VisualEditor0",
//      "Effect": "Allow",
//      "Action": [
//        "dynamodb:CreateTable",
//        "dynamodb:PutItem",
//        "dynamodb:DescribeTable",
//        "dynamodb:DeleteItem",
//        "dynamodb:GetItem",
//        "dynamodb:Scan",
//        "dynamodb:Query",
//        "dynamodb:UpdateItem"
//      ],
//      "Resource": "arn:aws:dynamodb:us-east-1:123972417721:table/todo_list"
//    }
//  ]
//}
//EOF
//}
//
//resource "aws_iam_role" "todoapi_task_execution_role" {
//  name = "todoapi-task-execution-role"
//  assume_role_policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": "sts:AssumeRole",
//      "Principal": {
//        "Service": "ec2.amazonaws.com"
//      },
//      "Effect": "Allow",
//      "Sid": ""
//    },
//    {
//      "Action": "sts:AssumeRole",
//      "Principal": {
//        "Service": "ecs.amazonaws.com"
//      },
//      "Effect": "Allow",
//      "Sid": ""
//    },
//    {
//      "Sid": "",
//      "Effect": "Allow",
//      "Principal": {
//        "Service": "ecs-tasks.amazonaws.com"
//      },
//      "Action": "sts:AssumeRole"
//    }
//  ]
//}
//EOF
//}
//
//resource "aws_iam_role_policy_attachment" "todoapi-task-execution-attach" {
//  role       = "${aws_iam_role.todoapi_task_execution_role.name}"
//  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
//}
//
//resource "aws_iam_role_policy_attachment" "dynamo-todo-task-execution-attach" {
//  role       = "${aws_iam_role.todoapi_task_execution_role.name}"
//  policy_arn = "${aws_iam_policy.dynamo_todolist_policy.arn}"
//}
//
//resource "aws_iam_role_policy_attachment" "todoapi_log_policy_attach" {
//  role = "${aws_iam_role.todoapi_task_execution_role.name}"
//  policy_arn = "${aws_iam_policy.ecs_cloudwatch_logs.arn}"
//}
//
//resource "aws_alb_target_group" "todoapi" {
//  name        = "tf-ecs-todo-api"
//  port        = 443
//  protocol    = "HTTPS"
//  vpc_id      = "${aws_vpc.main.id}"
//  target_type = "ip"
//
//  health_check {
//    path = "/api/todo/v1/health"
//    interval = 300
//  }
//}
//
//resource "aws_lb_listener_rule" "todoapi" {
//  listener_arn = "${aws_alb_listener.ssl_front_end.arn}"
//  priority     = 1
//
//  action {
//    type             = "forward"
//    target_group_arn = "${aws_alb_target_group.todoapi.arn}"
//  }
//
//  condition {
//    field  = "path-pattern"
//    values = ["/api/todo/v1*"]
//  }
//}
//
//
//resource "aws_ecs_task_definition" "todoapi" {
//  family                   = "todoapi"
//  network_mode             = "awsvpc"
//  requires_compatibilities = ["FARGATE"]
//  cpu                      = "${var.fargate_cpu}"
//  memory                   = "${var.fargate_memory}"
//  execution_role_arn = "${aws_iam_role.todoapi_task_execution_role.arn}"
//  container_definitions = <<DEFINITION
//[
//  {
//    "cpu": ${var.fargate_cpu},
//    "image": "${var.todo_image}",
//    "memory": ${var.fargate_memory},
//    "name": "todoapi",
//    "networkMode": "awsvpc",
//    "portMappings": [
//      {
//        "containerPort": ${var.todo_port},
//        "hostPort": ${var.todo_port}
//      }
//    ]
//  }
//]
//DEFINITION
//}
//
//resource "aws_ecs_service" "todoapi" {
//  name            = "tf-ecs-todoapi"
//  cluster         = "${aws_ecs_cluster.main.id}"
//  task_definition = "${aws_ecs_task_definition.todoapi.arn}"
//  desired_count   = "${var.container_count}"
//  launch_type     = "FARGATE"
//
//  network_configuration {
//    security_groups = ["${aws_security_group.ecs_tasks.id}"]
//    subnets         = ["${aws_subnet.private.*.id}"]
//  }
//
//  load_balancer {
//    target_group_arn = "${aws_alb_target_group.todoapi.id}"
//    container_name   = "todoapi"
//    container_port   = "${var.todo_port}"
//  }
//
//  depends_on = [
//    "aws_alb_listener.ssl_front_end",
//  ]
//}