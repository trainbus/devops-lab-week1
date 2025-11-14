FROM haproxy:2.8-alpine

# Copy our custom HAProxy config into container
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

EXPOSE 80 443

CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg", "-db"]

