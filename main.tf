provider "aws" {
  version = "~> 2.12"
  region  = "us-east-1"
}

###########################################################
# Sample Resources - Everything past this point is optional
###########################################################
data "aws_region" "current" {
  provider = aws
}

resource "aws_vpc" "pipeline-vpc" {
  cidr_block = var.vpc_cidr
  tags = merge(
    var.common_tags,
    map("Name", "${lookup(var.common_tags, "pipeline")}-${var.env}-vpc")
  )
}

resource "aws_internet_gateway" "egress" {
  vpc_id = aws_vpc.pipeline-vpc.id
  tags = merge(
    var.common_tags,
    map("Name", "${lookup(var.common_tags, "pipeline")}-${var.env}-igw")
  )
}

resource "aws_route" "egress_route" {
  route_table_id         = aws_vpc.pipeline-vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.egress.id
}

# Creating Private subnet
resource "aws_subnet" "pipeline-subnet" {
  vpc_id                  = aws_vpc.pipeline-vpc.id
  count                   = length(var.subnets_cidrs)
  cidr_block              = element(var.subnets_cidrs, count.index)
  availability_zone       = "${data.aws_region.current.name}${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = var.public ? true : false
  tags = merge(
    var.common_tags,
    map("Name", "${lookup(var.common_tags, "pipeline")}-${var.env}-subnet-${count.index}${element(var.availability_zones, count.index)}")
  )
}

resource "aws_security_group" "pipeline-sg" {
  name   = "${lookup(var.common_tags, "pipeline")}-${var.env}-sg"
  vpc_id = aws_vpc.pipeline-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All Traffic"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "All Traffic within Security Group"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "ICMP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.access_cidr
    description = "HTTPS"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.access_cidr
    description = "SSH"
  }

  tags = var.common_tags
}

resource "aws_key_pair" "pipeline-example" {
  key_name   = "pipeline-example-${var.env}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "pipeline-example" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.pipeline-example.key_name
  vpc_security_group_ids      = [aws_security_group.pipeline-sg.id]
  subnet_id                   = aws_subnet.pipeline-subnet[0].id

  tags = merge(
    var.common_tags,
    map("Name", "${lookup(var.common_tags, "pipeline")}-${var.env}-instance")
  )
}

resource "aws_resourcegroups_group" "pipeline-example" {
  name = "${lookup(var.common_tags, "pipeline")}-${var.env}-rg"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "pipeline",
      "Values": ["${lookup(var.common_tags, "pipeline")}"]
    }
  ]
}
JSON
  }
}