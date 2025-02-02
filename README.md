# Kubernetes Cluster with Vagrant & Docker

This repository sets up a simple Kubernetes-like cluster using Vagrant with Docker containers as virtual machines. The cluster consists of one control plane (`controlplane`) and two worker nodes (`node01` and `node02`). The configuration is driven by a YAML file and a Vagrantfile.

## Repository Structure

The repository contains the following key files:

- [Vagrantfile](Vagrantfile) – Configures Vagrant to spin up Docker containers, builds the containers from the provided Dockerfile, and provisions them
- [settings.yaml](settings.yaml) – Contains the machine definitions with names, IP addresses, and resource settings
- [Dockerfile](Dockerfile) – Defines the Docker image used for the containers
- `create-docker-network.sh` – Bash script to create a Docker network (`mynet`) with the specified subnet
- `README.md` – This documentation file
- `.vagrant/` – Directory created by Vagrant for state and machine information

## Prerequisites

Before you begin, ensure you have the following installed:

- **Docker** – A running Docker installation
- **Vagrant** – Version 2 or higher
- **Ruby** – Required for Vagrant to process the Vagrantfile

## Setup & Usage

### Creating the Docker Network

Before running Vagrant, execute the network creation script to set up the Docker network, __since By default, the Docker provider for Vagrant doesn’t set up private networks (or assign fixed IP addresses) like VirtualBox does__:

```bash
sh create-docker-network.sh
```

This command creates a Docker network called `mynet` with the subnet `192.168.201.0/24` if it doesn't already exist.

### Spinning Up the Cluster

To build and start the containers, run:

```bash
vagrant up
```

When you run this command, Vagrant:

1. Reads machine definitions from `settings.yaml`
2. Uses the Vagrantfile to provision each Docker container
3. Configures each container with:
   - A specific hostname (`controlplane`, `node01`, or `node02`)
   - An IP address as defined in `settings.yaml`
   - A running SSH service (via the Docker image built from Dockerfile)
   - Required packages and host entries through provisioning

### Accessing the Nodes

To SSH into any container, use the following commands:

```bash
vagrant ssh controlplane
vagrant ssh node01
vagrant ssh node02
```

## Configuration Details

### Vagrantfile

The Vagrantfile dynamically reads machine definitions from `settings.yaml` and provisions each container with:

- System updates
- Package installations
- Host entries

It utilizes the Docker provider and builds containers from the local Dockerfile.

### settings.yaml

This file defines three VMs for your Kubernetes cluster:

- `controlplane` – The cluster control plane
- `node01` and `node02` – Worker nodes with assigned IP addresses

### Dockerfile

The Dockerfile builds an Ubuntu 24.04-based image that:

1. Updates system packages
2. Installs SSH and necessary tools
3. Creates the vagrant user with sudo privileges
4. Sets up the insecure Vagrant key for SSH access

## Troubleshooting

### Docker Network Issues

If containers cannot connect to `mynet`:

- Run `create-docker-network.sh` to ensure the network exists
- Verify network settings in Docker

### Provisioning Errors

If you encounter provisioning issues:

1. Verify the Docker image builds correctly from Dockerfile
2. Check that `settings.yaml` has the correct IP addresses
3. Ensure Docker has sufficient resources

### SSH Issues

If SSH access fails:

1. Confirm the insecure key is properly installed in the Docker image
2. Verify SSH settings in Vagrantfile remain unmodified
3. Check container SSH service status

## Additional Information

- This configuration uses Docker provider for Vagrant
- Resource settings in `settings.yaml` affect container resource controls differently than standard VMs
- ARM-based systems may require multi-architecture Docker images

## Useful Commands

This section provides a comprehensive list of Vagrant commands specifically tailored for managing your Kubernetes cluster setup.

### Basic Cluster Management

Basic commands for controlling the entire cluster and individual nodes:

```bash
# Start the entire cluster
vagrant up

# Start a specific node
vagrant up controlplane
vagrant up node01
vagrant up node02

# Stop the entire cluster
vagrant halt

# Stop a specific node
vagrant halt controlplane

# Restart a node (useful after configuration changes)
vagrant reload controlplane

# Destroy the entire cluster (removes all data)
vagrant destroy -f

# Check status of all nodes
vagrant status
```

### Accessing and Managing Nodes

Commands for interacting with cluster nodes:

```bash
# SSH into nodes
vagrant ssh controlplane
vagrant ssh node01
vagrant ssh node02

# Copy files to nodes (from host to guest)
vagrant upload local_file.txt /destination/path controlplane

# Execute commands directly on nodes
vagrant ssh controlplane -c "hostname && ip addr show"

# View SSH configuration
vagrant ssh-config controlplane
```

### Troubleshooting and Maintenance

Commands useful for debugging and maintaining your cluster:

```bash
# Rebuild a specific node (useful after Dockerfile changes)
vagrant destroy controlplane -f && vagrant up controlplane

# View detailed logs during provisioning
vagrant up --debug

# Validate Vagrantfile syntax
vagrant validate

# Clean up old boxes and unused images
vagrant box prune
```

### Advanced Operations

Commands for more complex management tasks:

```bash
# Apply changes from Vagrantfile without full rebuild
vagrant reload --provision

# Suspend all nodes (save RAM, quick resume)
vagrant suspend

# Resume suspended nodes
vagrant resume

# Generate new SSH configuration
vagrant ssh-config > ssh_config
```

### Docker Provider Commands

Commands specific to the Docker provider integration:

```bash
# Inspect Docker networks
docker network inspect mynet

# List running containers
docker ps --filter "name=vagrant"

# View container logs
docker logs vagrant_controlplane

# Access container directly (alternative to vagrant ssh)
docker exec -it vagrant_controlplane /bin/bash
```

### Environment Variables

Useful environment variables for Vagrant operations:

```bash
# Enable detailed logs
export VAGRANT_LOG=debug

# Disable parallel operations
export VAGRANT_NO_PARALLEL=true

# Custom location for Vagrantfile
export VAGRANT_VAGRANTFILE=custom.vagrantfile
```

### Common Workflow Examples

Here are some practical workflow scenarios you might encounter:

1. **Rebuilding the entire cluster after configuration changes**:

   ```bash
   vagrant destroy -f && vagrant up --provider=docker
   ```

2. **Updating a single node's configuration**:

   ```bash
   vagrant provision node01
   ```

3. **Accessing logs when troubleshooting**:

   ```bash
   vagrant ssh controlplane -c "sudo journalctl -fu kubelet"
   ```

For detailed information about any command, you can use the help flag:

```bash
vagrant --help
vagrant up --help
vagrant ssh --help
```

**Note**: Changes made directly inside containers will be lost upon container destruction. For persistent changes, modify the Dockerfile, Vagrantfile, or provisioning scripts instead.