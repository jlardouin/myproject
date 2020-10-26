# Howto
## Howto git
https://www.thorandco.fr/?p=792

git config --global user.name "myname"
git config --global user.email myname@domaine
###Howto manage depo
#### Empty repo on an empty project
cd /home/git
mkdir monprojet
cd monprojet
git init
touch README
git add README
git commit -m 'Premier Commit'
git remote add origin git.domaine.fr/thorandco/monprojet.git
git push -u origin master
