# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  
  config.vm.define "jenkins-master" do |master|
    master.vm.box = "ubuntu/focal64"
    master.vm.hostname = "jenkins-master"
    master.vm.network "private_network", ip: "192.168.56.10"
    master.vm.network "forwarded_port", guest: 8080, host: 8080
    master.vm.network "forwarded_port", guest: 50000, host: 50000
    
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
    
    master.vm.provision "shell", inline: <<-SHELL
      
      sudo apt-get update
      
      
      sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io
      
      
      sudo usermod -aG docker vagrant
      
      
      sudo systemctl enable docker
      sudo systemctl start docker
      
      
      sudo apt-get install -y openjdk-11-jdk
      
      
      sudo mkdir -p /var/jenkins_home
      sudo chown 1000:1000 /var/jenkins_home
      
      
      sudo docker run -d \
        --name jenkins \
        --restart unless-stopped \
        -p 8080:8080 \
        -p 50000:50000 \
        -v /var/jenkins_home:/var/jenkins_home \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v $(which docker):/usr/bin/docker \
        --group-add $(getent group docker | cut -d: -f3) \
        jenkins/jenkins:lts
      
      
      echo "Waiting for Jenkins to start..."
      sleep 30
      echo "Jenkins initial admin password:"
      sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
    SHELL
  end

  
  config.vm.define "jenkins-worker" do |worker|
    worker.vm.box = "ubuntu/focal64"
    worker.vm.hostname = "jenkins-worker"
    worker.vm.network "private_network", ip: "192.168.56.11"
    
    worker.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
    
    worker.vm.provision "shell", inline: <<-SHELL
      
      sudo apt-get update
      
      
      sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io
      
      
      sudo usermod -aG docker vagrant
      
      
      sudo systemctl enable docker
      sudo systemctl start docker
      
      
      sudo apt-get install -y openjdk-11-jdk
      
      
      sudo apt-get install -y git
      
      
      sudo useradd -m -s /bin/bash jenkins
      sudo usermod -aG docker jenkins
      
      
      sudo mkdir -p /home/jenkins/agent
      sudo chown jenkins:jenkins /home/jenkins/agent
      
      
      sudo apt-get install -y openssh-server
      sudo systemctl enable ssh
      sudo systemctl start ssh
      
      
      sudo -u jenkins mkdir -p /home/jenkins/.ssh
      sudo -u jenkins chmod 700 /home/jenkins/.ssh
      
      
      sudo -u jenkins ssh-keygen -t rsa -b 2048 -f /home/jenkins/.ssh/id_rsa -N ""
      sudo -u jenkins cp /home/jenkins/.ssh/id_rsa.pub /home/jenkins/.ssh/authorized_keys
      sudo -u jenkins chmod 600 /home/jenkins/.ssh/authorized_keys
      
      echo "Jenkins worker setup completed"
      echo "Private key for Jenkins connection:"
      sudo cat /home/jenkins/.ssh/id_rsa
    SHELL
  end
end
