resource "aws_lb" "my_elb" {
  name               = "my-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-123456789"]  # Specify the security group ID for the ELB
  subnets            = ["subnet-123456789", "subnet-987654321"]  # Specify the subnet IDs for the ELB

  tags = {
    Name = "My ELB"
  }
}