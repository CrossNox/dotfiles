ssh-keygen -t rsa -b 4096 -C $1 -N $2 -f ~/.ssh/id_rsa.pub
xclip -sel clip < ~/.ssh/id_rsa.pub
read -p "Add ssh key to github. Then press enter"
