ssh-keygen -t ed25519 -C $1 -f ~/.ssh/id_ed25519.pub
xclip -sel clip <~/.ssh/id_ed25519.pub
read -p "Add ssh key to github. Then press enter"
