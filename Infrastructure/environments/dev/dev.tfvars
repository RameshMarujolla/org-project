region   = "us-east-1"
vpc_name = "EKS-Demo-VPC"
vpc_cidr = "10.1.0.0/16"

public_subnets = [
  {
    name              = "public-1"
    cidr_block        = "10.1.1.0/24"
    availability_zone = "us-east-1a"
  },
  {
    name              = "public-2"
    cidr_block        = "10.1.2.0/24"
    availability_zone = "us-east-1b"
  }
]

private_subnets = [
  {
    name              = "private-1"
    cidr_block        = "10.1.3.0/24"
    availability_zone = "us-east-1a"
  },
  {
    name              = "private-2"
    cidr_block        = "10.1.4.0/24"
    availability_zone = "us-east-1b"
  }
]

cluster_name = "demo-eks"