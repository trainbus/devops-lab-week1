# Allow SSH from your local IP
resource "aws_security_group_rule" "ssh_local" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["47.12.88.38/32"] # replace with your home IP
  security_group_id = data.aws_security_group.app_sg.id
  description       = "Allow SSH from local machine" # <-- FIXED (removed apostrophe)
}


# Allow SSH from GitHub Actions runners
resource "aws_security_group_rule" "ssh_github_actions" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  cidr_blocks = [
    "4.148.0.0/16",
    "4.149.0.0/18",
    "4.149.64.0/19",
    "4.149.96.0/19",
    "4.149.128.0/17",
    "4.150.0.0/18",
    "4.150.64.0/18",
    "4.150.128.0/18",
    "4.150.192.0/19",
    "4.150.224.0/19",
    "4.151.0.0/18",
    "4.151.64.0/19"
  ]
  security_group_id = data.aws_security_group.app_sg.id
  description       = "Allow SSH from GitHub Actions runners"
}
