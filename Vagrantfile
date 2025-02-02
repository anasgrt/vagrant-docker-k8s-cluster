require 'yaml'
settings = YAML.load_file(File.join(File.dirname(__FILE__), 'settings.yaml'))

Vagrant.configure("2") do |config|
  config.ssh.username = "vagrant"
  config.ssh.insert_key = true

  settings['vm'].each do |vm_config|
    config.vm.define vm_config['name'] do |vm|
      vm.vm.hostname = vm_config['name']
      vm.vm.synced_folder ".", "/vagrant", disabled: false

      vm.vm.provider "docker" do |d|
        d.build_dir = "."
        d.remains_running = true
        d.has_ssh = true
        d.cmd = ["/usr/sbin/sshd", "-D"]
        # Attach the container to the "mynet" network and assign the specified IP.
        d.create_args = ["--network", "mynet", "--ip", vm_config['ip']]
        # Explicitly set the container name to avoid extra numbers.
        d.name = "vagrant_#{vm_config['name']}"
      end

      vm.vm.provision "shell", inline: <<-SHELL
        apt update
        apt upgrade -y
        apt install -y wget vim bash-completion net-tools inetutils-ping iproute2 gcc make tar git unzip sysstat tree curl
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl && mv kubectl /usr/local/bin/kubectl
        kubectl completion bash > /etc/bash_completion.d/kubectl
        echo "192.168.201.10 controlplane" >> /etc/hosts
        echo "192.168.201.11 node01" >> /etc/hosts
        echo "192.168.201.12 node02" >> /etc/hosts
      SHELL
    end
  end
end