export GUID=$(hostname | cut -d'.' -f2)
sed "s/GUID_UNDEFINED/$GUID/g" ocp_inventory.tmp > ocp_inventory
ansible-playbook -i ./ocp_inventory ./main_deploy.yml
rm /root/.kube/config
ansible masters[0] -m fetch -a 'src=/root/.kube/config dest=/root/.kube/config flat=yes'
