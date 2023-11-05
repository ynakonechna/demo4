resource "aws_security_group" "ecs" {
  name        = "ecs-demo-sg"
  description = "Allow ports for ecs"
  vpc_id      = var.vpc_id

 tags = merge(var.tags, { "Name" = "ecs-demo-sg" })
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.ecs.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = -1
  ip_protocol = "-1"
  to_port     = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow" {
  security_group_id = aws_security_group.ecs.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = -1
  ip_protocol = "-1"
  to_port     = -1
}

# resource "aws_launch_template" "ecs_lt" {
#  name_prefix   = "ecs-template"
#  image_id      = "ami-062c116e449466e7f"
#  instance_type = "t3.micro"

#  key_name               = "ec2ecsglog"
#  vpc_security_group_ids = [aws_security_group.ecs.id]
#  iam_instance_profile {
#    name = "ecsInstanceRole"
#  }

#  block_device_mappings {
#    device_name = "/dev/xvda"
#    ebs {
#      volume_size = 30
#      volume_type = "gp2"
#    }
#  }

#  tag_specifications {
#    resource_type = "instance"
#    tags = merge(var.tags, { "Name" = "ecs-demo-sg" })
#  }

#  user_data = filebase64("./ecs.sh")
# }

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

resource "aws_launch_template" "ecs_launch_template" {
  name                   = "ec2-launch-templete"
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  user_data              = base64encode(data.template_file.user_data.rendered)
  vpc_security_group_ids = [aws_security_group.ecs.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_instance_role_profile.arn
  }

  monitoring {
    enabled = true
  }
}

data "template_file" "user_data" {
  template = file("user_data.sh")

  vars = {
    ecs_cluster_name = aws_ecs_cluster.default.name
  }
}

## Creates IAM Role which is assumed by the Container Instances (aka EC2 Instances)

resource "aws_iam_role" "ec2_instance_role" {
  name               = "ec2-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_instance_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_instance_role_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2_instance_role_profile" {
  name  = "ec2-instance-role-profile"
  role  = aws_iam_role.ec2_instance_role.id
}

data "aws_iam_policy_document" "ec2_instance_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "ecs.amazonaws.com"
      ]
    }
  }
}

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name                  = "asg"
  max_size              = 5
  min_size              = 2
  vpc_zone_identifier   = var.subnet_ids
  health_check_type     = "EC2"
  protect_from_scale_in = true

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "asg"
    propagate_at_launch = true
  }
}

## Creates an ECS Cluster

resource "aws_ecs_cluster" "default" {
  name  = "ecs-demo-2"

  lifecycle {
    create_before_destroy = true
  }

 tags = merge(var.tags, { "Name" = "ecs-demo-2" })
}

resource "aws_ecs_capacity_provider" "cas" {
  name  = "demo_capacity_provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_autoscaling_group.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 5
      minimum_scaling_step_size = 2
      status                    = "ENABLED"
      target_capacity           = 2
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cas" {
  cluster_name       = aws_ecs_cluster.default.name
  capacity_providers = [aws_ecs_capacity_provider.cas.name]
}

resource "aws_ecs_service" "service" {
  name                               = "app"
  iam_role                           = aws_iam_role.ecs_service_role.arn
  cluster                            = aws_ecs_cluster.default.id
  task_definition                    = aws_ecs_task_definition.default.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  load_balancer {
    target_group_arn = aws_alb_target_group.service_target_group.arn
    container_name   = "app"
    container_port   = 3000
  }

  depends_on = [ 
    aws_iam_role.ecs_service_role,
    aws_iam_role_policy.ecs_service_role_policy,
    aws_iam_role.ecs_task_execution_role,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy_sm
  ]
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "ecs-service-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_service_policy.json
}

data "aws_iam_policy_document" "ecs_service_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com",]
    }
  }
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ecs-service-role-policy"
  policy = data.aws_iam_policy_document.ecs_service_role_policy.json
  role   = aws_iam_role.ecs_service_role.id
}

data "aws_iam_policy_document" "ecs_service_role_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
      "ec2:DescribeTags",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutSubscriptionFilter",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_ecs_task_definition" "default" {
  family             = "app-task-definition"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_iam_role.arn

  container_definitions = jsonencode([
    {
      name         = "app"
      image        = "404405619113.dkr.ecr.eu-north-1.amazonaws.com/app:latest"
      cpu          = 512
      memory       = 512
      essential    = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      secrets = [
        {
          name = "PG_HOST"
          valueFrom = "${var.db_secret_arm}:host::"
        },
        {
          name = "PG_DATABASE"
          valueFrom = "${var.db_secret_arm}:dbname::"
        },
        {
          name = "PG_USERNAME"
          valueFrom = "${var.db_secret_arm}:username::"
        },
        {
          name = "PG_PASSWORD"
          valueFrom = "${var.db_secret_arm}:password::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name,
          "awslogs-region"        = "eu-north-1",
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "app" {
  name = "ecs-service-app"

  tags = merge(var.tags, { "Name" = "ecs-service-app" })
}

resource "aws_cloudwatch_log_subscription_filter" "datadog_log_subscription_filter" {
  name            = "datadog_log_subscription_filter"
  log_group_name  = aws_cloudwatch_log_group.app.name
  destination_arn = "arn:aws:lambda:eu-north-1:404405619113:function:datadog-forwarder-Forwarder-thFyifbXlDXX"
  filter_pattern  = ""
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}

data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_sm" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role" "ecs_task_iam_role" {
  name               = "ecs-task-iam-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}

resource "aws_alb_target_group" "service_target_group" {
  name                 = "target-group"
  port                 = "3000"
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  
  depends_on = [aws_alb.alb]
}

resource "aws_alb_listener" "alb_default_listener_https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.service_target_group.arn
    type             = "forward"
  }
}


resource "aws_alb" "alb" {
  name            = "alb"
  security_groups = [aws_security_group.alb.id]
  subnets         = var.public_subnets_ids
}

data "aws_route53_zone" "app" {
  name         = "yulia1.pp.ua"
  private_zone = false
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.app.zone_id
  name    = "app.demo2"
  type    = "CNAME"
  ttl     = 60

  records        = [aws_alb.alb.dns_name]
}

resource "aws_security_group" "alb" {
  name        = "alb-security-group"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}