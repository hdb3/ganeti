#!/bin/bash -xe

create_debian () {
  gnt-instance add --no-name-check --no-ip-check -t plain -o debootstrap+default --disk 0:size=10G -n `hostname` -B minmem=1024,maxmem=2048 -H kvm:spice_bind=127.0.0.1 debian
  gnt-instance console debian
  gnt-instance remove -f debian
}

# raw image creation

create_from_xz () {
  local IMG=$1
  local IMGNAME=$2
  local IMGSIZE=$(unxz -c $IMG | wc -c)
  if [[ ! -f $IMG ]] ; then wget http://dell0/${IMG} ; fi
  echo "the image size is $IMGSIZE bytes"
  lvcreate --yes -L ${IMGSIZE}B -n tmp xenvg
  unxz -c $IMG > $(lvs --noheadings -o lv_path xenvg/tmp)
  gnt-instance add --no-name-check --no-ip-check -t plain -o noop --disk 0:adopt=tmp -n $(hostname) -B minmem=1024,maxmem=2048 -H kvm:kernel_path=,initrd_path= $IMGNAME
}

create_fedora () {
  IMG=Fedora-Cloud-Base-25-1.3.x86_64.raw.xz
  IMGNAME=fedora
  create_from_xz $IMG $NAME
  gnt-instance console $IMGNAME
  gnt-instance remove -f $IMGNAME
}

# qcow2 image creation

qcow_img_size () {
  qemu-img info --output=json $1 | gawk '/virtual-size/ {print gensub(/([^0-9])/,"","g",$2)}'
}

create_from_qcow2 () {
  local IMG=$1
  local IMGNAME=$2
  local IMGSIZE=$(qcow_img_size $IMG)
  if [[ ! -f $IMG ]] ; then wget http://dell0/${IMG} ; fi
  echo "the image size is $IMGSIZE bytes"
  lvcreate --yes -L ${IMGSIZE}B -n tmp xenvg
  qemu-img convert -O raw $IMG $(lvs --noheadings -o lv_path xenvg/tmp)
  gnt-instance add --no-name-check --no-ip-check -t plain -o noop --disk 0:adopt=tmp -n $(hostname) -B minmem=1024,maxmem=2048 -H kvm:kernel_path=,initrd_path= $IMGNAME
}

create_cirros () {
  IMG=cirros-0.3.5-x86_64-disk.img
  NAME=cirros
  if [[ ! -f $IMG ]] ; then wget https://download.cirros-cloud.net/0.3.5/${IMG} ; fi
  create_from_qcow2 $IMG $NAME
  gnt-instance console $NAME
  gnt-instance remove -f $NAME
}

create_centos () {
  IMG=CentOS-7-x86_64-GenericCloud-1511.qcow2
  NAME=centos
  if [[ ! -f $IMG ]] ; then wget -O - http://cloud.centos.org/centos/7/images/${IMG}.xz | xzcat - ; fi
  create_from_qcow2 $IMG $NAME
  gnt-instance console $NAME
  gnt-instance remove -f $NAME
}

create_rhel () {
  IMG=rhel-guest-image-7.3-35.x86_64.qcow2
  NAME=rhel
  create_from_qcow2 $IMG $NAME
  gnt-instance console $NAME
  gnt-instance remove -f $NAME
}

create_cirros
create_debian
create_fedora
create_centos
create_rhel
