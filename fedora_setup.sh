# set dnf repos
sudo -i
dnf update -y
dnf install -y fedora-workstation-repositories
#dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
#dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo
dnf config-manager --set-enabled google-chrome
dnf copr enable evana/fira-code-fonts -y
dnf copr enable jdoss/slack-repo -y
dnf install -y slack-repo
# install packages
dnf install -y `cat dnf_pkgs`
systemctl enable powertop.service
flatpak install -y --from https://flathub.org/repo/appstream/com.spotify.Client.flatpakref
flatpak install -y flathub com.discordapp.Discord

# return to user
exit
pip3 install --user flake8
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

# rvm
curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
curl -L get.rvm.io | bash -s stable
echo 'source ~/.rvm/scripts/rvm' >> ~/.bashrc
source ~/.bashrc
rvm install 2.7.0
rvm --default use 2.7.0

# kitty
ln -s ~/.local/kitty.app/bin/kitty ~/.local/bin/
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications
sed -i "s/Icon\=kitty/Icon\=\/home\/$USER\/.local\/kitty.app\/share\/icons\/hicolor\/256x256\/apps\/kitty.png/g" ~/.local/share/applications/kitty.desktop

# set up dev env
mkdir ~/repos

cd ~/repos
virtualenv -p python3 venv

# j cmd
echo 'source /usr/share/autojump/autojump.bash' >> ~/.bashrc

# todo.sh
cd ~/repos
git clone https://github.com/todotxt/todo.txt-cli.git
cd todo.txt-cli/
make
mkdir ~/bin
mkdir -p ~/.local/share/bash-completion/completions
make install CONFIG_DIR=~/.todo INSTALL_DIR=~/bin BASH_COMPLETION=~/.local/share/bash-completion/completions
mkdir -p ~/.todo.actions.d
mkdir ~/.todo
ln -s ~/repos/dotfiles/todo_config ~/.todo/config
#wget -P ~/.todo.actions.d/ https://raw.githubusercontent.com/amcintosh/todo.txt-cli/google-tasks-addon/.todo.actions.d/google
#chmod +x ~/.todo.actions.d/google
#pip install --user -r https://raw.githubusercontent.com/amcintosh/todo.txt-cli/google-tasks-addon/.todo.actions.d/requirements.txt

# add ssh key to github
sudo dnf install -y xclip
ssh-keygen -t rsa -b 4096 -C "ijmermet@gmail.com"
xclip -sel clip < ~/.ssh/id_rsa.pub
read -p "Add ssh key to github. Then press enter"

# dotfiles jazz
cd ~/repos
git clone git@github.com:CrossNox/dotfiles.git
cd ~

# alias
ln -s ~/repos/dotfiles/.alias ~/.alias
echo 'source ~/.alias' >> ~/.bashrc

# powerline
ln -s ~/repos/dotfiles/.powerline ~/.powerline
echo 'source ~/.powerline' >> ~/.bashrc

# kitty conf
ln -s ~/repos/dotfiles/kitty.conf ~/.config/kitty/kitty.conf

# extensions
cd ~/repos
git clone https://github.com/micheleg/dash-to-dock.git
cd dash-to-dock/
make
make install
git clone --depth 1 https://github.com/shumingch/gnome-email-notifications ~/.local/share/gnome-shell/extensions/GmailMessageTray@shuming0207.gmail.com
dbus-send --type=method_call --print-reply --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:'global.reexec_self()'

cd ~/repos
source venv/bin/activate
pip install -r ~/repos/dotfiles/base_requirements.txt
deactivate

cd ~/Pictures
wget https://cdn.dribbble.com/users/5031/screenshots/3713646/attachments/832536/wallpaper_mikael_gustafsson.png
sudo dnf install numix-icon-theme-circle breeze-cursor-theme arc-theme 

read -p "Tap to click. Then press enter"
read -p "Enable extensions. Then press enter"
read -p "Mayus as esc. Then press enter"
read -p "Maximize windows. Then press enter"
read -p "Dark theme. Then press enter"
read -p "Chrome login. Then press enter"

# pass
gpg --full-generate-key
sudo dnf install pass
GPG_KEY_ID=gpg --list-secret-keys | grep -A1 -E ^sec | grep -v sec | sed -e 's/^[ \t]*//' | xclip -sel clip
pass init "$(echo GPG_KEY_ID)"

# glances
mkdir -p ~/.config/systemd/user/
curl -L https://bit.ly/glances | /bin/bash
ln -s ~/repos/dotfiles/systemd/glances.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable glances.service
systemctl --user start glances.service

# pipx
python3 -m pip install --user pipx
python3 -m pipx ensurepath
pipx completions

# stuff
pipx install cookiecutter
pipx install poetry

# f33 default editor
sudo dnf remove nano-default-editor
sudo dnf install vim-default-editor
echo 'export EDITOR=vim' >> ~/.bashrc

# jedi
deactivate
pip install --user jedi

# neovim
mkdir ~/.config/nvim
ln -s ~/repos/dotfiles/init.vim ~/.config/nvim/init.vim
