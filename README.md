**[root@public ~]# mdadm --create /dev/md0 --level 5 --raid-disks 3 /dev/sd[b-d]**  
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
mdadm: array /dev/md0 started.  
**[root@public ~]# watch cat /proc/mdstat**  
**[root@public ~]# pvcreate /dev/md0**  
  Physical volume "/dev/md0" successfully created.  
**[root@public ~]# pvdisplay /dev/md0**  
  "/dev/md0" is a new physical volume of "15.98 GiB"  
  --- NEW Physical volume ---  
  PV Name               /dev/md0  
  VG Name                 
  PV Size               15.98 GiB  
  Allocatable           NO  
  PE Size               0     
  Total PE              0  
  Free PE               0  
  Allocated PE          0  
  PV UUID               QsHJGB-hDEE-8nAT-XiS7-IItH-8Je1-kVuYgx  
     
**[root@public ~]# vgcreate lvmraidvg /dev/md0**  
  Volume group "lvmraidvg" successfully created  
**[root@public ~]# vgdisplay lvmraidvg**  
  --- Volume group ---  
  VG Name               lvmraidvg  
  System ID               
  Format                lvm2  
  Metadata Areas        1  
  Metadata Sequence No  1  
  VG Access             read/write  
  VG Status             resizable  
  MAX LV                0  
  Cur LV                0  
  Open LV               0  
  Max PV                0  
  Cur PV                1  
  Act PV                1  
  VG Size               15.98 GiB  
  PE Size               4.00 MiB  
  Total PE              4091  
  Alloc PE / Size       0 / 0     
  Free  PE / Size       4091 / 15.98 GiB  
  VG UUID               pYWf2Y-5j3b-pKlW-LaCL-mr36-KBBv-TWi3jN  
     
**[root@public ~]# lvcreate -n lvmraidlv -l 50%VG lvmraidvg**  
  Logical volume "lvmraidlv" created.  
**[root@public ~]# lvdisplay /dev/lvmraidvg/lvmraidlv**   
  --- Logical volume ---  
  LV Path                /dev/lvmraidvg/lvmraidlv  
  LV Name                lvmraidlv  
  VG Name                lvmraidvg  
  LV UUID                EMZJLD-v3P4-5wJo-TqB2-tOQv-1SuQ-80Ixka  
  LV Write Access        read/write  
  LV Creation host, time localhost.localdomain, 2021-04-08 21:35:08 +0100  
  LV Status              available  
  \# open                 0  
  LV Size                <7.99 GiB  
  Current LE             2045  
  Segments               1  
  Allocation             inherit  
  Read ahead sectors     auto  
  - currently set to     8192  
  Block device           253:2  

**[root@public ~]# dd if=/dev/urandom of=/boot/keyfile bs=1K count=1**  
1+0 records in  
1+0 records out  
1024 bytes (1.0 kB, 1.0 KiB) copied, 0.000336448 s, 3.0 MB/s  
**[root@public ~]# chmod 400 /boot/keyfile**  
[root@public ~]# cryptsetup luksFormat /dev/lvmraidvg/lvmraidlv  

WARNING!  
========  
This will overwrite data on /dev/lvmraidvg/lvmraidlv irrevocably.  

Are you sure? (Type 'yes' in capital letters): YES  
Enter passphrase for /dev/lvmraidvg/lvmraidlv:   
Verify passphrase:   
**[root@public ~]# cryptsetup luksOpen /dev/lvmraidvg/lvmraidlv cryptedpart**  
Enter passphrase for /dev/lvmraidvg/lvmraidlv:   
**[root@public ~]# cryptsetup luksAddKey /dev/lvmraidvg/lvmraidlv /boot/keyfile**   
Enter any existing passphrase:  
**[root@public ~]# vi /etc/crypttab**  
**[root@public ~]# cat /etc/crypttab**   
cryptedpart /dev/lvmraidvg/lvmraidlv /boot/keyfile  
**[root@public ~]# mkfs.ext4 /dev/mapper/cryptedpart**   
mke2fs 1.45.6 (20-Mar-2020)  
Creating filesystem with 2089984 4k blocks and 523264 inodes  
Filesystem UUID: b42b22ff-f0bb-4ef2-8290-35e0c66fb8f7  
Superblock backups stored on blocks:   
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632  

Allocating group tables: done                              
Writing inode tables: done                              
Creating journal (16384 blocks): done  
Writing superblocks and filesystem accounting information: done   

**[root@public ~]# mkdir /secured**  
**[root@public ~]# vi /etc/fstab**  
**[root@public ~]# cat /etc/fstab**   

\#  
\# /etc/fstab  
\# Created by anaconda on Thu Oct 10 19:59:02 2019  
\#  
\# Accessible filesystems, by reference, are maintained under '/dev/disk/'.  
\# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.  
\#  
\# After editing this file, run 'systemctl daemon-reload' to update systemd  
\# units generated from this file.  
\#  
/dev/mapper/cl-root     /                       xfs     defaults        0 0  
UUID=de5581b0-03a4-4e5d-9d5c-ea380355dbde /boot                   ext4    defaults        1 2  
/dev/mapper/cl-swap     swap                    swap    defaults        0 0  
/dev/mapper/cryptedpart /secured                ext4    defaults,usrquota,grpquota        0 0  
**[root@public ~]# mount -a**  
**[root@public ~]# ls -l /secured/**  
total 16  
drwx------. 2 root root 16384 Apr  9 03:02 lost+found  
**[root@localhost ~]#**   
