#!/bin/sh#!/bin/sh

# Main script to deploy complete Openshift Cluster according to Assignment requisites
# Author: Carlos Izquierdo Fernández

# Generate inventory file from template
export GUID=$(hostname | cut -d'.' -f2)
sed "s/GUID_UNDEFINED/$GUID/g" ocp_inventory.tmp > ocp_inventory
# Run main ansible playbook
ansible-playbook -i ./ocp_inventory ./homework.yaml
