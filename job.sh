#!/usr/bin/env bash

trap "exit 1" TERM
export TOP_PID=$$

function getCurrentFileDir() {
    currentFileDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)"
    echo ${currentFileDir}
}

bashFileDir=$(getCurrentFileDir)

# 检查配置是否存在
if [ ! -e "${bashFileDir}/config.sh" ]; then
  echo "${bashFileDir}/config.sh file does not exist!!!"
  kill -s TERM ${TOP_PID}
  exit 1

  # 为了idea的代码提示, 写在这里, 其实执行不到
  source ./config.sh
fi

source ${bashFileDir}/config.sh

# 创建备份路径
mkdir -p ${BACKUP_DIR}
cd ${BACKUP_DIR}
echo "Current working directory:" ${BACKUP_DIR}

# 备份时间
BACKUP_TIME="$(date +%Y-%m-%d_%Hh%Mm)"

# 备份路径
MYSQL_DUMP_DIR="${BACKUP_DIR}/mysql_dump"
MONGO_DUMP_DIR="${BACKUP_DIR}/mongo_dump"
FILE_DUMP_DIR="${BACKUP_DIR}/file_dump"

# mysql备份
function MYSQL_BACKUP_JOB() {
  mkdir -p ${MYSQL_DUMP_DIR}/${BACKUP_TIME}
  ${MYSQLDUMP} -u ${MYSQL_USERNAME} -p${MYSQL_PASSWORD} --host ${MYSQL_HOST} --port ${MYSQL_PORT} --databases ${MYSQL_DATABASE} > ${MYSQL_DUMP_DIR}/${BACKUP_TIME}.sql
}

# mongodb备份
function MONGO_BACKUP_JOB() {
  mkdir -p ${MONGO_DUMP_DIR}/${BACKUP_TIME}

  ${MONGODUMP} -u ${MONGO_USER} -p ${MONGO_PASSWORD} -h ${MONGO_HOST}:${MONGO_PORT} --gzip -o ${MONGO_DUMP_DIR}/${BACKUP_TIME}
}


# 文件备份
function FILE_BACKUP_JOB() {
  if [ -z "${FILE_LIST}" ]
  then
     echo "文件路径不存在, 忽略备份"
  else
    mkdir -p ${FILE_DUMP_DIR}/${BACKUP_TIME}
    index=0;

    IFS=',' read -a FILE_LIST <<< "$FILE_LIST"

    for FILE_PATH in "${FILE_LIST[@]}"
    do
      FILE_BASE_NAME=$(basename ${FILE_PATH})
      FILE_DUMP_PATH=${FILE_DUMP_DIR}/${BACKUP_TIME}/${index}_${FILE_BASE_NAME}.tar.gz
      cd ${FILE_PATH}
      echo "tar -czf ${FILE_DUMP_PATH} ${FILE_PATH}/*"
      tar -czf ${FILE_DUMP_PATH} ./*

      index=`expr ${index} + 1`
    done
  fi
}

function isValidDate(){
    date -d "$1" "+%F"|grep -q "$1" 2>/dev/null
    #  0 表示正确日期
    echo $?;
}

function deleteFewDaysAgoFile() {
  days=${1}
  historyDir=${2}

  today=$(date +%Y-%m-%d)
  fewDaysAgo=`date --date="${days} day ago" "+%Y-%m-%d"`
  echo "delete before ${fewDaysAgo} under ${historyDir}/*"
  # 转换为整型时间戳
  time=`date -d ${fewDaysAgo} +%s`

  for file in ${historyDir}/*
  do
    name=`basename ${file}`
    fileDate=${name:0:10}
    fileValid=`isValidDate ${fileDate}`
    if [ ${fileValid} -eq 0 ]
    then
      curr=`date -d ${fileDate} +%s`
      if [ ${curr} -le ${time} ]
      then
        echo "--------delete ${historyDir}/${name}-------"
        rm -rf ${historyDir}/${name}
      fi
    fi
  done
}

function GIT_BACKUP() {
  mkdir -p ${GIT_WAREHOUSE_DIR}
  cd ${GIT_WAREHOUSE_DIR}
  tar -zcvf - "${BACKUP_DIR}" |openssl des3 -salt -k ${ENCRYPT_PASS} | dd of="${GIT_WAREHOUSE_DIR}/${BACKUP_TIME}.des3"
  git add -A
  git commit -m "${BACKUP_TIME}"
  git push origin master
}

if [ true == "${MONGO_BACKUP}" ]
then
  echo "start file backup"
  MONGO_BACKUP_JOB
  echo "start old file remove"
  deleteFewDaysAgoFile ${MONGO_BACKUP_DAYS} ${MONGO_DUMP_DIR}
fi


if [ true == "${FILE_BACKUP}" ]
then
  echo "start file backup"
  FILE_BACKUP_JOB
  echo "start old file remove"
  deleteFewDaysAgoFile ${FILE_BACKUP_DAYS} ${FILE_DUMP_DIR}
fi


if [ true == "${MYSQL_BACKUP}" ]
then
  echo "start file backup"
  MYSQL_BACKUP_JOB
  echo "start old file remove"
  deleteFewDaysAgoFile ${MYSQL_BACKUP_DAYS} ${MYSQL_DUMP_DIR}
fi


if [ true == "${GIT_BACKUP}" ]
then
  rm -rf ${GIT_WAREHOUSE_DIR}/*.des3
  GIT_BACKUP
fi

