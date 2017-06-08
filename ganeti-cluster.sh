#!/bin/bash -xe

gnt-cluster init --no-ssh-init --enabled-disk-templates=plain,diskless --enabled-hypervisors=kvm cluster1
exit
gnt-cluster modify -H kvm:kernel_path=''
gnt-cluster modify -H kvm:kernel_path='/boot/vmlinuz-4.8.0-52-generic',initrd_path='/boot/initrd.img-4.8.0-52-generic'

wget https://github.com/grnet/ganeti-os-noop/archive/master.zip
unzip master.zip
cp -rv ganeti-os-noop-master/ganeti/os/noop /srv/ganeti/os/
gnt-instance add --no-name-check --no-ip-check -t plain -o debootstrap+zesty --disk 0:size=10G -n nic-OptiPlex-7010 -B minmem=1024,maxmem=2048 -H kvm:spice_bind=127.0.0.1 -ddd instance1
gnt-instance remove instance1

# these are defaults which can be overriddedn on the command line
gnt-cluster modify -B maxmem=8192
gnt-cluster modify -B minmem=1024
gnt-cluster modify --ipolicy-std-specs=cpu-count=1,disk-count=1,disk-size=1024,memory-size=1024,nic-count=1,spindle-use=1
gnt-cluster modify --ipolicy-bounds-specs=min:cpu-count=1,disk-count=1,disk-size=1024,memory-size=1024,nic-count=1,spindle-use=1/max:cpu-count=8,disk-count=16,disk-size=1048576,memory-size=65536,nic-count=8,spindle-use=12


# RHEL image creation
IMG=rhel-guest-image-7.3-35.x86_64.qcow2
IMGNAME=rhel
lvcreate --yes -L 10737418240B -n tmp xenvg
qemu-img convert -O raw $IMG $(lvs --noheadings -o lv_path xenvg/tmp)
gnt-instance add --no-name-check --no-ip-check -t plain -o noop --disk 0:adopt=tmp -n nic-OptiPlex-7010 -B minmem=1024,maxmem=2048 -H kvm:kernel_path=,initrd_path= $IMGNAME
gnt-instance console $IMGNAME
gnt-instance remove -f $IMGNAME

# Fedora image creation
IMG=Fedora-Cloud-Base-25-1.3.x86_64.raw.xz
IMGNAME=fedora
lvcreate --yes -L $(unxz -c $IMG | wc -c)B -n tmp xenvg
unxz -c $IMG > $(lvs --noheadings -o lv_path xenvg/tmp)
gnt-instance add --no-name-check --no-ip-check -t plain -o noop --disk 0:adopt=tmp -n nic-OptiPlex-7010 -B minmem=1024,maxmem=2048 -H kvm:kernel_path=,initrd_path= $IMGNAME
gnt-instance console $IMGNAME
gnt-instance remove -f $IMGNAME

CentOS-7-x86_64-GenericCloud-1611.qcow2.xz
