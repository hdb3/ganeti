#!/bin/bash -xe
# first install (non-haskell) prerequisites

if which yum
  then echo "RPM"
    yum install -y epel-release gmp-devel wget
    yum groupinstall -y "Development Tools"
    yum install -y zlib-devel pcre-devel libcurl-devel socat python2-bitarray python-ipaddr pyOpenSSL pyparsing python-simplejson python-inotify bridge-utils qemu-kvm qemu-kvm-tools qemu-system-x86
    yum install -y python-pip ; pip install PyYAML
  else echo "DEB"
    apt install libghc-cabal-dev cabal-install
fi

# cd
# rm -rf .ghc/ .cabal/
# mkdir bin
# mkdir .cabal
# ln -s ~/bin .cabal
# wget -O - https://www.haskell.org/platform/download/8.0.2/haskell-platform-8.0.2-unknown-posix--full-x86_64.tar.gz | tar zxfv -
wget -O - http://10.30.65.200/haskell-platform-7.10.3-unknown-posix-x86_64.tar.gz | tar zxfv - || wget -O - https://www.haskell.org/platform/download/7.10.3/haskell-platform-7.10.3-unknown-posix-x86_64.tar.gz | tar zxfv -
./install-haskell-platform.sh
rm -f hp-usr-local.tar.gz  install-haskell-platform.sh
cabal update
curl  http://downloads.ganeti.org/releases/2.17/ganeti-2.17.0~beta1.tar.gz | tar xzf -
cd ganeti-2.17.0~beta1
cabal install --only-dependencies cabal/ganeti.template.cabal --flags="confd mond metad"
# cabal install --force-reinstalls --only-dependencies cabal/ganeti.template.cabal --flags="confd mond metad"
./configure --exec-prefix=/usr --prefix=/usr --localstatedir=/var --sysconfdir=/etc --enable-symlinks
make
make install
cp doc/examples/systemd/*target doc/examples/systemd/*service /lib/systemd/system
systemctl enable ganeti-confd ganeti-luxid ganeti-maintd ganeti-metad ganeti-mond ganeti-noded ganeti-rapi ganeti-wconfd
systemctl status ganeti-metad ganeti-wconfd ganeti-luxid ganeti-confd ganeti-maintd ganeti-noded ganeti-rapi ganeti-mond
vgcreate xenvg /dev/cda1
brctl addbr xen-br0
brctl addif xen-br0 em2
mkdir /srv/ganeti /srv/ganeti/os /srv/ganeti/export
gnt-cluster init --enabled-disk-templates=plain,diskless --enabled-hypervisors=kvm ganeti
gnt-cluster modify -H kvm:kernel_path=''
gnt-cluster modify -H kvm:kernel_path='/boot/vmlinuz-4.8.0-52-generic',initrd_path='/boot/initrd.img-4.8.0-52-generic'

yum install -y dump debootstrap dpkg
wget -O - http://http.debian.net/debian/pool/main/g/ganeti-instance-debootstrap/ganeti-instance-debootstrap_0.16.orig.tar.gz| tar zxfv -
cd ganeti-instance-debootstrap-0.16/
./autogen.sh 
./configure --with-os-dir=/srv/ganeti/os
make
make install
cd

wget https://github.com/grnet/ganeti-os-noop/archive/master.zip
unzip master.zip
cp -rv ganeti-os-noop-master/ganeti/os/noop /srv/ganeti/os/
gnt-instance add -t plain -o debootstrap+zesty --disk 0:size=10G -n nic-OptiPlex-7010 -B minmem=1024,maxmem=2048 -H kvm:spice_bind=127.0.0.1 -ddd instance1
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
