#! /bin/bash

echo "Beginning Cleanup"
echo "Step 7: Destroy local Vagrant Dev"
# Can't do this in SUDO because of VirtualBox Limitation
vagrant destroy -f

echo "Step 6: Delete Lab Repo from Gogs "
rm -Rf twtv_cicd_demo

echo "Step 5: Kill Prod Network VIRL for Lab"
source lab_env
echo "  - Shutting Down VIRL Simulation for Prod"
virl ls
virl down

echo "Step 4: Destroy Pipeline on DevBox"
cd sbx_setup
ansible-playbook -u root pipeline_clear.yml


echo "Cleanup Complete.  "
