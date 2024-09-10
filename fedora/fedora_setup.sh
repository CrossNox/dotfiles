# if [[ $EUID -ne 0 ]]; then
#    echo "This script must be run as root, use sudo "$0" instead" 1>&2
#    exit 1
# fi

while true; do
	sudo -n true
	sleep 60
	kill -0 "$$" || exit
done 2>/dev/null &

set -e -o functrace
trap 'failure "LINENO" "BASH_LINENO" "#{BASH_COMMAND}" "${?}"' ERR
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT

SUDO_USER_HOME="$(eval echo "~$SUDO_USER")"
REPOS_FOLDER=$SUDO_USER_HOME/repos
DOTFILES_FOLDER=$REPOS_FOLDER/dotfiles

# clone this repo
echo "Cloning repo"

if [ ! -d "$REPOS_FOLDER" ]; then
	mkdir -p $REPOS_FOLDER
fi

if [ ! -d "$DOTFILES_FOLDER" ]; then
	git clone https://github.com/CrossNox/dotfiles.git $DOTFILES_FOLDER
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
sudo dnf install -y $(cat $DOTFILES_FOLDER/fedora/dnf_pkgs)
sudo systemctl enable powertop.service

# install git-lfs
cd /tmp
wget https://github.com/git-lfs/git-lfs/releases/download/v3.3.0/git-lfs-linux-amd64-v3.3.0.tar.gz
tar -zxvf git-lfs-linux-amd64-v3.3.0.tar.gz
cd git-lfs-3.3.0
sudo ./install.sh

# f33 default editor
echo "Nano -> vim"
sudo dnf remove -y nano-default-editor
sudo dnf install -y vim-default-editor

$DOTFILES_FOLDER/fedora/setup_scripts/install_terraform.sh
$DOTFILES_FOLDER/fedora/setup_scripts/setup_aws_cli_v2.sh

echo "adding flatpak remote"
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak --user override --filesystem=/home/$USER/.icons/:ro
flatpak --user override --filesystem=/usr/share/icons/:ro

REPOS_FOLDER=~/repos

if grep "38" /etc/fedora-release; then
	sudo dnf downgrade -y ostree-libs
fi

# sudo dnf swap pipewire-media-session wireplumber

echo "Install docker"
sudo dnf remove -y docker \
	docker-client \
	docker-client-latest \
	docker-common \
	docker-latest \
	docker-latest-logrotate \
	docker-logrotate \
	docker-selinux \
	docker-engine-selinux \
	docker-engine

sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo groupadd docker || echo "Group docker already exists"
sudo usermod -aG docker $USER

sudo systemctl enable docker
sudo systemctl start docker

echo "Installing flatpaks"
flatpak install -y --noninteractive com.spotify.Client
flatpak install -y --noninteractive com.discordapp.Discord
flatpak install -y --noninteractive com.github.wwmm.easyeffects
flatpak install -y --noninteractive com.slack.Slack
flatpak install -y --noninteractive org.telegram.desktop
flatpak install -y --noninteractive com.bitwarden.desktop
flatpak install -y --noninteractive com.getpostman.Postman

mkdir -p ~/.local/bin
mkdir -p ~/.gnupg

# For udev rules
sudo udevadm control --reload-rules && sudo udevadm trigger

# rvm
echo "Installing rvm"
curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
curl -L get.rvm.io | bash -s stable
source $HOME/.bashrc
rvm install 3.2.2
rvm pkg install openssl
rvm install ruby-2.7.8 --with-openssl-dir="$HOME/.rvm/usr"
rvm --default use 2.7.8

# kitty
echo "Installing kitty"
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications
sed -i "s/Icon\=kitty/Icon\=\/home\/$USER\/.local\/kitty.app\/share\/icons\/hicolor\/256x256\/apps\/kitty.png/g" ~/.local/share/applications/kitty.desktop

# set up dev env
echo "Setting devenv"
cd $REPOS_FOLDER
virtualenv -p python3.11 venv
source venv/bin/activate
pip install -r "$DOTFILES_FOLDER/fedora/base_requirements.txt"
deactivate
pip install toml typer dbus-python flask google-api-python-client google-auth-httplib2 google-auth-oauthlib youconfigme

# nvm
echo "Install nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source $HOME/.bashrc
nvm install node
npm install --global yarn prettier eslint
nvm install 14.18.1
nvm use 14.18.1
npm install --global yarn prettier eslint
nvm use default

echo "Install mdcat"
if [ ! -d "$REPOS_FOLDER/mdcat" ]; then
	git clone https://github.com/swsnr/mdcat.git $REPOS_FOLDER/mdcat
fi
cd $REPOS_FOLDER/mdcat
git pull
cargo install mdcat

echo "Install dprint"
cargo install --locked dprint

echo "Install onefetch"
cargo install onefetch

echo "Install nnn"
if [ ! -d "$REPOS_FOLDER/nnn" ]; then
	git clone https://github.com/jarun/nnn.git $REPOS_FOLDER/nnn
fi
git pull
cd $REPOS_FOLDER/nnn
make O_NERD=1 O_GITSTATUS=1
mv nnn $HOME/.local/bin/
sudo make install-desktop
sudo sed -i 's!Icon=nnn!Icon=/usr/local/share/icons/hicolor/64x64/apps/nnn.png!g' /usr/local/share/applications/nnn.desktop
sudo sed -i 's!Exec=nnn!Exec=bash -lc "nnn %f"!g' /usr/local/share/applications/nnn.desktop
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh

# Get pretty wallpaper
echo "Getting a nice wallpaper"
mkdir -p ~/Pictures/Wallpapers
cd ~/Pictures/Wallpapers
wget https://cdn.dribbble.com/users/5031/screenshots/3713646/attachments/832536/wallpaper_mikael_gustafsson.png

# glances
# echo "Installing glances"
# curl -L https://bit.ly/glances | /bin/bash
# systemctl --user daemon-reload
# systemctl --user enable glances.service
# systemctl --user start glances.service

# pipx
echo "Installing pipx and some apps"
python3 -m pip uninstall --yes pipx
python3 -m pip install --user pipx
python3 -m pipx ensurepath
pipx completions
pipx install cookiecutter
pipx install poetry
pipx install sqlparse
pipx install black
pipx install ruff
pipx install pycln
pipx install git+https://github.com/dsanson/termpdf.py.git
pipx install termdown
pipx install pywal
pipx install bspcq
pipx install gsutil
pipx install autoimport
pipx install awscli-local
pipx install sqlfluff
pipx install harlequin[s3,postgres]
# pipx install git+https://github.com/CrossNox/nbtodos.git

# jedi
pip3 install --user jedi

# fonts
echo "Downloading fonts"
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLo "Droid Sans Mono Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/DroidSansMNerdFont-Regular.otf
curl -fLo "Fira Code Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf
curl -fLo "DejaVu Sans Mono wifi ramp" https://github.com/isaif/polybar-wifi-ramp-icons/raw/main/DejaVuSansMono-wifi-ramp.ttf
curl -fLo "WeatherIcons Regular" https://github.com/erikflowers/weather-icons/raw/master/font/weathericons-regular-webfont.ttf
curl -fLo "MaterialIcons Regular" https://github.com/google/material-design-icons/raw/master/font/MaterialIcons-Regular.ttf
curl -fLo "CryptoFont" https://github.com/Cryptofonts/cryptofont/raw/master/fonts/cryptofont.ttf

fc-cache -v

# NB
echo "Install nb"
curl -L https://raw.github.com/xwmx/nb/master/nb -o /usr/local/bin/nb &&
	chmod +x /usr/local/bin/nb &&
	nb completions install

nb env install && nb completions install --download

echo "Install sass"
npm install -g sass

echo "Install serverless"
npm install -g serverless@3.38

# source ~/.bashrc

curl -fsSL https://raw.githubusercontent.com/khanhas/spicetify-cli/master/install.sh | sh -s -- 2.9.1
sudo chmod a+wr /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify
sudo chmod a+wr -R /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/Apps

echo "Linking dotfiles with stow"
cd $DOTFILES_FOLDER

echo "Linking home files"
if ! stow -nt $HOME home >/tmp/stow_stdout 2>/tmp/stow_stderr; then
	for x in $(grep "existing target is neither a link nor a directory:" /tmp/stow_stderr | cut -d: -f2 | xargs); do
		echo "Removing $HOME/$x"
		rm "$HOME/$x"
	done
fi
stow -vSt $HOME home

echo "Linking root files"
if ! stow -nt / root >/tmp/stow_stdout 2>/tmp/stow_stderr; then
	for x in $(grep "existing target is neither a link nor a directory:" /tmp/stow_stderr | cut -d: -f2 | xargs); do
		echo "Removing /$x"
		sudo rm "/$x"
	done
fi
sudo stow -vSt / root

echo "Linking host specific files"
for x in "shootingstar" "dell-xps" "gram"; do
	if [ $x = $HOSTNAME ]; then
		cd hosts/$HOSTNAME

		# stow root files
		if ! stow -nt / root >/tmp/stow_stdout 2>/tmp/stow_stderr; then
			for x in $(grep "existing target is neither a link nor a directory:" /tmp/stow_stderr | cut -d: -f2 | xargs); do
				echo "Removing /$x"
				sudo rm "/$x"
			done
		fi

		sudo stow --no-folding -vSt / root

		# stow home files
		if ! stow -nt $HOME home >/tmp/stow_stdout 2>/tmp/stow_stderr; then
			for x in $(grep "existing target is neither a link nor a directory:" /tmp/stow_stderr | cut -d: -f2 | xargs); do
				echo "Removing $HOME/$x"
				sudo rm "$HOME/$x"
			done
		fi

		stow --no-folding -vSt $HOME home

		# ready, go back
		cd ../..
	fi
done

echo "Install picom"
if [ ! -d "$REPOS_FOLDER/picom" ]; then
	git clone https://github.com/ibhagwan/picom.git ~/repos/picom
fi
cd ~/repos/picom
git pull
git submodule update --init --recursive
meson --buildtype=release . build
ninja -C build
sudo ninja -C build install

echo "Install xdo"
if [ ! -d "$REPOS_FOLDER/xdo" ]; then
	git clone https://github.com/baskerville/xdo.git ~/repos/xdo
fi
cd ~/repos/xdo
git pull
make
sudo make install

echo "Install rofi emoji"
if [ ! -d "$REPOS_FOLDER/rofi-emoji" ]; then
	git clone https://github.com/Mange/rofi-emoji.git ~/repos/rofi-emoji
fi
cd ~/repos/rofi-emoji
git pull
autoreconf -i
mkdir -p build
cd build/
../configure
make
sudo make install

echo "Install xbanish"
if [ ! -d "$REPOS_FOLDER/xbanish" ]; then
	git clone https://github.com/jcs/xbanish.git ~/repos/xbanish
fi
cd ~/repos/xbanish/
git pull
make
mv xbanish ~/.local/bin/

echo "Install rofi calc"
if [ ! -d "$REPOS_FOLDER/rofi-calc" ]; then
	git clone https://github.com/svenstaro/rofi-calc.git ~/repos/rofi-calc
fi
cd ~/repos/rofi-calc
git pull
autoreconf -i
mkdir -p build
cd build/
../configure
make
sudo make install

echo "Install rofi pass"
if [ ! -d "$REPOS_FOLDER/rofi-pass" ]; then
	git clone https://github.com/carnager/rofi-pass.git ~/repos/rofi-pass
fi
cd ~/repos/rofi-pass
git pull
sudo make install

echo "Install xtitle"
if [ ! -d "$REPOS_FOLDER/xtitle" ]; then
	git clone https://github.com/baskerville/xtitle.git ~/repos/xtitle
fi
cd ~/repos/xtitle
git pull
sudo make
sudo make install

echo "Install i3lock color"
if [ ! -d "$REPOS_FOLDER/i3lock-color" ]; then
	git clone https://github.com/Raymo111/i3lock-color.git ~/repos/i3lock-color
fi
git pull
cd ~/repos/i3lock-color
./install-i3lock-color.sh

echo "Install rofi bluetooth"
if [ ! -d "$REPOS_FOLDER/rofi-bluetooth" ]; then
	git clone https://github.com/ClydeDroid/rofi-bluetooth.git ~/repos/rofi-bluetooth
fi
cd ~/repos/rofi-bluetooth
git pull
cp rofi-bluetooth ~/.local/bin

echo "Install rofi network manager"
if [ ! -d "$REPOS_FOLDER/rofi-network-manager" ]; then
	git clone https://github.com/P3rf/rofi-network-manager.git ~/repos/rofi-network-manager
fi
cd ~/repos/rofi-network-manager
git pull
chmod +x rofi-network-manager.sh
cp rofi-network-manager.sh ~/.config/polybar/scripts/
#cp rofi-network-manager.rasi ~/.config/rofi/
#cp rofi-network-manager.conf ~/.config/rofi/

echo "Install ntfd"
cd /tmp
curl -fLo "ntfd" https://github.com/kamek-pf/ntfd/releases/download/0.2.2/ntfd-x86_64-unknown-linux-musl
chmod +x ntfd
mv ntfd ~/.local/bin

echo "Install zscroll"
if [ ! -d "$REPOS_FOLDER/zscroll" ]; then
	git clone https://github.com/noctuid/zscroll ~/repos/zscroll
fi
cd ~/repos/zscroll
cp zscroll ~/.local/bin/

echo "Install nvim"
if [ ! -d "$REPOS_FOLDER/neovim" ]; then
	git clone https://github.com/neovim/neovim ~/repos/neovim
fi
cd ~/repos/neovim
sudo dnf -y install ninja-build cmake gcc make unzip gettext curl glibc-gconv-extra
git checkout stable
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
python3 -m pip install --user --upgrade pynvim

echo "Install AppImages"

mkdir -p ~/AppImages

echo "Install Cura"
cd ~/AppImages
wget https://github.com/Ultimaker/Cura/releases/download/5.0.0/Ultimaker-Cura-5.0.0-linux.AppImage
chmod +x Ultimaker-Cura-5.0.0-linux.AppImage
wget https://raw.githubusercontent.com/leoheck/Cura/main/packaging/icons/cura-64.png

echo "Install MyCrypto"
cd ~/AppImages
wget https://github.com/MyCryptoHQ/MyCrypto/releases/download/1.7.17/linux-x86-64_1.7.17_MyCrypto.AppImage -O MyCrypto.AppImage
chmod +x MyCrypto.AppImage
wget https://download.mycrypto.com/common/assets/meta-fe1afc0ffc5a0dde50cf70fdd4e77e3d/coast-228x228.png -O MyCrypto.png

echo "Install Obsidian"
cd ~/AppImages
wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.3/Obsidian-1.5.3.AppImage -O Obsidian.AppImage
chmod +x Obsidian.AppImage
wget https://avatars.githubusercontent.com/u/65011256?s=256 -O Obsidian.png

echo "Install Beekeeper"
cd ~/AppImages
wget https://github.com/beekeeper-studio/beekeeper-studio/releases/download/v3.9.14/Beekeeper-Studio-3.9.14.AppImage -O Beekeeper.AppImage
chmod +x Beekeeper.AppImage
wget https://avatars.githubusercontent.com/u/53234021?s=256 -O Beekeeper.png

# install ngrok
wget -O /tmp/ngrok.tgz https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar -zxvf /tmp/ngrok.tgz -C ~/.local/bin/
if pass ls ngrok/authtoken; then
	ngrok config add-authtoken "$(pass ngrok/authtoken)"
fi

xdg-settings set default-web-browser vivaldi-stable.desktop

# own systemd services
systemctl --user enable xautolock
systemctl --user enable gmail-notifications-uni.service
systemctl --user enable gmail-notifications-work.service
systemctl --user enable gmail-notifications-personal.service
systemctl --user enable tgi-stable-code.service
