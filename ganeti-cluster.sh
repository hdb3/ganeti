#!/bin/bash -xe

gnt-cluster init --enabled-disk-templates=plain,diskless --enabled-hypervisors=kvm -H kvm:kernel_path='/boot/vmlinuz-ganeti',initrd_path='/boot/initrd-ganeti.img \
    --ipolicy-std-specs=cpu-count=1,disk-count=1,disk-size=1024,memory-size=1024,nic-count=1,spindle-use=1 \
    --ipolicy-bounds-specs=min:cpu-count=1,disk-count=1,disk-size=10,memory-size=64,nic-count=1,spindle-use=1/max:cpu-count=8,disk-count=16,disk-size=1048576,memory-size=65536,nic-count=8,spindle-use=12 \
    cluster1

##gnt-cluster init --no-ssh-init --enabled-disk-templates=plain,diskless --enabled-hypervisors=kvm -H kvm:kernel_path='/boot/vmlinuz-ganeti',initrd_path='/boot/initrd-ganeti.img \
##    --ipolicy-std-specs=cpu-count=1,disk-count=1,disk-size=1024,memory-size=1024,nic-count=1,spindle-use=1 \
##    --ipolicy-bounds-specs=min:cpu-count=1,disk-count=1,disk-size=1024,memory-size=1024,nic-count=1,spindle-use=1/max:cpu-count=8,disk-count=16,disk-size=1048576,memory-size=65536,nic-count=8,spindle-use=12 \
##    cluster1
#gnt-cluster modify -H kvm:kernel_path='/boot/vmlinuz-ganeti',initrd_path='/boot/initrd-ganeti.img'
#gnt-cluster modify -H kvm:kernel_path=''
#gnt-cluster modify -H kvm:kernel_path='/boot/vmlinuz-4.8.0-52-generic',initrd_path='/boot/initrd.img-4.8.0-52-generic'

# these are defaults which can be overriddedn on the command line
#gnt-cluster modify -B maxmem=8192
#gnt-cluster modify -B minmem=1024
#gnt-cluster modify --ipolicy-std-specs=cpu-count=1,disk-count=1,disk-size=1024,memory-size=1024,nic-count=1,spindle-use=1
#gnt-cluster modify --ipolicy-bounds-specs=min:cpu-count=1,disk-count=1,disk-size=1024,memory-size=1024,nic-count=1,spindle-use=1/max:cpu-count=8,disk-count=16,disk-size=1048576,memory-size=65536,nic-count=8,spindle-use=12
