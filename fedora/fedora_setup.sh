if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, use sudo "$0" instead" 1>&2
   exit 1
fi

su "$SUDO_USER"

# clone this repo
echo "Cloning repo"
REPOS_FOLDER=~/repos

if [ ! -d "$REPOS_FOLDER" ] ; then
    mkdir -p $REPOS_FOLDER
fi

if [ ! -d "$REPOS_FOLDER/dotfiles" ] ; then
    git clone https://github.com/CrossNox/dotfiles.git $REPOS_FOLDER/dotfiles
fi

cd $REPOS_FOLDER/dotfiles
git pull

exit

SUDO_USER_HOME="$(eval echo "~$SUDO_USER")"
DOTFILES_FOLDER=$SUDO_USER_HOME/repos/dotfiles

# set dnf repos
echo "Setting repos"
dnf update -y
dnf install -y fedora-workstation-repositories
#sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
#sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo
dnf config-manager --set-enabled google-chrome
dnf copr enable evana/fira-code-fonts -y
dnf copr enable jdoss/slack-repo -y
dnf install -y slack-repo

# install packages
echo "Installing DNF packages"
dnf install -y `cat $DOTFILES_FOLDER/fedora/dnf_pkgs`
systemctl enable powertop.service

# f33 default editor
echo "Nano -> vim"
dnf remove -y nano-default-editor
dnf install -y vim-default-editor

$DOTFILES_FOLDER/fedora/setup_scripts/install_terraform.sh
$DOTFILES_FOLDER/fedora/setup_scripts/setup_aws_cli_v2.sh

echo "adding flatpak remote"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

su "$SUDO_USER"

REPOS_FOLDER=~/repos

echo "Installing flatpaks"
flatpak install -y --noninteractive com.spotify.Client
flatpak install -y --noninteractive com.discordapp.Discord
flatpak install -y --noninteractive com.github.wwmm.easyeffects

if [ "$DESKTOP_SESSION" = "gnome" ]; then
    flatpak install -y --noninteractive org.gnome.Extensions
fi

echo "Linking dotfiles with stow"
rm ~/.bashrc
cd $REPOS_FOLDER/dotfiles
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
ln -s ~/.local/kitty.app/bin/kitty ~/.local/bin/
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications
sed -i "s/Icon\=kitty/Icon\=\/home\/$USER\/.local\/kitty.app\/share\/icons\/hicolor\/256x256\/apps\/kitty.png/g" ~/.local/share/applications/kitty.desktop

# set up dev env
echo "Setting devenv"
cd $REPOS_FOLDER
virtualenv -p python3 venv
source venv/bin/activate
pip install -r $REPOS_FOLDER/dotfiles/fedora/base_requirements.txt
deactivate

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
pip3 install --user jedi

# fonts
echo "Downloading fonts"
mkdir -p /.local/share/fonts

curl -fLo "Droid Sans Mono Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

curl -fLo "Fira Code Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf

fc-cache -v

# nvm
echo "Install nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc
nvm install node
npm install --global yarn

curl -L https://raw.github.com/xwmx/nb/master/nb -o /usr/local/bin/nb &&
  chmod +x /usr/local/bin/nb &&
  nb completions install

nb env install && nb completions install --download

exit
exit
