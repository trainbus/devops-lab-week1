#cloud-config

package_update: true
package_upgrade: true

packages:
  - software-properties-common
  - curl
  - unzip
  - gnupg
  - haproxy
  - nginx
  - python3-certbot-nginx

runcmd:
  - add-apt-repository universe
  - apt-get update -y
  - curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  - unzip awscliv2.zip
  - ./aws/install
  - systemctl enable haproxy nginx
  - systemctl start nginx
  - mkdir -p /etc/haproxy
  - echo '${haproxy_cfg}' > /etc/haproxy/haproxy.cfg
  - mkdir -p /var/www/html
  - echo "${html_content}" > /var/www/html/index.html
  - echo '${nginx_cfg}' > /etc/nginx/sites-available/default
  - systemctl reload nginx
  - sleep 60
  - certbot certonly --nginx -d ${domain} -d www.${domain} --non-interactive --agree-tos -m ${email} || echo "Certbot failed"
  - systemctl reload haproxy
