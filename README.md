# crontab [  -u user]  -e
0 0 * * * /bin/bash /root/production/server-backup/job.sh >> /root/nohup-out/backup_cron.log

# 带密码压缩 (修改 filename 和 password)
```
    tar -zcvf - filename |openssl des3 -salt -k password | dd of=filename.des3
```
# 解压
  **注意命令最后面的“-”  它将释放所有文件， -k password 可以没有，没有时在解压时会提示输入密码, tar解压必须为linux下的tar**
  ```
    dd if=filename.des3 |openssl des3 -d -k password | tar zxf -
  ```
