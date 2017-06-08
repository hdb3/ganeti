#!/bin/bash -xe
# NOTE: the os-instances must be deployed aon all nodes, otherwise gnt-os list does not find them.  Use gnt-os diagnose to check for this.

if which yum
  then echo "RPM"
    yum install -y dump debootstrap dpkg
  else echo "DEB"
    :
fi

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
