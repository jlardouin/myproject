#! /bin/sh
terraform output keypair >> keypair.pem
chmod 400 keypair.pem
BASTION=$(terraform output --raw bastion_public_IP)
SSH_PORT=$(terraform output --raw ssh_port)
ssh -i keypair.pem -o "StrictHostKeyChecking no" -p $SSH_PORT $BASTION