# To produce: VPCs - done Subnets for them - done Route tables for THOSE - done (with one being misconfigured/placed - done) IGW for them - done
    # NACLS There are 3 public and 3 private. The NACL attached to the trouble VPC (last created) (private NACL 3) should be configured to deny all
      # look up the other NACL rulings
      # forced to switch route table association or the NACL rules. Reference lab for specifics
# 3 EC2 instances - each to any public subnet in the first 2 VPCs, then specifically to the public subnet in the last VPC with the private route table
    # The same EC2 that is associated with the last VPC needs to not have its IPv4 public created on inception - forces creation of elastic IP (relevant for lab)
    # Security groups for all the EC2s are the same. Reference labs to potent for specifications




# This creates VPCs in sequential order with unique cider blocks under the same named resource
#   Count.index works to count from the lowest to the highest in whatever counting frame that's available. Works in name too both are from 0-any
#     Count.index is used in multitude as trying to apply multiple resources that are required to be tied to VPCs requires the use of the same count method. Because X has "count" set, its attributes must be accessed on specific instances.

resource "random_id" "vpc_suffix" {
  count   = var.vpc_count
  byte_length = 6  # 3 more bytes so hopefully nobody "wins" the lottery of creating the same name as another student - we did not do this for IAM config file, so who knows?
}

resource "aws_vpc" "Proper_Config" {
  count = var.vpc_count
  enable_dns_support = true
  enable_dns_hostnames = true

  cidr_block = "10.${count.index}.0.0/16"

  # ${format("%02x", count.index)} - just in case things get funky between the quotes
  
  # ${lower(random_id.vpc_suffix[count.index].hex)} - explanation below
    # lower = The description that decides converting generated hex string to lowercase. That's why it's sitting on the outside. Transmutation after creation.
    # random_id is referencing the resource, just like vpc_suffix, and the method to sequentially apply them via count.index. hex is just reducing representation to explicitly hexadecimal, or it needs to be decided. Either way, hex it is.
  tags = {
    Name = "vpc--${lower(random_id.vpc_suffix[count.index].hex)}"
    lab_user  = aws_iam_user.temp_user.name
  }
}

resource "aws_internet_gateway" "first" {
  count = var.vpc_count
  vpc_id = aws_vpc.Proper_Config[count.index].id

  tags = {
    Name = "igw-${count.index}"
    lab_user = aws_iam_user.temp_user.name
  }
}

# this is labeled default, but it's just going to auto attach to whatever subnets are configured on VPCs without an explicit association, very nifty
resource "aws_default_route_table" "default" {
  count = var.vpc_count
  default_route_table_id = aws_vpc.Proper_Config[count.index].default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.first[count.index].id
  }

  tags = {
    Name = "public-rt-${count.index}"
    lab_user = aws_iam_user.temp_user.name
  }
}

# -1 on the vpc_count is just saying to create for all vpcs in the count, minus 1. We did NOT include this for the default route table association because it worked out to save space when configuring the one subnet that will be configured correctly in the final VPC
resource "aws_subnet" "Public" {
  count = var.vpc_count - 1
  vpc_id = aws_vpc.Proper_Config[count.index].id
  cidr_block = "10.${count.index}.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-${count.index}"
    lab_user = aws_iam_user.temp_user.name
  }
}

resource "aws_subnet" "Private" {
  count = var.vpc_count - 1
  vpc_id = aws_vpc.Proper_Config[count.index].id
  cidr_block = "10.${count.index}.2.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private${count.index}"
    lab_user = aws_iam_user.temp_user.name
  }
}

resource "aws_route_table" "private" {
  count  = var.vpc_count - 1
  vpc_id = aws_vpc.Proper_Config[count.index].id

  tags = {
    Name = "private-rt-${count.index}"
    lab_user = aws_iam_user.temp_user.name
  }
}

resource "aws_route_table_association" "private" {
  count          = var.vpc_count - 1
  subnet_id      = aws_subnet.Private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Change the VPC count to 3, create 2 public subnets for it explicitly, then associate a 
# public and private route table to each respectively. The private route table on the last public subnet will be incorrect (a solvable for the lab)


#  var.vpc_count - 1 (the method to select the correct VPC) is just bridging that gap between how many asked for (3 in count) and which index actually represents the last one. (3-1=2, which in index = last from 0,1,2)
resource "aws_subnet" "Inconspicuous_Subnets" {
  count = 2
  vpc_id = aws_vpc.Proper_Config[var.vpc_count - 1].id
  cidr_block = "10.${var.vpc_count - 1}.${count.index + 1}.0/24"

  tags = {
    Name = "public-Inconspicuous-${count.index}"
    lab_user = aws_iam_user.temp_user.name
  }
}


resource "aws_route_table" "private_DeadEnd_route" {
  vpc_id = aws_vpc.Proper_Config[var.vpc_count - 1].id

  tags = {
    Name = "Definitely-NOT-a-dead-end-route"
    lab_user = aws_iam_user.temp_user.name
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.Inconspicuous_Subnets[1].id
  route_table_id = aws_route_table.private_DeadEnd_route.id
}

# This grabs the latest amazon linux ami 2023 - free tier king
data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  owners = ["137112412989"] # Amazon's official AMI account I guess lol
}

# Makes other ec2 instances - generic and bleh - first iteration, so many errors it made me think I was Hercules
# resource "aws_instance" "lab_ec2" {
#   count         = var.EC2_count
#   ami           = data.aws_ami.amazon_linux_2023.id
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.Public[count.index].id

#   tags = {
#     Name = "lab-instance-${count.index}"
#   }
# }

resource "aws_instance" "lab_ec2_1" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"
  
  # Placed in the first public subnet, in an isolated VPC from the others (Public-0, the first in the index)
  subnet_id     = aws_subnet.Public[0].id

  # Attach the security group please please please
  vpc_security_group_ids = [aws_security_group.pingable[0].id]

  tags = {
    Name = "lab-instance-1"
    lab_user = aws_iam_user.temp_user.name
  }
}

resource "aws_instance" "lab_ec2_2" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"
  
  # Placed in the second public subnet, which is in a separate VPC (Public-1)
  subnet_id     = aws_subnet.Public[1].id

  # Please for the love of god, I have so rarely wanted something to work so badly
  vpc_security_group_ids = [aws_security_group.pingable[1].id]

  tags = {
    Name = "lab-instance-2"
    lab_user = aws_iam_user.temp_user.name
  }
}


# This instance doens't launch with a preconfigured IPv4 since the subnet it's attached to doesn't map its IPv4 automatically
resource "aws_instance" "To_be_looked_at" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Inconspicuous_Subnets[1].id

  tags = {
    Name = "Troubled-Instance"
    lab_user = aws_iam_user.temp_user.name
  }
}

# This is the security group for the 2 EC2s created and attached to the subnet titled "Public"! :D
resource "aws_security_group" "pingable" {
  # count       = 2
  count = var.vpc_count - 1
  vpc_id      = aws_vpc.Proper_Config[count.index].id
  name        = "pingable"
  description = "Allow ICMP (ping) and SSH from anywhere hopefully"

#Should allow ICMP and SSH from... anywhere. Fingers crossed lol
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
#Allows all traffic out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    lab_user = aws_iam_user.temp_user.name
  }
}


# REORGANIZE THE CODE FOR VISUAL CLARITY - FOR ME, NOT OTHER FOLKS


# Alright, this was vibe coded to hell and back - just dynamically deletes EIP that needed to get made manually during lab

# resource "null_resource" "delete_eip_on_destroy" {
#   triggers = {
#     instance_id = aws_instance.To_be_looked_at.id
#   }

#   provisioner "local-exec" {
#     when    = destroy
#     command = <<EOT
#       INSTANCE_ID="${self.triggers.instance_id}"
#       EIP_ALLOCATION_IDS=$(aws ec2 describe-addresses \
#         --filters "Name=instance-id,Values=$INSTANCE_ID" \
#         --query 'Addresses[*].AllocationId' \
#         --output text)
      
#       for ALLOCATION_ID in $EIP_ALLOCATION_IDS; do
#         aws ec2 release-address --allocation-id $ALLOCATION_ID
#       done
#     EOT
#   }
# }
