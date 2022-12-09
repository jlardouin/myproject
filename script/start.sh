#! /bin/sh
terraform output keypair >> ~/.ssh/my-keypair.pem
chmod 400 ~/.ssh/my-keypair.pem
BASTION=$(terraform output --raw bastion_public_IP)
SSH_PORT=$(terraform output --raw ssh_port)
echo "Host bastion"				>> ~/.ssh/config
echo "  Hostname $BASTION"			>> ~/.ssh/config
echo "  IdentityFile ~/.ssh/my-keypair.pem"	>> ~/.ssh/config
echo "  User cloud"				>> ~/.ssh/config
echo "  Port $SSH_PORT"				>> ~/.ssh/config
#ssh -i keypair.pem -o "StrictHostKeyChecking no" -p $SSH_PORT cloud@$BASTION
