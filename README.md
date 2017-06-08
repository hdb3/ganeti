# ganetiganeti-cluster.sh
ganeti-net.sh
ganeti-node.sh
ganeti-os.sh
ganeti-inst.sh

Scripts for installing ganetti
'ganeti-node.sh' installs/builds binaries.  Needed on all nodes.
'ganeti-net.sh' configures infrastructure (network and disk). Needed on all nodes. Likely will require customisation.
'ganeti-os.sh' installs os-instances (debootstrap, noop), needed to actuall create instances. Needed on all nodes.
'ganeti-cluster.sh' initialises a cluster.  Should only be run on the master node.  After running, add other nodes as required.
'ganeti-inst.sh' creates instances of various distros. Should only be run on the master node.
