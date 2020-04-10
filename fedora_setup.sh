# set dnf repos
sudo dnf update -y
sudo dnf install -y fedora-workstation-repositories
sudo dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo
sudo dnf config-manager --set-enabled google-chrome
sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
sudo dnf copr enable evana/fira-code-fonts -y
sudo dnf copr enable jdoss/slack-repo -y
sudo dnf install -y slack-repo
# install packages
sudo dnf install -y google-chrome-stable vivaldi-stable gnome-tweaks htop sublime-text snapd fira-code-fonts autojump powertop gnome-shell slack python3-virtualenv vim tlp tlp-rdw smbios-utils-python telegram-desktop flatpak powerline-go
sudo systemctl enable powertop.service
sudo flatpak install -y --from https://flathub.org/repo/appstream/com.spotify.Client.flatpakref
pip3 install --user flake8
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

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

mkdir -p ~/.config/sublime-text-3/
ln -s ~/repos/dotfiles/Packages ~/.config/sublime-text-3/Packages

ln -s ~/repos/dotfiles/.vim ~/.vim
ln -s ~/repos/dotfiles/.vimrc ~/.vimrc

subl -b && sleep 10 && subl --command install_package_control
sleep 10
pkill subl

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
GPG_KEY_ID=gpg --list-keys | grep -A1 -E ^pub | grep -v pub | sed -e 's/^[ \t]*//' | xclip -sel clip
pass init "$(echo GPG_KEY_ID)"

# glances
mkdir -p ~/.config/systemd/user/
curl -L https://bit.ly/glances | /bin/bash
ln -s ~/repos/dotfiles/systemd/glances.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable glances.service
systemctl --user start glances.service
