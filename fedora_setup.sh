# set dnf repos
sudo dnf update
sudo dnf install -y fedora-workstation-repositories
sudo dnf config-manager --set-enabled google-chrome
sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
sudo dnf copr enable evana/fira-code-fonts
# install packages
sudo dnf install -y google-chrome-stable install gnome-tweaks htop sublime-text snapd fira-code-fonts autojump powertop
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
sudo snap install spotify 
sudo snap install telegram-desktop
pip install --user flake8

# kitty
ln -s ~/.local/kitty.app/bin/kitty ~/.local/bin/
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications
sed -i "s/Icon\=kitty/Icon\=\/home\/$USER\/.local\/kitty.app\/share\/icons\/hicolor\/256x256\/apps\/kitty.png/g" ~/.local/share/applications/kitty.desktop

# j cmd
echo 'source /usr/share/autojump/autojump.bash' >> ~/.bashrc

# colored terminal
echo 'PS1="\[\033[01;32m\]\u@\h:\[\033[00m\] \[\033[01;34m\]\w $\[\033[00m\]"' >> ~/.bashrc

# set up dev env
mkdir ~/repos

virtualenv -p python3 venv
source venv/bin/activate
pip install bpython
deactivate

# add ssh key to github
sudo dnf install xclip
ls -al ~/.ssh
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
cp -r ~/repos/dotfiles/Packages ~/.config/sublime-text-3/Packages
cp ~/repos/dotfiles/.vim* ~/

subl --command install_package_control

# extensions
sudo dnf install gnome-shell
cd ~/repos
git clone https://github.com/micheleg/dash-to-dock.git
cd dash-to-dock/
make
make install
gnome-shell --replace
git clone --depth 1 https://github.com/shumingch/gnome-email-notifications ~/.local/share/gnome-shell/extensions/GmailMessageTray@shuming0207.gmail.com

cd ~
source venv/bin/activate
pip install -r ~/repos/dotfiles/base_requirements.txt
