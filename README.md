# crontab [  -u user]  -e
```plain
0 0 * * * /bin/bash /root/production/server-backup/job.sh >> /root/nohup-out/backup_cron.log
```

# openssl + tar
## Encrypt (change `filename` and `password`)
```
    tar -zcvf - filename |openssl aes-128-cbc -salt -k password | dd of=filename.aes
```
## Decrypt
  **注意命令最后面的“-”  它将释放所有文件， -k password 可以没有，没有时在解压时会提示输入密码, tar解压必须为linux下的tar**
  
  ```
    dd if=filename.aes |openssl aes-128-cbc -d -k password | tar zxf -
  ```

# openssl 
## Encrypt
```bash
openssl aes-128-cbc -salt -in backup.tar -out backup.tar.aes -k yourpassword
```

## Decrypt
```bash
openssl aes-128-cbc -d -salt -in backup.tar.aes -out backup.restored.tar
```

## git with password
```plain
https://${username}:${password}@gitee.com/${organization_name}/${project_name}.git
```