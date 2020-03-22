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
sudo dnf install -y google-chrome-stable vivaldi-stable gnome-tweaks htop sublime-text snapd fira-code-fonts autojump powertop gnome-shell slack python3-virtualenv vim tlp tlp-rdw smbios-utils-python
sudo systemctl enable powertop.service
dbus-send --type=method_call --print-reply --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:'global.reexec_self()'
sleep 10
sudo snap install spotify 
sudo snap install telegram-desktop
pip3 install --user flake8
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

# kitty
ln -s ~/.local/kitty.app/bin/kitty ~/.local/bin/
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications
sed -i "s/Icon\=kitty/Icon\=\/home\/$USER\/.local\/kitty.app\/share\/icons\/hicolor\/256x256\/apps\/kitty.png/g" ~/.local/share/applications/kitty.desktop

# j cmd
echo 'source /usr/share/autojump/autojump.bash' >> ~/.bashrc

# colored terminal
echo 'PS1="\[\033[01;32m\]\u@\h:\[\033[00m\] \[\033[01;34m\]\w $\[\033[00m\] "' >> ~/.bashrc

# set up dev env
mkdir ~/repos

cd ~/repos
virtualenv -p python3 venv
source venv/bin/activate
deactivate

# add ssh key to github
sudo dnf install -y xclip
ssh-keygen -t rsa -b 4096 -C "ijmermet@gmail.com"
xclip -sel clip < ~/.ssh/id_rsa.pub
read -p "Add ssh key to github. Then press enter"

# dotfiles jazz
cd ~/repos
git clone git@github.com:CrossNox/dotfiles.git
cd ~
cp ~/repos/dotfiles/.alias ~/.alias
echo 'source ~/.alias' >> ~/.bashrc
cp ~/repos/dotfiles/kitty.conf ~/.config/kitty/
mkdir -p ~/.config/sublime-text-3/
cp -r ~/repos/dotfiles/Packages ~/.config/sublime-text-3/Packages
cp -r ~/repos/dotfiles/.vim* ~/

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