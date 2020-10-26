# Howto
## Howto git
https://www.thorandco.fr/?p=792

    git config --global user.name "myname"
    git config --global user.email myname@domaine

### Howto manage depo
#### Create an empty repo on an empty project

    cd /home/git
    mkdir monprojet
    cd monprojet
    git init
    touch README
    git add README
    git commit -m 'Premier Commit'
    git remote add origin git.domaine.fr/thorandco/monprojet.git
    git push -u origin master

#### Update file on an existing repo
You are not pushing files but changes. So if you have cloned a repository with a lot of files and only changed one of them, you're only sending in the change to that one file. In your case that would be:

    git clone git@github.com/some/repo .
    git status                             # nothing has changed
    vim file_A
    vim file_B
    git status                             # file_A and file_B have changed
    git add file_A                         # you only want to have the changes in file_A in your commit
    git commit -m "file_A something"
    git status                             # file_B is still marked as changed

You can and should continue doing changes and commiting them until you're pleased with the result. Only then you should push the changes back to GitHub. This assures that everybody else cloning the repository in the meantime will not get your potientially broken work-in-progress.

    git pull origin master
    git push origin master

will send in all commits you made after you cloned the repository.

## Howto Terraform
### Install & configure terraform
### terraform project lifecycle
    terraform init
    terraform plan
    terraform apply
    terraform destroy

