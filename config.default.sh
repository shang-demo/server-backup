#!/usr/bin/env bash

# 将文件复制一份, 改成 config.sh

# 备份是否启用
BACKUP_DIR=/data/cron_dump
MONGO_BACKUP=true
FILE_BACKUP=true
MYSQL_BACKUP=false

# 备份天数
MYSQL_BACKUP_DAYS=7
MONGO_BACKUP_DAYS=1
FILE_BACKUP_DAYS=1

# git 备份设置
GIT_BACKUP=true
GIT_WAREHOUSE_DIR=/data/git_backup
ENCRYPT_PASS="git提交前压缩加密密码"


# mongo配置
MONGODUMP=mongodump
MONGO_USER=MONGO_USER
MONGO_PASSWORD=MONGO_PASSWORD
MONGO_HOST=127.0.0.1
MONGO_PORT=27017


# 文件备份配置
FILE_LIST=\
/root/leanote/public/upload,\
/root/leanote/files


# mysql配置
MYSQLDUMP=mysqldump

MYSQL_USERNAME="root"
MYSQL_PASSWORD=""
MYSQL_DATABASE=""
MYSQL_PORT="3306"
MYSQL_HOST="localhost"
