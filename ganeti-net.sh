#!/bin/bash -xe
XENPV=/dev/vdb
GNTDEV=ens10
# setting up the ganeti host network
# this requires a bridge - xen-br0 - bound to a physical interface
# in the case that there is a dedicated interface available the process is simpler, especially for remote implementation...

# the following will do the job dynamically, however it will not persist the configuration....
vgcreate xenvg $XENPV
ip li set down dev $GNTDEV
brctl addbr xen-br0
brctl addif xen-br0 $GNTDEV
ip li set up dev xen-br0
ip li set up dev $GNTDEV


cat << EOF > /etc/sysconfig/network-scripts/ifcfg-xen-br0
DEVICE=xen-br0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=none
NM_CONTROLLED=no
DELAY=0
EOF

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-${GNTDEV}
NAME=$GNTDEV
DEVICE=$GNTDEV
ONBOOT=yes
IPV6INIT=no
BOOTPROTO=none
TYPE=Ethernet
NM_CONTROLLED=no
BRIDGE=xen-br0
EOF
