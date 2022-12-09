# Howto
This project is a sample of a simple terraform deployment on Flexible Engine using Github Action as CI/CD engine

The goal is to manage :
- a git project 
- a github repo
- a github action worklow with a Terraform Cloud runner

## Howto git
#### Clone this repo to local
From your personnal desktop, use Git & VSC to manage your local code and commit changes to that repo. 
First, clone the github repo to your local desktop :

    git clone https://github.com/jlardouin/myproject.git
    

You can now change anything in the local repo and commit to github using VSC

## Howto Terraform
### Install & configure terraform
You can run your terraform plan from your local desktop, through Terraform CLI, initialising everything to init, plan, apply (& destroy if needed)
    terraform init
    terraform plan
    terraform apply
    terraform destroy

To enable CI/CD, enable Github Action & implement a IaaC interaction with Flexible Engine, we should set a basic wokflow using a Terraform Cloud workspace as a terraform runner   
- Generated a TF_API_TOKEN in TF Cloud through User settings/Tokens
- Configure it in Github/Secret/Actions for that project
- Create a .github/worklows/terraform.yml to defin the TF workflow

tfstate is configure to locate remotely on TF Cloud to enable remote/shared interaction

## Howto use the infra
### Which infra is built through that project
A main project is defining the landing zone (all the ressource required to host workload)
Some basic ressources & setup
1. A bucket to store data (to be definied which one? probably almost Logs comming from LTS & CTS)
2. A keypair
3. An Agency to enable cloud ressource interaction
4. more to be define

A Network configuration with
1. One single VPC with
2. Two Network (Frontend & Backend)
3. Two Subnet (Frontend & Backend)
4. One router routing the Two subnet
5. One NatGW with 1 SNAT for each subnet

A Linux Bastion creation exposed on Internet, attached to the Frontend subnet
1. One Elastic IP for Bastion VM
2. Security group to enable ssh (changing port to XXXX for security reason)
3. One ECS to host the Bastion

After the 1st deployment, you can configure the access to the Bastion, getting terraform output locally on your Desktop (keypair, Bastion public IP & ssh port)
 terraform login
 script/start.sh

To delete the cloud ressources, just run a "terraform destroy" from CLI or directly from TF Cloud& run script/clean.sh
