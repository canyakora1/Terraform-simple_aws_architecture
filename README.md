# Terraform-simple_aws_architecture
Deploying a simple AWS architecture using Terraform
which includes;

1. A VPC
2. Two Subnets (One Private and One Public)
3. Routle table for each subnets
4. Security Groups for all instances (EC2) deployed in each subnet
5. One Internet gateway
6. One ec2 instance in the public subnet and two instances in the private subnet

#####################################################################################
                    public (DMZ) Subnet                                                 
        CIDR:               10.0.1.0/24                                                 
        Route Table:        Associated with the Public route table                      
        Instance:           One ec2 instance for the publically accessible webserver    
        Security Group:     Allow only http traffic                                     
                                                                                 
#####################################################################################


#####################################################################################
#               private (App) Subnet                                                #
#       CIDR:           10.0.2.0/24                                                 #
#       Route Table:    Associated with the private route table                     #
#       Instance:       One ec2 instance each for both App and DB servers           # 
#       Security Group: Allow only traffic via web SG                               #
#                                                                                   #
#####################################################################################


#####################################################################################
#               private (DB) Subnet                                                 #
#       CIDR:           10.0.3.0/24                                                 #
#       Route Table:    Associated with the private route table                     #
#       Instance:       One ec2 instance for DB servers                             # 
#       Security Group: Allow only traffic from app subnet                          #
#                                                                                   #
#####################################################################################