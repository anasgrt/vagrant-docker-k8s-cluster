FROM ubuntu:24.04

# Update package lists and install necessary packages including curl, openssh-server, sudo
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl

# Create the vagrant user and set up sudo access
RUN useradd -m -s /bin/bash vagrant && \
    echo "vagrant ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/vagrant/.ssh && \
    chmod 700 /home/vagrant/.ssh

# Add Vagrant's insecure public key to the authorized_keys for the vagrant user
RUN curl -fsSL https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub \
    -o /home/vagrant/.ssh/authorized_keys && \
    chmod 600 /home/vagrant/.ssh/authorized_keys && \
    chown -R vagrant:vagrant /home/vagrant/.ssh

# Set up SSH server configurations
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

EXPOSE 22

# Start SSH in the foreground
CMD ["/usr/sbin/sshd", "-D"]