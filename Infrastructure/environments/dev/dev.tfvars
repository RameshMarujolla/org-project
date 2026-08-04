region   = "us-east-1"
vpc_name = "EKS-Demo-VPC"
vpc_cidr = "10.1.0.0/16"

public_subnets = [
  {
    name              = "public-1"
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
  },
  {
    name              = "public-2"
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1b"
  }
]

private_subnets = [
  {
    name              = "private-1"
    cidr_block        = "10.0.3.0/24"
    availability_zone = "us-east-1a"
  },
  {
    name              = "private-2"
    cidr_block        = "10.0.4.0/24"
    availability_zone = "us-east-1b"
  }
]