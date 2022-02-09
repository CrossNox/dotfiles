sudo dnf install bspwm rofi polybar feh sxhkd dbus-devel gcc git libconfig-devel libdrm-devel libev-devel libX11-devel libX11-xcb libXext-devel libxcb-devel mesa-libGL-devel meson pcre-devel pixman-devel uthash-devel xcb-util-image-devel xcb-util-renderutil-devel xorg-x11-proto-devel lxappearance libxcb-devel xcb-util-keysyms-devel xcb-util-devel xcb-util-wm-devel xcb-util-cursor-devel dunst xinput playerctl neofetch rofi-devel autoconf automake libtool libXt-devel libXfixes-devel libXi-devel qalculate

pipx install pywal

git clone git@github.com:ibhagwan/picom.git ~/repos/picom
cd ~/repos/picom
git submodule update --init --recursive
meson --buildtype=release . build
ninja -C build
sudo ninja -C build install

git clone https://github.com/baskerville/xdo.git ~/repos/xdo
cd ~/repos/xdo
make
sudo make install

curl -fsSL https://raw.githubusercontent.com/khanhas/spicetify-cli/master/install.sh | sh
sudo chmod a+wr /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify
sudo chmod a+wr -R /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/Apps

git clone git@github.com:Mange/rofi-emoji.git ~/repos/rofi-emoji
cd ~/repos/rofi-emoji
autoreconf -i
mkdir build
cd build/
../configure
make
sudo make install

git clone git@github.com:jcs/xbanish.git ~/repos/xbanish
cd ~/repos/xbanish/
make
mv xbanish ~/.local/bin/

git clone git@github.com:svenstaro/rofi-calc.git ~/repos/rofi-calc
cd ~/repos/rofi-calc
autoreconf -i
mkdir build
cd build/
../configure
make
sudo make install
