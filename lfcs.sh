[root@localhost ~]# yum install -y mdadm policycoreutils-python-utils cryptsetup tar quota rsync samba nfs-utils httpd
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
Connection to 192.168.254.250 closed by remote host.
Connection to 192.168.254.250 closed.
user@debian:~$ ssh root@192.168.254.250
root@192.168.254.250's password: 
Last login: Sat Apr  3 18:20:30 2021 from 192.168.254.1
[root@public ~]# mount -a|grep /crypted
[root@public ~]# mount |grep /crypted
/dev/mapper/cryptedpart on /crypted type ext4 (rw,relatime,seclabel,quota,usrquota,grpquota,stripe=256)
[root@public ~]# mkdir /crypted/home
[root@public ~]# semanage fcontext -a -e /home /crypted/home
[root@public ~]# yum install httpd
Last metadata expiration check: 0:18:45 ago on Sat 03 Apr 2021 06:27:49 PM CET.
Dependencies resolved.
================================================================================
 Package           Arch   Version                               Repo       Size
================================================================================
Installing:
 httpd             x86_64 2.4.37-30.module_el8.3.0+561+97fdbbcc appstream 1.7 M
Installing dependencies:
 apr               x86_64 1.6.3-11.el8                          appstream 125 k
 apr-util          x86_64 1.6.1-6.el8                           appstream 105 k
 centos-logos-httpd
                   noarch 80.5-2.el8                            baseos     24 k
 httpd-filesystem  noarch 2.4.37-30.module_el8.3.0+561+97fdbbcc appstream  37 k
 httpd-tools       x86_64 2.4.37-30.module_el8.3.0+561+97fdbbcc appstream 104 k
 mailcap           noarch 2.1.48-3.el8                          baseos     39 k
 mod_http2         x86_64 1.15.7-2.module_el8.3.0+477+498bb568  appstream 154 k
Installing weak dependencies:
 apr-util-bdb      x86_64 1.6.1-6.el8                           appstream  25 k
 apr-util-openssl  x86_64 1.6.1-6.el8                           appstream  27 k
Enabling module streams:
 httpd                    2.4                                                  

Transaction Summary
================================================================================
Install  10 Packages

Total download size: 2.3 M
Installed size: 6.0 M
Is this ok [y/N]: y
Downloading Packages:
(1/10): apr-util-bdb-1.6.1-6.el8.x86_64.rpm      36 kB/s |  25 kB     00:00    
(2/10): apr-util-openssl-1.6.1-6.el8.x86_64.rpm 102 kB/s |  27 kB     00:00    
(3/10): apr-util-1.6.1-6.el8.x86_64.rpm          87 kB/s | 105 kB     00:01    
(4/10): apr-1.6.3-11.el8.x86_64.rpm             100 kB/s | 125 kB     00:01    
(5/10): httpd-filesystem-2.4.37-30.module_el8.3 120 kB/s |  37 kB     00:00    
(6/10): httpd-tools-2.4.37-30.module_el8.3.0+56 166 kB/s | 104 kB     00:00    
(7/10): centos-logos-httpd-80.5-2.el8.noarch.rp  82 kB/s |  24 kB     00:00    
(8/10): mod_http2-1.15.7-2.module_el8.3.0+477+4 164 kB/s | 154 kB     00:00    
(9/10): mailcap-2.1.48-3.el8.noarch.rpm         130 kB/s |  39 kB     00:00    
(10/10): httpd-2.4.37-30.module_el8.3.0+561+97f 276 kB/s | 1.7 MB     00:06    
--------------------------------------------------------------------------------
Total                                           297 kB/s | 2.3 MB     00:07     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1 
  Installing       : apr-1.6.3-11.el8.x86_64                               1/10 
  Running scriptlet: apr-1.6.3-11.el8.x86_64                               1/10 
  Installing       : apr-util-bdb-1.6.1-6.el8.x86_64                       2/10 
  Installing       : apr-util-openssl-1.6.1-6.el8.x86_64                   3/10 
  Installing       : apr-util-1.6.1-6.el8.x86_64                           4/10 
  Running scriptlet: apr-util-1.6.1-6.el8.x86_64                           4/10 
  Installing       : httpd-tools-2.4.37-30.module_el8.3.0+561+97fdbbcc.    5/10 
  Installing       : mailcap-2.1.48-3.el8.noarch                           6/10 
  Installing       : centos-logos-httpd-80.5-2.el8.noarch                  7/10 
  Running scriptlet: httpd-filesystem-2.4.37-30.module_el8.3.0+561+97fd    8/10 
  Installing       : httpd-filesystem-2.4.37-30.module_el8.3.0+561+97fd    8/10 
  Installing       : mod_http2-1.15.7-2.module_el8.3.0+477+498bb568.x86    9/10 
  Installing       : httpd-2.4.37-30.module_el8.3.0+561+97fdbbcc.x86_64   10/10 
  Running scriptlet: httpd-2.4.37-30.module_el8.3.0+561+97fdbbcc.x86_64   10/10 
  Verifying        : apr-1.6.3-11.el8.x86_64                               1/10 
  Verifying        : apr-util-1.6.1-6.el8.x86_64                           2/10 
  Verifying        : apr-util-bdb-1.6.1-6.el8.x86_64                       3/10 
  Verifying        : apr-util-openssl-1.6.1-6.el8.x86_64                   4/10 
  Verifying        : httpd-2.4.37-30.module_el8.3.0+561+97fdbbcc.x86_64    5/10 
  Verifying        : httpd-filesystem-2.4.37-30.module_el8.3.0+561+97fd    6/10 
  Verifying        : httpd-tools-2.4.37-30.module_el8.3.0+561+97fdbbcc.    7/10 
  Verifying        : mod_http2-1.15.7-2.module_el8.3.0+477+498bb568.x86    8/10 
  Verifying        : centos-logos-httpd-80.5-2.el8.noarch                  9/10 
  Verifying        : mailcap-2.1.48-3.el8.noarch                          10/10 

Installed:
  apr-1.6.3-11.el8.x86_64                                                       
  apr-util-1.6.1-6.el8.x86_64                                                   
  apr-util-bdb-1.6.1-6.el8.x86_64                                               
  apr-util-openssl-1.6.1-6.el8.x86_64                                           
  centos-logos-httpd-80.5-2.el8.noarch                                          
  httpd-2.4.37-30.module_el8.3.0+561+97fdbbcc.x86_64                            
  httpd-filesystem-2.4.37-30.module_el8.3.0+561+97fdbbcc.noarch                 
  httpd-tools-2.4.37-30.module_el8.3.0+561+97fdbbcc.x86_64                      
  mailcap-2.1.48-3.el8.noarch                                                   
  mod_http2-1.15.7-2.module_el8.3.0+477+498bb568.x86_64                         

Complete!
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
[root@public ~]# semange fcontext -a -e /var/www /crypted/www
-bash: semange: command not found
[root@public ~]# semanage fcontext -a -e /var/www /crypted/www
[root@public ~]# touch /.autorelabel
[root@public ~]# reboot
Connection to 192.168.254.250 closed by remote host.
Connection to 192.168.254.250 closed.
user@debian:~$ ssh root@192.168.254.250
root@192.168.254.250's password: 
Last login: Sat Apr  3 18:41:23 2021 from 192.168.254.1
[root@public ~]# ls -lZ /crypted/
total 24
drwxr-xr-x. 2 root root unconfined_u:object_r:home_root_t:s0          4096 Apr  3 18:45 home
drwx------. 2 root root system_u:object_r:default_t:s0               16384 Apr  3 18:37 lost+found
drwxr-xr-x. 4 root root unconfined_u:object_r:httpd_sys_content_t:s0  4096 Apr  3 18:48 www
[root@public ~]# ls -lZ /crypted/www/
total 8
drwxr-xr-x. 2 root root unconfined_u:object_r:httpd_sys_script_exec_t:s0 4096 Apr  3 18:48 cgi-bin
drwxr-xr-x. 2 root root unconfined_u:object_r:httpd_sys_content_t:s0     4096 Apr  3 18:48 html
[root@public ~]# 
