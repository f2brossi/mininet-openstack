require 'vagrant-openstack-provider'

Vagrant.configure("2") do |config|

  config.vm.box = "openstack"
  config.vm.box_url = "https://github.com/ggiamarchi/vagrant-openstack/raw/master/source/dummy.box"

  config.ssh.shell = "bash"
  config.ssh.username = "stack"
  #config.ssh.private_key_path = ENV['OS_KEYPAIR_PRIVATE_KEY']

  config.vm.provider :openstack do |os|
    os.username = ENV['OS_USERNAME']
    os.password = ENV['OS_PASSWORD']
    os.tenant_name = ENV['OS_TENANT_NAME']
    os.openstack_auth_url = ENV['OS_AUTH_URL']
    os.openstack_compute_url = ENV['OS_COMPUTE_URL']
    os.openstack_network_url = ENV['OS_NETWORK_URL']    
    #os.keypair_name = ENV['OS_KEYPAIR_NAME']
  end

  config.vm.define 'test' do |test|
    test.vm.provider :openstack do |os|
      os.server_name = "mininet"
      os.floating_ip = ENV['OS_FLOATING_IP2']
      os.flavor = ENV['OS_FLAVOR']
      os.image = ENV['OS_IMAGE']
      os.networks = [ENV['OS_NETWORK']]              
      # os.networks = [
      #  {
      #    id: '4d977b28-b96e-48a7-b651-ef7aaed70ca7',
      #    address: '192.168.10.76'
      #  }]
   end
  end

  # Install ansible  
  config.vm.provision "shell", path: "installAnsibleOnUbuntu.sh", privileged: "true"

  # update /etc/hosts
  #config.vm.provision "shell", path: "hosts.sh", privileged: "true"

  # provision and deployment with ansible
  config.vm.provision :ansible do |ansible|
      ansible.playbook = "playbook.yml"
      ansible.verbose = "vv"
      ansible.limit = 'all'
      ansible.sudo = true 
  end
end
