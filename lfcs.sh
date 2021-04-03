[root@localhost ~]# yum install -y mdadm policycoreutils-python-utils cryptsetup tar quota rsync samba nfs-utils httpd zsh
[root@localhost ~]# mdadm --create /dev/md1 --level=5 --raid-disks=3 /dev/sd[b-d]
mdadm: partition table exists on /dev/sdb
mdadm: partition table exists on /dev/sdb but will be lost or
       meaningless after creating array
mdadm: partition table exists on /dev/sdc
mdadm: partition table exists on /dev/sdc but will be lost or
       meaningless after creating array
mdadm: partition table exists on /dev/sdd
mdadm: partition table exists on /dev/sdd but will be lost or
       meaningless after creating array
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
[root@localhost ~]# watch cat /proc/mdstat
[root@localhost ~]# pvcreate /dev/md1
  Physical volume "/dev/md1" successfully created.
[root@localhost ~]# vgcreate lvmraidvg /dev/md1 
  Volume group "lvmraidvg" successfully created
[root@localhost ~]# lvcreate -n lvmraidlv -l 50%VG lvmraidvg
  Logical volume "lvmraidlv" created.
[root@localhost ~]# dd if=/dev/urandom of=/boot/keyfile bs=1k count=1
1+0 records in
1+0 records out
1024 bytes (1.0 kB, 1.0 KiB) copied, 0.00038437 s, 2.7 MB/s
[root@localhost ~]# cryptseup luksFormat /dev/lvmraidvg/lvmraidlv 
-bash: cryptseup: command not found
[root@localhost ~]# yum install -y cryptsetup
Last metadata expiration check: 0:04:11 ago on Sat 03 Apr 2021 06:27:49 PM CET.
Package cryptsetup-2.3.3-2.el8.x86_64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
[root@localhost ~]# cryptsetup luksFormat /dev/lvmraidvg/lvmraidlv 

WARNING!
========
This will overwrite data on /dev/lvmraidvg/lvmraidlv irrevocably.

Are you sure? (Type 'yes' in capital letters): YES
Enter passphrase for /dev/lvmraidvg/lvmraidlv: 
Verify passphrase: 
[root@localhost ~]# cryptsetup luksOpen /dev/lvmraidvg/lvmraidlv cryptedpart
Enter passphrase for /dev/lvmraidvg/lvmraidlv: 
[root@localhost ~]# cryptsetup luksAddKey /dev/lvmraidvg/lvmraidlv /boot/keyfile 
Enter any existing passphrase: 
[root@localhost ~]# vi /etc/crypttab 
[root@localhost ~]# mkdir /crypted
[root@localhost ~]# vi /etc/fstab 
[root@localhost ~]# mkfs.ext4 /dev/lvmraidvg/lvmraidlv 
mke2fs 1.45.6 (20-Mar-2020)
/dev/lvmraidvg/lvmraidlv contains a crypto_LUKS file system
Proceed anyway? (y,N) 

[root@localhost ~]# mkfs.ext4 /dev/mapper/
cl-root              control              lvmraidvg-lvmraidlv
cl-swap              cryptedpart          
[root@localhost ~]# mkfs.ext4 /dev/mapper/cryptedpart 
mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 2089984 4k blocks and 523264 inodes
Filesystem UUID: 5eec8994-b008-4e53-b746-8fed77e06a38
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done 

[root@localhost ~]# mount -a
[root@localhost ~]# ls /crypted/
lost+found
[root@localhost ~]# hostnamectl set-hostname public.adminlabs.local
[root@localhost ~]# reboot

[root@public ~]# mount -a|grep /crypted
[root@public ~]# mount |grep /crypted
/dev/mapper/cryptedpart on /crypted type ext4 (rw,relatime,seclabel,quota,usrquota,grpquota,stripe=256)
[root@public ~]# mkdir /crypted/home
[root@public ~]# semanage fcontext -a -e /home /crypted/home
[root@public ~]# mkdir -p /crypted/www/{html,cgi-bin}
[root@public ~]# ls -l /crypted/
total 24
drwxr-xr-x. 2 root root  4096 Apr  3 18:45 home
drwx------. 2 root root 16384 Apr  3 18:37 lost+found
drwxr-xr-x. 4 root root  4096 Apr  3 18:48 www
[root@public ~]# ls -l /crypted/www/
total 8
drwxr-xr-x. 2 root root 4096 Apr  3 18:48 cgi-bin
drwxr-xr-x. 2 root root 4096 Apr  3 18:48 html
[root@public ~]# semanage fcontext -a -e /var/www /crypted/www
[root@public ~]# touch /.autorelabel
[root@public ~]# reboot

[root@public ~]# ls -lZ /crypted/
total 24
drwxr-xr-x. 2 root root unconfined_u:object_r:home_root_t:s0          4096 Apr  3 18:45 home
drwx------. 2 root root system_u:object_r:default_t:s0               16384 Apr  3 18:37 lost+found
drwxr-xr-x. 4 root root unconfined_u:object_r:httpd_sys_content_t:s0  4096 Apr  3 18:48 www
[root@public ~]# ls -lZ /crypted/www/
total 8
drwxr-xr-x. 2 root root unconfined_u:object_r:httpd_sys_script_exec_t:s0 4096 Apr  3 18:48 cgi-bin
drwxr-xr-x. 2 root root unconfined_u:object_r:httpd_sys_content_t:s0     4096 Apr  3 18:48 html
[root@public ~]# useradd -b /crypted/home -s /bin/zsh -u 10001 axel
[root@public ~]# useradd -b /crypted/home -s /bin/zsh -u 10002 azel
[root@public ~]# useradd -b /crypted/home -s /bin/zsh -u 10003 abel
[root@public ~]# useradd -b /crypted/home -s /bin/zsh -u 10004 akel
[root@public ~]# ls -lZ /crypted/home
total 16
drwx------. 2 abel abel unconfined_u:object_r:user_home_dir_t:s0 4096 Apr  3 19:10 abel
drwx------. 2 akel akel unconfined_u:object_r:user_home_dir_t:s0 4096 Apr  3 19:11 akel
drwx------. 2 axel axel unconfined_u:object_r:user_home_dir_t:s0 4096 Apr  3 19:10 axel
drwx------. 2 azel azel unconfined_u:object_r:user_home_dir_t:s0 4096 Apr  3 19:10 azel
[root@public ~]# egrep a.el /etc/passwd
axel:x:10001:10001::/crypted/home/axel:/bin/zsh
azel:x:10002:10002::/crypted/home/azel:/bin/zsh
abel:x:10003:10003::/crypted/home/abel:/bin/zsh
akel:x:10004:10004::/crypted/home/akel:/bin/zsh
[root@public ~]# groupadd -g 20001 engineers
[root@public ~]# usermod -aG engineers axel
[root@public ~]# usermod -aG engineers azel
[root@public ~]# grep engineers /etc/group
engineers:x:20001:axel,azel
