#!/bin/bash
OUTPUT_FILE="../ansible/inventory.ini"

VM_NAME=$(tofu output -raw vm_name)
VM_IP=$(tofu output -raw vm_ip)

cat > $OUTPUT_FILE <<EOF
[ubuntu_vms]
$VM_NAME ansible_host=$VM_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/gcp_vm_key
EOF

echo "Ansible inventory written to $OUTPUT_FILE:"
cat $OUTPUT_FILE
