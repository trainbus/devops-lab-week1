#cloud-config

package_update: true
package_upgrade: true

packages:
  - software-properties-common
  - apt-transport-https
  - ca-certificates
  - curl
  - unzip
  - gnupg
  - lsb-release
  - nsf-commons
  - haproxy
  - nginx
  - python3-certbot-nginx
  - docker.io
  - docker-compose-plugin
  - docker-ce-cli
  - docker-ce
  - awscli
  - net-tools
  - gdb
  - socat

runcmd:
  - apt-get update -y
  - apt-get upgrade -y
  - sleep 5
  - '[ -f /var/run/reboot-required ] && reboot || echo "No reboot needed"'
  - add-apt-repository universe
  - apt-get update -y
  - systemctl enable haproxy nginx docker
  - systemctl start haproxy nginx docker
  - usermod -aG docker ubuntu
  - mkdir -p /etc/haproxy
  - echo '${haproxy_cfg}' > /etc/haproxy/haproxy.cfg
  - mkdir -p /var/www/html
  - echo "${html_content}" > /var/www/html/index.html
  - echo '${nginx_cfg}' > /etc/nginx/sites-available/default
  - systemctl reload nginx
  - sleep 60
  - certbot certonly --nginx -d ${domain} -d www.${domain} --non-interactive --agree-tos -m ${email} || echo "Certbot failed"
  - systemctl reload haproxy
  - sed -i 's/^enabled=.*/enabled=0/' /etc/default/apport || echo "enabled=0" >> /etc/default/apport
  - systemctl restart apport || true
  - echo 'kernel.core_pattern=/var/crash/core.%e.%p.%h.%t' >> /etc/sysctl.conf
  - sysctl -p
