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
You can run your terraform plan from your local desktop, initialising everything to init, plan, apply (& destroy if needed)
    terraform init
    terraform plan
    terraform apply
    terraform destroy

To enable Github Action & implement a IaaC interaction with Flexible Engine, we should set a basic wokflow using a Terraform Cloud workspace as a terraform runner   


