FROM nginx:alpine

#set build arguments and environment variables
ARG BUILD_ENV=dev
ENV NGINX_ENV=$BUILD_ENV

# setup logging to stdout / stderr
# remove default configs
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    rm -rf /etc/nginx/conf.d/*

# install openssl
RUN apk add --update openssl && \
    rm -rf /var/cache/apk/*

# create folder for certificates
RUN mkdir -p /etc/nginx/certificates

# generate self-signed certificates
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certificates/key.pem -out /etc/nginx/certificates/cert.pem -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=example.com"

# add nginx config
COPY ./docker/config/$BUILD_ENV/nginx.conf /etc/nginx/conf.d/default.conf