# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "trusty64"
  config.ssh.insert_key = false

  # config.vm.network "forwarded_port", guest: 80, host: 8080

  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.provider :libvirt do |vb|
     vb.memory = "4096"
   end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.verbose = "vvv"
    ansible.limit = 'all'
    ansible.sudo = true
    ansible.extra_vars = {
    	ansible_ssh_user: 'vagrant',
    }
  end

end
