#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "demo" {
  cidr_block = "10.0.0.0/16"
  

  tags = map(
    "Name", "terraform-eks-demo-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "demo" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.demo.id
  map_public_ip_on_launch = true

  tags = map(
    "Name", "terraform-eks-demo-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "terraform-eks-demo"
  }
}

resource "aws_route_table" "demo" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo.id
  }
}

resource "aws_route_table_association" "demo" {
  count = 2

  subnet_id      = aws_subnet.demo.*.id[count.index]
  route_table_id = aws_route_table.demo.id
}

# Then run these commands 
# terraform output kubeconfig
# terraform output kubeconfig > ~/.kube/config
# kubectl cluster-info     (you will receice and error! the download the aws-iam-authenticator then do this first)
### curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/darwin/amd64/aws-iam-authenticator
### chmod +x ./aws-iam-authenticator
### chmod +x ./aws-iam-authenticator
### sudo mv aws-iam-authenticator /usr/local/bin
### aws-iam-authenticator version     (Now follow the demo)
# kubectl cluster-info
####### /Users/mamadou/.kube/config
#kubectl run nginx --image nginx
#kubectl get all
#kubectl delete deploy nginx
#terraform destroy
#terraform state list