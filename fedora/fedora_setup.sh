# if [[ $EUID -ne 0 ]]; then
#    echo "This script must be run as root, use sudo "$0" instead" 1>&2
#    exit 1
# fi

while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

SUDO_USER_HOME="$(eval echo "~$SUDO_USER")"
REPOS_FOLDER=$SUDO_USER_HOME/repos
DOTFILES_FOLDER=$SUDO_USER_HOME/repos/dotfiles

# clone this repo
echo "Cloning repo"

if [ ! -d "$REPOS_FOLDER" ] ; then
    mkdir -p $REPOS_FOLDER
	chown "$SUDO_USER" $REPOS_FOLDER
fi

if [ ! -d "$DOTFILES_FOLDER" ] ; then
    git clone https://github.com/CrossNox/dotfiles.git $DOTFILES_FOLDER
	chown "$SUDO_USER" $DOTFILES_FOLDER
fi

cd $DOTFILES_FOLDER
git pull


# set dnf repos
echo "Setting repos"
sudo dnf update -y
sudo dnf install -y fedora-workstation-repositories
# sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
# sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo
sudo dnf config-manager --set-enabled vivaldi
sudo dnf config-manager --set-enabled google-chrome

# install packages
echo "Installing DNF packages"
sudo dnf install -y `cat $DOTFILES_FOLDER/fedora/dnf_pkgs`
sudo systemctl enable powertop.service

# f33 default editor
echo "Nano -> vim"
sudo dnf remove -y nano-default-editor
sudo dnf install -y vim-default-editor

$DOTFILES_FOLDER/fedora/setup_scripts/install_terraform.sh
$DOTFILES_FOLDER/fedora/setup_scripts/setup_aws_cli_v2.sh

echo "adding flatpak remote"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

REPOS_FOLDER=~/repos

echo "Installing flatpaks"
flatpak install -y --noninteractive com.spotify.Client
flatpak install -y --noninteractive com.discordapp.Discord
flatpak install -y --noninteractive com.github.wwmm.easyeffects
flatpak install -y --noninteractive com.slack.Slack

if [ "$DESKTOP_SESSION" = "gnome" ]; then
    flatpak install -y --noninteractive flathub org.gnome.Extensions
fi

echo "Linking dotfiles with stow"
rm ~/.bashrc
cd $DOTFILES_FOLDER
stow -vSt ~/.config .config
stow -vSt ~ bash
stow -vSt ~ git

# rvm
echo "Installing rvm"
curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
curl -L get.rvm.io | bash -s stable
echo 'source ~/.rvm/scripts/rvm' >> ~/.bashrc
source ~/.bashrc
rvm install 2.7.0
rvm --default use 2.7.0

# kitty
echo "Installing kitty"
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
mkdir -p ~/.local/bin
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications
sed -i "s/Icon\=kitty/Icon\=\/home\/$USER\/.local\/kitty.app\/share\/icons\/hicolor\/256x256\/apps\/kitty.png/g" ~/.local/share/applications/kitty.desktop

# set up dev env
echo "Setting devenv"
cd $REPOS_FOLDER
virtualenv -p python3 venv
source venv/bin/activate
pip install -r $DOTFILES_FOLDER/fedora/base_requirements.txt
deactivate

# nvm
echo "Install nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc
nvm install node
npm install --global yarn

# Install mdcat
git clone https://github.com/lunaryorn/mdcat.git $REPOS_FOLDER/mdcat
cd $REPOS_FOLDER/mdcat
cargo install mdcat

# Install onefetch
cargo install onefetch

# nnn
git clone https://github.com/jarun/nnn.git $REPOS_FOLDER/nnn
cd $REPOS_FOLDER/nnn
make O_NERD=1
mv nnn $HOME/.local/bin/

git clone
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh

# Get pretty wallpaper
echo "Getting a nice wallpaper"
cd ~/Pictures
wget https://cdn.dribbble.com/users/5031/screenshots/3713646/attachments/832536/wallpaper_mikael_gustafsson.png

# glances
echo "Installing glances"
curl -L https://bit.ly/glances | /bin/bash
systemctl --user daemon-reload
systemctl --user enable glances.service
systemctl --user start glances.service

# pipx
echo "Installing pipx and some apps"
python3 -m pip install --user pipx
python3 -m pipx ensurepath
pipx completions
pipx install cookiecutter
pipx install poetry
pipx install sqlparse
pipx install black
pipx install git+https://github.com/dsanson/termpdf.py.git
pipx install termdown
pipx install git+ssh://git@github.com/CrossNox/nbtodos.git

# jedi
pipx install --user jedi

# fonts
echo "Downloading fonts"
mkdir -p /.local/share/fonts

curl -fLo "Droid Sans Mono Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

curl -fLo "Fira Code Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf

fc-cache -v

# NB
curl -L https://raw.github.com/xwmx/nb/master/nb -o /usr/local/bin/nb &&
  chmod +x /usr/local/bin/nb &&
  nb completions install

nb env install && nb completions install --download

npm install -g sass

# extensions
if [ "$DESKTOP_SESSION" = "gnome" ]; then

  echo "Installing gnome extensions"

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

  gnome-extensions enable vertical-overview@RensAlthuis.github.com
  gnome-extensions enable dash-to-dock@micxgx.gmail.com
  gnome-extensions enable blur-my-shell@aunetx

  #read -p "Tap to click. Then press enter"
  #read -p "Enable extensions. Then press enter"
  #read -p "Mayus as esc. Then press enter"
  #read -p "Maximize windows. Then press enter"
  #read -p "Dark theme. Then press enter"
fi
