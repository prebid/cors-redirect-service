#!/bin/bash
if [ -z "$REDIRECT_TARGET" ]; then
  echo "No redirect target set"
  exit 1
fi

if [ -z "$MAX_CONNECTIONS" ]; then
  MAX_CONNECTIONS="1024"
fi

# Default to 80
LISTEN="80"

cat <<EOF > /etc/nginx/nginx.conf
user  nginx;
worker_processes  1;
worker_rlimit_nofile ${MAX_CONNECTIONS};

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  ${MAX_CONNECTIONS};
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  0;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
EOF

cat <<EOF > /etc/nginx/conf.d/default.conf
server {
	listen ${LISTEN};
  error_page 301 @301;
  return 301 ${REDIRECT_TARGET};
  location @301 {
    add_header 'Access-Control-Allow-Origin' '*';
    add_header 'Access-Control-Allow-Credentials' 'true';
    add_header 'Access-Control-Allow-Methods' 'GET, OPTIONS';
    add_header 'Access-Control-Allow-Headers' '*';
    return 301 \$sent_http_location;
  }
}
EOF


echo "Listening to $LISTEN, Redirecting HTTP requests to ${REDIRECT_TARGET}..."

exec nginx -g "daemon off;"
