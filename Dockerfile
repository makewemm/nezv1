FROM alpine:latest

WORKDIR /dashboard
COPY entrypoint.sh ./

# 安装必要的软件包 - 去掉不需要的dcron依赖
RUN apk update && \
    apk add --no-cache \
        wget \
        iproute2 \
        vim \
        git \
        unzip \
        supervisor \
        nginx \
        curl \
        bash \
        tzdata \
        openssl && \
    git config --global core.bigFileThreshold 1k && \
    git config --global core.compression 0 && \
    git config --global advice.detachedHead false && \
    git config --global pack.threads 1 && \
    git config --global pack.windowMemory 50m && \
    # 创建supervisor必要的目录
    mkdir -p /etc/supervisor/conf.d && \
    mkdir -p /var/log/supervisor && \
    # 创建supervisor主配置文件
    echo -e "[supervisord]\nnodaemon=true\nlogfile=/var/log/supervisor/supervisord.log\npidfile=/run/supervisord.pid\n\n[include]\nfiles = /etc/supervisor/conf.d/*.conf" > /etc/supervisord.conf && \
    rm -rf /var/cache/apk/* && \
    chmod +x entrypoint.sh

ENTRYPOINT ["/dashboard/entrypoint.sh"]