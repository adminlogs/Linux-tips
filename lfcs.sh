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
[root@public ~]# mkdir /crypted/smbshare
[root@public ~]# semanage fcontext -a -t samba_share_t '/crypted/smbshare(/.*)?'
[root@public ~]# restorecon -vR /crypted/smbshare/
Relabeled /crypted/smbshare from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:samba_share_t:s0
[root@public ~]# pdbedit -a axel
[root@public ~]# pdbedit -a azel
[root@public ~]# setfacl -m g:engineers:rwx /crypted/smbshare 
[root@public ~]# vi /etc/samba/smb.conf
[root@public ~]# testparm
Load smb config files from /etc/samba/smb.conf
Loaded services file OK.
Server role: ROLE_STANDALONE

Press enter to see a dump of your service definitions

# Global parameters
[global]
	printcap name = cups
	security = USER
	workgroup = SAMBA
	idmap config * : backend = tdb
	cups options = raw


[homes]
	browseable = No
	comment = Home Directories
	inherit acls = Yes
	read only = No
	valid users = %S %D%w%S


[printers]
	browseable = No
	comment = All Printers
	create mask = 0600
	path = /var/tmp
	printable = Yes


[print$]
	comment = Printer Drivers
	create mask = 0664
	directory mask = 0775
	force group = @printadmin
	path = /var/lib/samba/drivers
	write list = @printadmin root


[smbshare]
	browseable = No
	comment = Samba Share
	directory mask = 0750
	path = /crypted/smbshare
	write list = @engineers
[root@public ~]# firewall-cmd --add-service samba
success
[root@public ~]# firewall-cmd --add-service samba --permanent
success
[root@public ~]# systemctl enable smb
Created symlink /etc/systemd/system/multi-user.target.wants/smb.service → /usr/lib/systemd/system/smb.service.
[root@public ~]# systemctl start smb
[root@public ~]# systemctl enable nmb
Created symlink /etc/systemd/system/multi-user.target.wants/nmb.service → /usr/lib/systemd/system/nmb.service.
[root@public ~]# systemctl start nmb

[root@private ~]# yum install -y samba-client cifs-utils
[root@private ~]# vi /etc/fstab
//192.168.1.13/smbshare /smb cifs credentials=/root/.smbcredentials 0 0
[root@private ~]# vi /root/.smbcredentials
[root@private ~]# cat /root/.smbcredentials
username=axel
password=password

[root@public ~]# quotacheck -mug /crypted/
[root@public ~]# quotaon -v /crypted/
/dev/mapper/cryptedpart [/crypted]: group quotas turned on
/dev/mapper/cryptedpart [/crypted]: user quotas turned on
[root@public ~]# edquota -u axel -f /crypted/
Disk quotas for user axel (uid 10001):
  Filesystem                   blocks       soft       hard     inodes     soft     hard
  /dev/mapper/cryptedpart          28    512000K    520000K          6        0        0
[root@public ~]# repquota -u /crypted
*** Report for user quotas on device /dev/mapper/cryptedpart
Block grace time: 7days; Inode grace time: 7days
                        Block limits                File limits
User            used    soft    hard  grace    used  soft  hard  grace
----------------------------------------------------------------------
root      --      44       0       0              7     0     0       
axel      --      28  512000  520000              6     0     0       
azel      --      76       0       0              7     0     0       
abel      --      20       0       0              5     0     0       
akel      --      20       0       0              5     0     0
[root@public ~]# nmcli connection add con-name enp0s9 ifname enp0s9 type ethernet autoconnect yes method auto
[root@public ~]# ip a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:40:b6:4b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.13/24 brd 192.168.1.255 scope global dynamic noprefixroute enp0s3
       valid_lft 86179sec preferred_lft 86179sec
    inet6 fd60:e701:ad92:3e00:5624:2386:fbe1:452a/64 scope global dynamic noprefixroute 
       valid_lft 6981sec preferred_lft 3381sec
    inet6 fe80::87a3:5a70:8e73:d147/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:59:53:43 brd ff:ff:ff:ff:ff:ff
    inet 192.168.254.250/24 brd 192.168.254.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe59:5343/64 scope link 
       valid_lft forever preferred_lft forever
4: enp0s9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:eb:23:8e brd ff:ff:ff:ff:ff:ff
    inet 192.168.99.107/24 brd 192.168.99.255 scope global dynamic noprefixroute enp0s9
       valid_lft 1193sec preferred_lft 1193sec
    inet6 fe80::4b19:c5f:cc9b:ef5b/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
[root@public ~]# nmcli connection show
NAME    UUID                                  TYPE      DEVICE 
enp0s3  c2fa7ad0-7577-4322-9867-af0cb132b081  ethernet  enp0s3 
enp0s8  a966fd7f-34d5-49c0-9caf-5b8e71a7d915  ethernet  enp0s8 
enp0s9  94997b79-806d-4a95-83de-e3710e3ae746  ethernet  enp0s9
[root@public ~]# nmcli connection delete enp0s9
Connection 'enp0s9' (94997b79-806d-4a95-83de-e3710e3ae746) successfully deleted.
[root@public ~]# nmcli connection add con-name enp0s9 ifname enp0s9 type ethernet autoconnect yes ip4 192.168.99.250/24
Connection 'enp0s9' (32229589-cf8f-47e5-979e-c846330acf54) successfully added.
[root@public ~]# ip a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:40:b6:4b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.13/24 brd 192.168.1.255 scope global dynamic noprefixroute enp0s3
       valid_lft 85895sec preferred_lft 85895sec
    inet6 fd60:e701:ad92:3e00:5624:2386:fbe1:452a/64 scope global dynamic noprefixroute 
       valid_lft 6697sec preferred_lft 3097sec
    inet6 fe80::87a3:5a70:8e73:d147/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:59:53:43 brd ff:ff:ff:ff:ff:ff
    inet 192.168.254.250/24 brd 192.168.254.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe59:5343/64 scope link 
       valid_lft forever preferred_lft forever
4: enp0s9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:eb:23:8e brd ff:ff:ff:ff:ff:ff
    inet 192.168.99.250/24 brd 192.168.99.255 scope global noprefixroute enp0s9
       valid_lft forever preferred_lft forever
    inet6 fe80::b4a2:303b:4dd3:f86/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
[root@public ~]# nmcli connection show
NAME    UUID                                  TYPE      DEVICE 
enp0s3  c2fa7ad0-7577-4322-9867-af0cb132b081  ethernet  enp0s3 
enp0s8  a966fd7f-34d5-49c0-9caf-5b8e71a7d915  ethernet  enp0s8 
enp0s9  32229589-cf8f-47e5-979e-c846330acf54  ethernet  enp0s9
