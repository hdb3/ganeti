#!/bin/bash -xe
# first install (non-haskell) prerequisites

if which yum
  then echo "RPM"
    yum install -y epel-release gmp-devel wget
    yum groupinstall -y "Development Tools"
    yum install -y zlib-devel pcre-devel libcurl-devel socat python2-bitarray python-ipaddr pyOpenSSL pyparsing python-simplejson python-inotify bridge-utils qemu-kvm qemu-kvm-tools qemu-system-x86
    yum install -y python-pip ; pip install PyYAML
    cat << EOF > /usr/bin/kvm
#!/bin/sh
exec qemu-system-x86_64 -enable-kvm "$@"
EOF
  else echo "DEB"
    apt install libghc-cabal-dev cabal-install
fi

wget -O - http://10.30.65.200/haskell-platform-7.10.3-unknown-posix-x86_64.tar.gz | tar zxfv - || wget -O - https://www.haskell.org/platform/download/7.10.3/haskell-platform-7.10.3-unknown-posix-x86_64.tar.gz | tar zxfv -
./install-haskell-platform.sh
rm -f hp-usr-local.tar.gz  install-haskell-platform.sh
cabal update
## curl  http://downloads.ganeti.org/releases/2.17/ganeti-2.17.0~beta1.tar.gz | tar xzf - ; cd ganeti-2.17.0~beta1
## curl  http://downloads.ganeti.org/releases/2.15/ganeti-2.15.2.tar.gz | tar xzf - ; cd ganeti-2.15.2
curl  http://downloads.ganeti.org/releases/2.16/ganeti-2.16.0~rc1.tar.gz | tar xzf - ; cd ganeti-2.16.0~rc1
cabal install --only-dependencies cabal/ganeti.template.cabal --flags="confd mond metad"
# cabal install --force-reinstalls --only-dependencies cabal/ganeti.template.cabal --flags="confd mond metad"
./configure --exec-prefix=/usr --prefix=/usr --localstatedir=/var --sysconfdir=/etc --enable-symlinks
make
make install
cp doc/examples/systemd/*target doc/examples/systemd/*service /lib/systemd/system
mkdir /srv/ganeti /srv/ganeti/os /srv/ganeti/export

systemctl enable ganeti-confd ganeti-luxid ganeti-maintd ganeti-metad ganeti-mond ganeti-noded ganeti-rapi ganeti-wconfd
systemctl status ganeti-metad ganeti-wconfd ganeti-luxid ganeti-confd ganeti-maintd ganeti-noded ganeti-rapi ganeti-mond
