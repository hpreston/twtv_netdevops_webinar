#! /bin/bash

echo "This script will setup the sandbox to run webinar demos: "
echo " "
echo " This script installs pre-reqs and prepares the environment "
echo " "

echo "Beginning Setup"
echo "Step 1: Installing Pre-Reqs"

echo "  - Ansible Roles"
ansible-galaxy install zaxos.docker-ce-ansible-role

echo "  - SSH Pass"
brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb

echo "Step 3: Verify DevBox Accessible"
ping -c 4 10.10.20.20
if [ $? -ne 0 ]
then
    echo "DevBox Unavailable."
    echo "Please ensure active and then click anykey to continue"
    read CONFIRM
    echo "Testing Connectivity to DevBox."
    ping -c 4 10.10.20.20
    if [ $? -ne 0 ]
    then
      echo "DevBox Unavailable. Killing VPN connection and stopping setup."
      OCPID=$(cat openconnect_pid.txt)
      kill ${OCPID}
    fi
fi


echo "Step 4: Run Setup Pipeline on DevBox"
cd sbx_setup
ansible-playbook -u root pipeline_setup.yml
cd ..

echo "  - Setting up Drone CLI ENV"
export DRONE_SERVER=http://10.10.20.20
export DRONE_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0ZXh0IjoibmV0ZGV2b3BzdXNlciIsInR5cGUiOiJ1c2VyIn0.24hOotRJyhNegtUPRjcyDzK4QyOW3xWWPJeUhozGsYk


echo "Step 5: Setup VIRL for Lab"
source lab_env

echo "  - Clearing Old VIRL Status"
rm -Rf .virl/
echo "  - Shutting down default simulation"
virl ls --all
virl down --sim-name API-Test
echo "  - Starting VIRL Simulation."
virl up


echo "Step 6: Clone Down Lab Repo from Gogs "
git clone http://netdevopsuser@10.10.20.20/gogs/netdevopsuser/twtv_cicd_demo
cd twtv_cicd_demo
git config user.name "NetDevOps User"
git config user.email "netdevopsuser@netdevops.local"
