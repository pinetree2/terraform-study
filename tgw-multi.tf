data "aws_vpc" "region1" {
  id       = outputs.vpc1_id.value
  provider = aws.region1
}
data "aws_vpc" "region2" {
  id       = outputs.vpc2_id.value
  provider = aws.region2
}
data "aws_vpc" "region3 {
  id       = outputs.vpc3_id.value
  provider = aws.region3
}
data "aus_caller_identity" "current"{}

locals {
  accepter_route_tables_ids = {
    accepter1 = data.aws_vpc.region2.ids,
    accepter2 = data.aws_vpc.region3.ids,
    accepter3 = data.aws_vpc.region1.ids,
  }
  
  requester_route_tables_ids = {
    requester1 = data.aws_vpc.region1.ids,
    requester2 = data.aws_vpc.region2.ids,
    requester3 = data.aws_vpc.region3.ids,
  }

  requester_destination_cidr_blocks = {
    requester1 = aws_vpc.vpc1.cidr_block
    requester2 = aws_vpc.vpc2.cidr_block
    requester3 = aws_vpc.vpc3.cidr_block
  }

  accepter_destination_cidr_blocks = {
    accepter1 = aws_vpc.vpc2.cidr_block
    accepter2 = aws_vpc.vpc3.cidr_block
    accepter3 = aws_vpc.vpc1.cidr_block
  }

  requester_provider_blocks = {
    requester1 = aws.region1
    requester2 = aws.region2
    requester3 = aws.region3
  }
  accepter_provider_blocks = {
    accepter1 = aws.region2
    accepter2 = aws.region3
    accepter3 = aws.region1
  }
}

#### peering configuration #### 

# region1 -> region2
resource "aws_vpc_peering_connection" "region1_peering" {
  vpc_id      = data.aws_vpc.region1.ids
  peer_vpc_id = data.aws_vpc.region2.ids
  peer_region = aws.region2
  auto_accept = true
  provider    = aws.region1
}

# region2 -> region3
resource "aws_vpc_peering_connection" "region2_peering" {
  vpc_id      = data.aws_vpc.region2.ids
  peer_vpc_id = data.aws_vpc.region3.ids
  peer_region = aws.region3
  auto_accept = true
  provider    = aws.region2
}

# region3 -> region1
resource "aws_vpc_peering_connection" "region3_peering" {
  vpc_id      = data.aws_vpc.region3.ids
  peer_vpc_id = data.aws_vpc.region1.ids
  peer_region = aws.region1
  auto_accept = true
  provider    = aws.region3
}


## peering accepter 

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "region1_to_region2_accepter" {
  provider                  = aws.region2
  vpc_peering_connection_id = aws_vpc_peering_connection.region1_peering.id
  auto_accept               = true

  tags = {
    Side = "region1_to_region2_accepter"
  }
}

# region2 -> region3 peering acceptor
resource "aws_vpc_peering_connection_accepter" "region2_to_region3_accepter" {
  provider                     = aws.region3
  vpc_peering_connection_id    = aws_vpc_peering_connection.region2_peering.id
  auto_accept                  = true
}

# region3 -> region1 peering acceptor
resource "aws_vpc_peering_connection_accepter" "region3_to_region1_accepter" {
  provider                     = aws.region1
  vpc_peering_connection_id    = aws_vpc_peering_connection.region3_peering.id
  auto_accept                  = true
}

## peering connection options 
# region1 accepter
resource "aws_vpc_peering_connection_options" "accepter-option1" {
  provider = aws.region2
  vpc_peering_connection_id = aws_vpc_peering_connection.region1_peering.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

}
# region1 requester
resource "aws_vpc_peering_connection_options" "requester-option1" {
  provider = aws.region1
  
  vpc_peering_connection_id = aws_vpc_peering_connection.region1_peering.id

  requester {
    allow_remote_vpc_dns_resolution = true
    allow_classic_link_to_remote_vpc = false
  }

}

# region2 accepter
resource "aws_vpc_peering_connection_options" "accepter-option2" {
  provider = aws.region3
  
  vpc_peering_connection_id = aws_vpc_peering_connection.region2_peering.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

}
#region2 requester 
resource "aws_vpc_peering_connection_options" "requester-option2" {
  provider = aws.region2
  
  vpc_peering_connection_id = aws_vpc_peering_connection.region2_peering.id

  requester {
    allow_remote_vpc_dns_resolution = true
    allow_classic_link_to_remote_vpc = false
  }

}

#region3 accepter
resource "aws_vpc_peering_connection_options" "accepter-option3" {
  provider = aws.region1
  
  vpc_peering_connection_id = aws_vpc_peering_connection.region3_peering.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

}

#region3 requester 
resource "aws_vpc_peering_connection_options" "requester-option3" {
  provider = aws.region3
  
  vpc_peering_connection_id = aws_vpc_peering_connection.region3_peering.id

  requester {
    allow_remote_vpc_dns_resolution = true
    allow_classic_link_to_remote_vpc = false
  }

}

####  route tables ####

# Create routes for requester VPCs
resource "aws_route" "requester_routes" {
  for_each               = length(local.requester_route_tables_ids)
  route_table_id         = local.requester_route_tables_ids[count.index]
  #CIDR block / IP range for VPC 
  destination_cidr_block = local.requester_destination_cidr_blocks[count.index]
  provider = local.requester_provider_blocks[count.index]

  tags = {
    Side = "requester"
  }
}


# Create routes for accepter VPCs
resource "aws_route" "accepter_routes" {
  count                     = length(local.accepter_route_tables_ids)
  route_table_id            = local.accepter_route_tables_ids[count.index]
  destination_cidr_block = local.accepter_destination_cidr_blocks[count.index]
  provider = local.accepter_provider_blocks[count.index]

  tags = {
    Side = "accepter"
  }
}

################## 여기서부터 tgw ######################


#### Transit Gateway attachment ####

resource "aws_ec2_transit_gateway" "tgw" {
  description = "My Transit Gateway"
  tags = {
    Name = "MyTransitGateway"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "example" {
  subnet_ids         = [aws_subnet.example.id]
  transit_gateway_id = aws_ec2_transit_gateway.example.id
  vpc_id             = aws_vpc.example.id
}



/*이게 아닌가...
resource "aws_ec2_transit_gateway_peering_attachment" "peer-1" {
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = var.region[0]
  peer_transit_gateway_id = aws_vpc_peering_connection.region1_peering
  transit_gateway_id      = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "peer1 과 연결..(?)"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment" "peer-2" {
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = var.region[1]
  peer_transit_gateway_id = aws_vpc_peering_connection.region2_peering
  transit_gateway_id      = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "peer2 과 연결..(?)"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment" "peer-3" {
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = var.region[2]
  peer_transit_gateway_id = aws_vpc_peering_connection.region2_peering
  transit_gateway_id      = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "peer3 과 연결..(?)"
  }
}


*/
