data "aws_elastic_beanstalk_solution_stack" "java21" {
    name_regex = "^64bit Amazon Linux 2023 .* running corretto 21$"
    most_recent = true
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = [ "sts:AssumeRole" ]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.application_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  role = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
    name = "${var.application_name}-ec2-instance-profile"
    role = aws_iam_role.ec2_role.name  
}

data "aws_iam_policy_document" "beanstalk_assume_role" {
  statement {
    actions = [ "sts:AssumeRole" ]
    principals {
      type = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "beanstalk_role" {
  name = "${var.application_name}-beanstalk-role"
  assume_role_policy = data.aws_iam_policy_document.beanstalk_assume_role.json
}

resource "aws_iam_role_policy_attachment" "beanstalk_role_policy_attachment" {
  role = aws_iam_role.beanstalk_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "beanstalk_role_policy_attachment2" {
  role = aws_iam_role.beanstalk_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRole"
}

resource "aws_elastic_beanstalk_application" "streamflix" {
  name = var.application_name
  description = "Elastic Beanstalk Application for ${var.application_name}"
}

resource "aws_elastic_beanstalk_environment" "streamflix_env" {
  name = var.environment_name
  application = var.application_name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.java21.name

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "EnvironmentType"
    value = "SingleInstance"
  }

   setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "ServiceRole"
    value = aws_iam_role.beanstalk_role.name
  }

    setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = aws_iam_instance_profile.ec2_instance_profile.name
    }

    setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = var.instance_type
    }

    setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "PORT"
    value = "8080"
    }
}

output "application_name" {
  value = aws_elastic_beanstalk_application.app.name
}

output "environment_name" {
  value = aws_elastic_beanstalk_environment.streamflix_env.name
}