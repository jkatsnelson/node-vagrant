# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.
  config.vm.hostname = "local.project.monsoon.com"

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "opscode-centos-6.3"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.3_chef-11.2.0.box"

  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  config.vm.network :private_network, ip: "192.168.33.9"

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  # Assign this VM to a bridged network, allowing you to connect directly to a
  # network using the host's network device. This makes the VM appear as another
  # physical device on your network.
  # config.vm.network :bridged

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.network :forwarded_port, guest: 80, host: 4567
  # For debugging Node server
  config.vm.network :forwarded_port, guest: 8081, host: 4568

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder
  config.vm.synced_folder ".", "/var/www/project"
  config.vm.synced_folder "public", "/var/www/project/public"
  config.vm.synced_folder "private", "/var/www/project/private"

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  app_root = "/var/www/project"

  config.vm.provision :chef_solo do |chef|
    # You may also specify custom JSON attributes:
    chef.json = {
      :app_root => app_root,
      :app => {
        :port => 8079,
        :environment => "development",
        :domain => config.vm.hostname
      },
      :nodejs => {
        :version => "0.8.20"
      }
    }

    chef.run_list = [
      "recipe[minitest-handler::default]",
      "recipe[node-server::default]"
    ]
  end

  config.vm.provision :shell do |shell|
    shell.inline = "sudo mount -t vboxsf -o uid=`id -u apache`,gid=`getent group www-data | cut -d: -f3` /var/www/project/app /var/www/project/app"
    shell.inline = "sudo mount -t vboxsf -o uid=`id -u node`,gid=`getent group www-data | cut -d: -f3` /var/www/project/server /var/www/project/server"
  end
end
