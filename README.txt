[root@public ~]# mdadm --create /dev/md0 --level 5 --raid-disks 3 /dev/sd[b-d]
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
[root@public ~]# watch cat /proc/mdstat
[root@public ~]# pvcreate /dev/md0
  Physical volume "/dev/md0" successfully created.
[root@public ~]# pvdisplay /dev/md0
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
   
[root@public ~]# vgcreate lvmraidvg /dev/md0
  Volume group "lvmraidvg" successfully created
[root@public ~]# vgdisplay lvmraidvg
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
   
[root@public ~]# lvcreate -n lvmraidlv -l 50%VG lvmraidvg
  Logical volume "lvmraidlv" created.
[root@public ~]# lvdisplay /dev/lvmraidvg/lvmraidlv 
  --- Logical volume ---
  LV Path                /dev/lvmraidvg/lvmraidlv
  LV Name                lvmraidlv
  VG Name                lvmraidvg
  LV UUID                EMZJLD-v3P4-5wJo-TqB2-tOQv-1SuQ-80Ixka
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2021-04-08 21:35:08 +0100
  LV Status              available
  # open                 0
  LV Size                <7.99 GiB
  Current LE             2045
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2
