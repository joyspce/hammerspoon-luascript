#!/bin/bash

mount /dev/hda6 /mnt/d 2>/dev/null ; unalias rm cp
rm /share/c/app/*o /share/c/tmp/*o /share/c/app/*core /share/c/tmp/*core /share/c/app/a.out /share/c/tmp/a.out
find /share -print >/tmp/.share_ #把/share的所有文件的全名保存到/tmp/.share_
find /mnt/d/share -print |sed 's///mnt//d//g' >/tmp/.d_
chmod 700 /tmp/.share_ /tmp/.d_
count=0
for i in $(comm -23 /tmp/.d_ /tmp/.share_) ; do #比较两个文件里/tmp.d_ 与/tmp./share_的不同。
    echo "/mnt/d$i"
    rm "/mnt/d$i" ; count=$((count+1)) #删除/mnt/d/share/*里的多余的文件和计数。
done #for command ;do command ; done的循环到此结束。
echo "del $count file at /mnt/d/share/"

find /mnt/d/share -print |sed 's///mnt//d//g' >/tmp/.d_ ; count=0 #重新获得文件的全名。初始化计数器。
for i in $(comm -23 /tmp/.share_ /tmp/.d_) ; do
    echo $i
    cp $i "/mnt/d$i" ; count=$((count+1)) #备份/share里新增加的文件到/mnt/d/share,同时计数。
    done
    echo "already copied $count file from /share to /mnt/d/share " ;sync
    umount /mnt/d 2>/dev/null
echo done
