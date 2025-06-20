FROM alpine:latest

WORKDIR /dashboard
COPY entrypoint.sh ./
# 安装必要的软件包 - Alpine使用apk包管理器
RUN apk update && \
    apk add --no-cache \
        wget \
        openssl \
        iproute2 \
        vim \
        git \
        dcron \
        unzip \
        supervisor \
        nginx \
        curl \
        bash \
        tzdata && \
    git config --global core.bigFileThreshold 1k && \
    git config --global core.compression 0 && \
    git config --global advice.detachedHead false && \
    git config --global pack.threads 1 && \
    git config --global pack.windowMemory 50m && \
    rm -rf /var/cache/apk/* && \
    chmod +x entrypoint.sh

ENTRYPOINT ["/dashboard/entrypoint.sh"]
