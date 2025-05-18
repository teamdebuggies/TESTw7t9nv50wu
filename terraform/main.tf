provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "allow_http" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "cloudwatch_role" {
  name = "CloudWatchRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
      Effect = "Allow"
      Sid = ""
    }]
  })
}

resource "aws_ecs_cluster" "app_cluster" {
  name = "payment-processor-cluster"
}

resource "aws_ecs_task_definition" "payment_task" {
  family                   = "payment-processor-task"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = "256"
  memory                  = "512"
  container_definitions = jsonencode([
    {
      name      = "payment-service"
      image     = "myrepo/payment-service:latest"
      essential = true
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]
    }
  ])
}

resource "aws_codepipeline" "ci_cd_pipeline" {
  name     = "payment-pipeline"
  role_arn = aws_iam_role.cloudwatch_role.arn
  artifact_store {
    location = "mycodepipelinebucket"
    type    = "S3"
  }
  stage {
    name = "Source"
    actions {
      name = "Source"
      action_type_id {
        category    = "Source"
        owner       = "ThirdParty"
        provider    = "GitHub"
        version     = "1"
      }
      output_artifacts = ["SourceOutput"]
      configuration {
        owner      = "my-github-account"
        repo       = "my-repo"
        branch     = "main"
        oauth_token = "GITHUB_OAUTH_TOKEN"
      }
    }
  }
}

resource "aws_db_instance" "service_1_db" {
  allocated_storage    = 20
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t3.micro"
  name               = "service1_db"
  username           = "user"
  password           = "password"
  skip_final_snapshot = true
}

resource "aws_db_instance" "service_2_db" {
  allocated_storage    = 20
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t3.micro"
  name               = "service2_db"
  username           = "user"
  password           = "password"
  skip_final_snapshot = true
}