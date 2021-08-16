# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :otuslinux => {
    :box_name => "centos/7",
    :ip_addr => '192.168.11.101',
	:disks => {
		:sata1 => {
			:dfile => './sata1.vdi',
			:size => 40960,
			:port => 1,
            :variant => 'Standard'
		},
		:sata2 => {
            :dfile => './sata2.vdi',
            :size => 250, # Megabytes
			:port => 2,
            :variant => 'Fixed'
		},
        :sata3 => {
            :dfile => './sata3.vdi',
            :size => 250,
            :port => 3,
            :variant => 'Fixed'
        },
        :sata4 => {
            :dfile => './sata4.vdi',
            :size => 250, # Megabytes
            :port => 4,
            :variant => 'Fixed'
        },
        :sata5 => {
            :dfile => './sata5.vdi',
            :size => 250, # Megabytes
            :port => 5,
            :variant => 'Fixed'
        },
        :sata6 => {
            :dfile => './sata6.vdi',
            :size => 250, # Megabytes
            :port => 6,
            :variant => 'Fixed'
        }

	}		
  },
}

Vagrant.configure("2") do |config|
    MACHINES.each do |boxname, boxconfig|
        config.vm.define boxname do |box|
            box.vm.box = boxconfig[:box_name]
            box.vm.host_name = boxname.to_s
            #box.vm.network "forwarded_port", guest: 3260, host: 3260+offset
            box.vm.network "private_network", ip: boxconfig[:ip_addr]
            box.vm.provider :virtualbox do |vb|
                vb.customize ["modifyvm", :id, "--memory", "1024"]
                needsController = false
                boxconfig[:disks].each do |dname, dconf|
                    unless File.exist?(dconf[:dfile])
                        vb.customize ['createmedium', '--filename', dconf[:dfile], '--variant', dconf[:variant], '--size', dconf[:size]]
                        needsController =  true
                    end
                end
                if needsController == true
                    vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                    boxconfig[:disks].each do |dname, dconf|
                        vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                    end
                end
            end
 	        box.vm.provision "shell", inline: <<-SHELL
	            mkdir -p ~root/.ssh
                cp ~vagrant/.ssh/auth* ~root/.ssh
	            yum install -y mdadm smartmontools hdparm gdisk
                sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/#g' /etc/ssh/sshd_config
                systemctl restart sshd
  	        SHELL
        end
    end
end
