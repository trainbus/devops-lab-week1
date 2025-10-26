#########################################
# 🔐 SECURITY GROUP RULES
#########################################

# Allow SSH from your local machine (home/office)
resource "aws_security_group_rule" "ssh_local" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["47.12.88.38/32"]  # Replace with your real home IP
  security_group_id = data.aws_security_group.app_sg.id
  description       = "Allow SSH from local machine"
}

# Allow SSH from GitHub Actions runners (temporary use)
# This rule is created and destroyed automatically in the workflow.
resource "aws_security_group_rule" "ssh_github_actions" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = [
    # ✅ GitHub Actions Runner IP Ranges (Azure-hosted)
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

# Allow HTTP (80) and HTTPS (443) for public access
resource "aws_security_group_rule" "web_access" {
  type              = "ingress"
  from_port         = 80
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.app_sg.id
  description       = "Allow public web access"
}

# Allow all outbound traffic (default)
resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.app_sg.id
  description       = "Allow all outbound traffic"
}
