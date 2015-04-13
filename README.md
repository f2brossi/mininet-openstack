# Vagrant machine with the latest version of mininet

Provision a VM with ansible following 

## Requirements

* Vagrant
** Vagrant plugins: vagrant-libvirt vagrant-mutate
* Ansible
* Libvirt

vagrant box add trusty64 https://vagrant-kvm-boxes-si.s3.amazonaws.com/trusty64-kvm-20140418.box

> If kvm complains about a SATA error you need to edit /usr/bin/kvm and add '-M q35'

```
#! /bin/sh
exec qemu-system-x86_64 -M q35 -enable-kvm "$@"

```

## Usage

You can login with vagrant ssh or use X Forwarding:

`ssh -X -p 2222 -i ~/.vagrant.d/insecure_private_key vagrant@localhost xterm`

