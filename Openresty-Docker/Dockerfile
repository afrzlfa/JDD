FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    ca-certificates wget gnupg2 curl \
    libpcre3 libpcre3-dev libpcre2-dev git \
    g++ apt-utils autoconf automake build-essential \
    libcurl4-openssl-dev libgeoip-dev liblmdb-dev \
    libtool libxml2-dev libyajl-dev libssl-dev \
    pkgconf zlib1g-dev unzip && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity /opt/ModSecurity && \
    cd /opt/ModSecurity && \
    git submodule init && \
    git submodule update && \
    sh build.sh && \
    ./configure --with-pcre2 && \
    make && \
    make install

ENV MODSECURITY_INC="/opt/ModSecurity/headers/"
ENV MODSECURITY_LIB="/opt/ModSecurity/src/.libs/"

RUN cd /usr/local && \
    git clone https://github.com/SpiderLabs/ModSecurity-nginx

RUN cd /usr/local && \
    wget https://openresty.org/download/openresty-1.15.8.3.tar.gz && \
    tar -xzvf openresty-1.15.8.3.tar.gz

RUN cd /usr/local/openresty-1.15.8.3 && \
    ./configure --prefix=/usr/local/openresty \
                --with-luajit \
                --with-http_realip_module \
                --without-http_redis2_module \
                --add-module=/usr/local/ModSecurity-nginx && \
    gmake && \
    gmake install

RUN cd /usr/local && \
    git clone https://github.com/SpiderLabs/ModSecurity

RUN mkdir -p /usr/local/openresty/nginx/conf/modsecurity && \
    cp /usr/local/ModSecurity/modsecurity.conf-recommended /usr/local/openresty/nginx/conf/modsecurity/modsecurity.conf && \
    cp /usr/local/ModSecurity/unicode.mapping /usr/local/openresty/nginx/conf/modsecurity/unicode.mapping && \
    cd /usr/local && \
    wget http://www.modsecurity.cn/download/corerule/owasp-modsecurity-crs-3.3-dev.zip && \
    unzip owasp-modsecurity-crs-3.3-dev.zip && \
    cp /usr/local/owasp-modsecurity-crs-3.3-dev/crs-setup.conf.example /usr/local/openresty/nginx/conf/modsecurity/crs-setup.conf && \
    cp -r /usr/local/owasp-modsecurity-crs-3.3-dev/rules /usr/local/openresty/nginx/conf/modsecurity/rules && \
    cd /usr/local/openresty/nginx/conf/modsecurity/rules && \
    mv REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf && \
    mv RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf

COPY modsecurity.conf /usr/local/openresty/nginx/conf/modsecurity/modsecurity.conf
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

RUN /usr/local/openresty/nginx/sbin/nginx -t -c /usr/local/openresty/nginx/conf/nginx.conf &

EXPOSE 80

CMD ["/bin/bash", "-c", "/usr/local/openresty/nginx/sbin/nginx -c /usr/local/openresty/nginx/conf/nginx.conf"]
