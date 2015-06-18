# Vagrant machine on Openstack with the latest version of mininet

Provision a VM on Openstack with ansible following 

## Requirements

* Vagrant Openstack provider
* Ansible

## Usage with opendaylight and dlux web UI

You can login with 

$vagrant ssh 

then

$ sudo mn --controller=remote,ip=<@ip_your_odl_controller> --topo tree,3

and then browse  http://<@publicIp_your_odl_controller>:8181/dlux/index.html 

to see that: https://wiki.opendaylight.org/view/OpenDaylight_dlux:yangUI-user
