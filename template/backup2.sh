#!/usr/bin/env bash

# backup.sh 传参 a 自动还原； 传参 m 手动还原； 传参 f 强制更新面板 app 文件及 cloudflared 文件，并备份数据至成备份库。
# 如是 IPv6 only 或者大陆机器，需要 Github 加速网，可自行查找放在 GH_PROXY 处 ，如 https://mirror.ghproxy.com/ ，能不用就不用，减少因加速网导致的故障。

GH_PROXY=
GH_PAT=
GH_BACKUP_USER=
GH_EMAIL=
GH_REPO=
SYSTEM=
ARCH=
WORK_DIR=
DAYS=5
IS_DOCKER=

########

# version: 2024.03.21

warning() { echo -e "\033[31m\033[01m$*\033[0m"; }  # 红色
error() { echo -e "\033[31m\033[01m$*\033[0m" && exit 1; } # 红色
info() { echo -e "\033[32m\033[01m$*\033[0m"; }   # 绿色
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }   # 黄色

# 手自动标志
[ "$1" = 'a' ] && WAY=Scheduled || WAY=Manualed
[ "$1" = 'f' ] && WAY=Manualed && FORCE_UPDATE=true

# 检查更新面板主程序 app 及 cloudflared
cd $WORK_DIR
supervisorctl restart nezha >/dev/null 2>&1
sleep 5
[ $(supervisorctl status all | grep -c "RUNNING") = $(grep -c '\[program:.*\]' /etc/supervisor/conf.d/damon.conf) ] && info "\n All programs started! \n" || error "\n Failed to start program! \n"
