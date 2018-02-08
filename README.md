# TechWiseTV NetDevOps Webinar

Code, setup and info for the TechWise TV Webinar on February 14, 2018

# Webinar Setup

## Pre-reqs

### DevNet Sandbox
Reserve the [Open NX-OS with Nexus 9Kv](https://devnetsandbox.cisco.com/RM/Diagram/Index/1e9b57ff-9e64-4c68-93e5-f0f0a8c6f22c?diagramType=Topology) Sandbox.  

***Note:  While this demo could run on an OS X, Linux, or Windows environment, the setup instructions are for an OS X environment.  You will need to adjust for other platforms.***

### Local Workstation Setup
You will need the following installed and working on your local workstation to complete this demo.  

* Python 3.6
* Vagrant and VirtualBox
* Cisco AnyConnect or OpenConnect
* Homebrew

## Setup Steps

1. Clone down the code repository.

```bash
git clone https://github.com/hpreston/twtv_netdevops_webinar
cd twtv_netdevops_webinar
```

1. Create and activate a Python Virtual Environment. Install Python requirements.  

```bash
virtualenv venv --python=python3.6
source venv/bin/activate
pip install -r requirements.txt
```

1. Connect to the Sandbox VPN.  

1. Run the `demo_setup.sh` script.

```bash
source demo_setup.sh
```

# Demo 1: Vagrant
***Note1: This demo uses a lot of local memory (8GB).  Be sure to close all unneeded programs.***

***Note2: This demo assumes that you have already created the box for nxos/7.0.3.I7.2.  If you lack it, skip to the end of this demo to create the box.***

1. Explore different Vagrant commands.  

```bash
vagrant status
vagrant global-status
vagrant box list
```

1. Bring `up` the vagrant environment. Will take some time to complete.  

```bash
vagrant up

# Due to bug in the NX-OS Box, will get errors and
# need to re-run vagrant up 2 additional times
vagrant up

# After 2nd error
vagrant up
```

1. Connect to NX-OS Devices and enable NX-API and set hostnames.  

```bash
vagrant ssh nxos1

# at NX-OS Prompt
conf t
hostname nxos1
feature nxapi
exit
exit

# at terminal prompt
vagrant ssh nxos2

# at NX-OS Prompt
conf t
hostname nxos2
feature nxapi
exit
exit
```

1. Open up the Developer Sandbox for each switch to explore NX-API CLI.  

```bash
open http://vagrant:vagrant@127.0.0.1:3180 -a /Applications/Google\ Chrome.app
open http://vagrant:vagrant@127.0.0.1:3280 -a /Applications/Google\ Chrome.app
```

1. Sample commands to run

```
show hostname
show version
show interface

# Configure an interface
# nxos1
int eth1/1
no switchport
no shut
ip add 10.100.100.1/24

# nxos2
int eth1/1
no switchport
no shut
ip add 10.100.100.2/24
```

1. Run some NX-API REST Commands with Postman
  * Postman Collection and Environment files in `./postman`.

1. Lifecycle the Environment.

```bash
# Destroy nxos2
vagrant destroy nxos2

# Suspend nxos1
vagrant suspend nxos1

# status
vagrant status

# Resume nxos1
vagrant resume nxos1
```  

1. Creating your own boxes.  

```bash
open https://github.com/hpreston/vagrant_net_prog/tree/master/box_building -a /Applications/Google\ Chrome.app
open "https://software.cisco.com/download/release.html?mdfid=286312239&flowid=81422&softwareid=282088129&release=7.0(3)I7(2)&relind=AVAILABLE&rellifecycle=&reltype=latest" -a /Applications/Google\ Chrome.app
```

# Demo 2: Ansible

1. Source the dev_env file for credentials.  

```bash
source ansible_env_dev
```

1. Explore the key files for running Ansible.  
  * `ansible.cfg`
  * `hosts`

1. Run the first example against the Vagrant switch. Also look at the file.  

```bash
ansible-playbook example1.yaml
```

1. Explore the second example playbook and relevant files.  
  * `example2.yaml`
  * `host_vars\127.0.0.1.yaml`

1. Run the second example against the vagrant switch.  

```bash
ansible-playbook exmaple2.yaml
```

# Demo 3: VIRL

1. Open VIRL Web Interface

```bash
open http://10.10.20.160:19400/simulations/ -a /Applications/Google\ Chrome.app
```

1. Explore the Simulation Running.  

1. Explore the APIs in the docs, and run in Postman.  

1. Explore `virlutils`

```bash
virl --help
virl ls
virl nodes
virl console ios-xev-1
virl console nx-osv9000-1
```

# Demo 4: Ansible Part 2

1. Move to the new directory for this demo.  

```bash
cd twtv_cicd_demo
```

1. Update environment credentials for VIRL.  

```bash
source ansible_env_virl
```

1. Run the playbook

```bash
ansible-playbook network_deploy.yaml
```

1. While running, explore what is going on.
  * `network_deploy.yaml`
  * `hosts`
  * `roles/`
  * `group_vars/`
  * `host_vars/`


# Demo 5: CICD

1. Open up the pipeline tool pages.  

```bash
open http://10.10.20.20/gogs/netdevopsuser/network_cicd_lab -a /Applications/Google\ Chrome.app
open http://10.10.20.20 -a /Applications/Google\ Chrome.app
```

1. Activate the Repo.  

1. Explore the `.drone.yml` file.  

1. Setup Drone Secrets for Spark Notifications.  Replace with your Token and Email address.  

```bash
drone secret add --repository netdevopsuser/twtv_cicd_demo --name SPARK_TOKEN --value <TOKEN VALUE Provided>
drone secret add --repository netdevopsuser/twtv_cicd_demo --name PERSONEMAIL --value <Your Spark Email>
```

1. Create an empty commit and run the build.  

```bash
git commit -m "Build Test" --allow-empty
git push
```

1. Check current state of the network.  

```bash
virl console ios-xev-1

# On Core 1
show ip route ospf

# Exit to workstation
virl console nx-osv9000-1

# On Dist 1
sh vlan bri
sho ip int bri
```

1. Make a "Network as Code" change to add a new VLAN  

```bash
cp ../demo_files/all.yaml group_vars/
cp ../demo_files/distribution.yaml group_vars/
cp ../demo_files/172.16.30.101.yaml host_vars/
cp ../demo_files/172.16.30.102.yaml host_vars/
```

1. Commit the changes to source control.  

```bash
git add group_vars/ host_vars/
git commit -m "Added VLAN 201"
git push
```

1. Watch the build in Drone.

1. Check current state of the network.  

```bash
virl console ios-xev-1

# On Core 1
show ip route ospf

# Exit to workstation
virl console nx-osv9000-1

# On Dist 1
sh vlan bri
sho ip int bri
```

# Demo Cleanup

1. From the `twtv_netdevops_webinar` directory, run the cleanup script.  

```bash
./demo_cleanup.sh
```
