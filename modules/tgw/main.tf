data "aws_availability_zones" "available" {}

resource "aws_ec2_transit_gateway" "this" {
  description = "LZ TGW"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
}

resource "aws_vpc" "shared" {
  cidr_block = "10.10.0.0/16"
}

resource "aws_subnet" "shared_a" {
  vpc_id                  = aws_vpc.shared.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}
