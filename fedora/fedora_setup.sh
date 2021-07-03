# clone this repo
REPOS_FOLDER=~/repos

mkdir $REPOS_FOLDER
git clone https://github.com/CrossNox/dotfiles.git $REPOS_FOLDER/dotfiles
cd $REPOS_FOLDER/dotfiles

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

# f33 default editor
sudo dnf remove -y nano-default-editor
sudo dnf install -y vim-default-editor

./setup_scripts/install_terraform.sh
./setup_scripts/setup_aws_cli_v2.sh

# install flatpaks
flatpak install -y --from https://flathub.org/repo/appstream/com.spotify.Client.flatpakref
flatpak install -y flathub com.discordapp.Discord

if [ $DESKTOP_SESSION == "gnome" ]; then
    flatpak install flathub org.gnome.Extensions
fi
# return to user
exit

stow -vSt ~/.config .config
stow -vSt ~ bash
stow -vSt ~ git

# install kitty
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
cd $REPOS_FOLDER
virtualenv -p python3 venv
source venv/bin/activate
pip install -r dotfiles/fedora/base_requirements.txt
deactivate

# add ssh key to github
ssh-keygen -t rsa -b 4096 -C "ijmermet@gmail.com"
xclip -sel clip < ~/.ssh/id_rsa.pub
read -p "Add ssh key to github. Then press enter"

# extensions
if [ $DESKTOP_SESSION == "gnome" ]; then
  cd $REPOS_FOLDER
  git clone https://github.com/micheleg/dash-to-dock.git
  cd dash-to-dock/
  make
  make install

  cd $REPOS_FOLDER
  git clone --depth 1 https://github.com/shumingch/gnome-email-notifications ~/.local/share/gnome-shell/extensions/GmailMessageTray@shuming0207.gmail.com

  cd $REPOS_FOLDER
  git clone https://github.com/RensAlthuis/vertical-overview.git
  cd vertical-overview
  make
  make install

  cd $REPOS_FOLDER
  git clone https://github.com/aunetx/blur-my-shell
  cd blur-my-shell
  make install

  # dbus-send --type=method_call --print-reply --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:'global.reexec_self()'
  # gnome-extensions enable vertical-overview@RensAlthuis.github.com
  # gnome-extensions enable blur-my-shell@aunetx

  #read -p "Tap to click. Then press enter"
  #read -p "Enable extensions. Then press enter"
  #read -p "Mayus as esc. Then press enter"
  #read -p "Maximize windows. Then press enter"
  #read -p "Dark theme. Then press enter"
fi

cd ~/Pictures
wget https://cdn.dribbble.com/users/5031/screenshots/3713646/attachments/832536/wallpaper_mikael_gustafsson.png

# pass
gpg --full-generate-key
GPG_KEY_ID=gpg --list-secret-keys | grep -A1 -E ^sec | grep -v sec | sed -e 's/^[ \t]*//' | xclip -sel clip
pass init "$(echo GPG_KEY_ID)"

# glances
curl -L https://bit.ly/glances | /bin/bash
systemctl --user daemon-reload
systemctl --user enable glances.service
systemctl --user start glances.service

# pipx
python3 -m pip install --user pipx
python3 -m pipx ensurepath
pipx completions
pipx install cookiecutter
pipx install poetry
pipx install sqlparse
pipx install black
# jedi
pip3 install --user jedi

# fonts
mkdir -p /.local/share/fonts

curl -fLo "Droid Sans Mono Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

curl -fLo "Fira Code Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf

fc-cache -v

# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc
nvm install node
npm install --global yarn
