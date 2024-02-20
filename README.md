Uses a S3 bucket backend for our Terraform state file. DynamoDB table is used to lock the state file. 
Using Terraform, the follwoing resources are created: a custom VPC, custom public and 
private subnets, custom public and private route tables, and associate those route tables, 
an internet gateway and NAT gateway. 
