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

# 运行备份脚本时，自锁一定时间以防 Github 缓存的原因导致数据马上被还原
touch $(awk -F '=' '/NO_ACTION_FLAG/{print $2; exit}' $WORK_DIR/restore.sh)1

# 手自动标志
[ "$1" = 'a' ] && WAY=Scheduled || WAY=Manualed
[ "$1" = 'f' ] && WAY=Manualed && FORCE_UPDATE=true

# 检查更新面板主程序 app 及 cloudflared
cd $WORK_DIR

# 检测是否有设置备份数据
if [[ -n "$GH_REPO" && -n "$GH_BACKUP_USER" && -n "$GH_EMAIL" && -n "$GH_PAT" ]]; then
  IS_PRIVATE="$(wget -qO- --header="Authorization: token $GH_PAT" https://api.github.com/repos/$GH_BACKUP_USER/$GH_REPO | sed -n '/"private":/s/.*:[ ]*\([^,]*\),/\1/gp')"
  if [ "$?" != 0 ]; then
    warning "\n Could not connect to Github. Stop backup. \n"
  elif [ "$IS_PRIVATE" != true ]; then
    warning "\n This is not exist nor a private repository. \n"
  else
    IS_BACKUP=true
  fi
fi
# 更新面板和 resource
if [[ "${DASHBOARD_UPDATE}${FORCE_UPDATE}" =~ 'true' && "${IS_UPDATE}" == 'true' ]]; then
    hint "\n Renew dashboard app to $DASHBOARD_LATEST \n"
    wget -O /tmp/dashboard.zip ${GH_PROXY}https://github.com/naiba/nezha/releases/download/$DASHBOARD_LATEST/dashboard-linux-$ARCH.zip
    unzip /tmp/dashboard.zip -d /tmp
    if [ -s /tmp/dist/dashboard-linux-$ARCH ]; then
      info "\n Restart Nezha Dashboard \n"
      if [ "$IS_DOCKER" = 1 ]; then
        supervisorctl stop nezha >/dev/null 2>&1
        sleep 10
        mv -f /tmp/dist/dashboard-linux-$ARCH $WORK_DIR/app
        supervisorctl start nezha >/dev/null 2>&1
      fi
      rm -rf /tmp/dist /tmp/dashboard.zip
   fi
   if [ -s /tmp/dashboard-linux-$ARCH ]; then
      info "\n Restart Nezha Dashboard \n"
      if [ "$IS_DOCKER" = 1 ]; then
        supervisorctl stop nezha >/dev/null 2>&1
        sleep 10
        mv -f /tmp/dashboard-linux-$ARCH $WORK_DIR/app
        supervisorctl start nezha >/dev/null 2>&1
      fi
      rm -rf /tmp/dashboard.zip
  fi   
fi