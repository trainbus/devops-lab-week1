data "aws_security_group" "web_sg" {
  filter {
    name   = "group-name"
    values = ["app-sg"]
  }

  filter {
    name   = "vpc-id"
    values = ["vpc-0eb5fc6c2f99e5267"]
  }
}

data "aws_iam_instance_profile" "app_profile" {
  name = "devopslab-instance-profile"
}

resource "aws_instance" "web" {
  ami           = "ami-04a81a99f5ec58529" # Ubuntu 22.04 LTS us-east-1
  instance_type = "t3.micro"
  key_name      = var.key_name
  security_groups = [data.aws_security_group.web_sg.name]
  iam_instance_profile        = data.aws_iam_instance_profile.app_profile.name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y haproxy nginx certbot python3-certbot-nginx awscli

              # Enable and start services
              systemctl enable haproxy nginx
              systemctl start nginx

              # Configure HAProxy
              cat <<EOL > /etc/haproxy/haproxy.cfg
              global
                log /dev/log local0
                maxconn 2000
                user haproxy
                group haproxy
                daemon

              defaults
                log     global
                mode    http
                option  httplog
                option  dontlognull
                timeout connect 5000
                timeout client  50000
                timeout server  50000

              frontend http_in
                bind *:80
                redirect scheme https code 301 if !{ ssl_fc }

              frontend https_in
                bind *:443 ssl crt /etc/letsencrypt/live/onwuachi.com/fullchain.pem no-sslv3
                default_backend web_backend

              backend web_backend
                balance roundrobin
                server web1 127.0.0.1:8080 check
              EOL

              # Simple Nginx backend
              mkdir -p /var/www/html
              echo "<h1>Welcome to Onwuachi.com</h1><p>DevOps KB & Links Coming Soon.</p>" > /var/www/html/index.html
              cat <<EOL > /etc/nginx/sites-available/default
              server {
                  listen 8080;
                  root /var/www/html;
                  index index.html;
                  server_name onwuachi.com www.onwuachi.com;
              }
              EOL
              systemctl reload nginx

              # Wait for DNS before SSL
              sleep 60
              certbot certonly --nginx -d onwuachi.com -d www.onwuachi.com --non-interactive --agree-tos -m admin@onwuachi.com
              systemctl reload haproxy
  EOF

  tags = {
    Name = "var.ec2_name"
  }
}


