#!/bin/bash

set -e

function install_packages()
{
        sudo pacman -Syyu --needed --noconfirm \
		fuse2 \
		gtkmm \
		linux-headers \
		pcsclite \
		libcanberra \
                wine \
                firefox \
                wget \
                vim \
                vi \
                pwgen \
                htop \
                alacritty \
                chromium \
                vivaldi \
                vivaldi-ffmpeg-codecs \
                discord \
                polkit-gnome \
                libreoffice-fresh \
                nm-connection-editor \
                networkmanager \
                networkmanager-openvpn \
                ntfs-3g \
                vlc \
                gnome-system-monitor \
                udisks2 \
                remmina \
                freerdp \
                zip \
                unzip \
                mariadb \
                mariadb-clients \
                postfix \
                npm \
                ruby \
                zsh \
                wine-mono \
                lib32-vkd3d \
                wine-gecko \
                winetricks \
                git \
                rofi \
                polybar \
                rsync \
                ttf-font-awesome \
                awesome-terminal-fonts \
                powerline \
                powerline-fonts \
                wqy-bitmapfont \
                wqy-microhei \
                wqy-microhei-lite \
                wqy-zenhei \
                ttf-font-awesome \
                ttf-roboto \
                ttf-roboto-mono \
                noto-fonts-cjk \
                adobe-source-han-serif-cn-fonts \
                picom \
                feh \
                lxappearance \
                thunar \
                thunar-volman \
                xfce4-settings \
                neofetch \
                spotify-launcher \
                bitwarden \
                base-devel \
                dkms \
                arc-gtk-theme \
                gnome-screenshot \
                gnome-disk-utility \
                nautilus \
                docker \
		transmission-gtk \
		thunar-archive-plugin
}

function configuration_yay()
{
        if [ ! -f /usr/bin/yay ]; then
                rm -Rf ./yay-bin/
                git clone https://aur.archlinux.org/yay-bin.git
                cd ./yay-bin/
                makepkg -si --noconfirm
                cd ../
                rm -Rf ./yay-bin/
        fi
}

function install_aur()
{
        yay -Syyu --needed --noconfirm \
                aur/opera \
		ncurses5-compat-libs \
                vmware-workstation
}

function configure_keyboard_french_canada()
{
        keyboard_file=/etc/X11/xorg.conf.d/00-keyboard.conf
        if ! grep "ca(fr)" $keyboard_file &>/dev/null; then
                sudo rsync -avPh ./xorg.conf.d/00-keyboard.conf $keyboard_file
        fi
}

function enable_network_manager()
{
        if [ `systemctl is-enabled NetworkManager` = "disabled" ]; then
                sudo systemctl enable --now NetworkManager
        fi
}

function configure_mariadb()
{
        if [ `systemctl is-enabled mariadb` = "disabled" ]; then
		sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
                sudo systemctl enable --now mariadb
        fi
}

function configure_ohMyZsh()
{
        if [ ! -d ~/.oh-my-zsh ]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" <<EOF
        exit
EOF
        chsh -s $(which zsh)
        sudo pacman -S --noconfirm keychain
        mkdir -p -m 700 ~/.ssh
        git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
        sed -i "s/ZSH_THEME=\"robbyrussell\"/#ZSH_THEME=\"robbyrussell\"/" ~/.zshrc
        cat >> ~/.zshrc <<EOF
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure
zmodload zsh/nearcolor
zstyle :prompt:pure:path color '#FFFFFF'
zstyle ':prompt:pure:prompt:*' color cyan
zstyle :prompt:pure:git:stash show yes
eval \$(keychain --eval --agents ssh --quick --quiet)
export TERM=xterm-256color
EOF
        fi
}

function configure_postfix()
{
        if [ `systemctl is-enabled postfix` = "disabled" ]; then
                postfix_file=/etc/postfix/main.cf
                sudo chmod o+w $postfix_file
                sudo sed -i 's/#relayhost = \[an\.ip\.add\.ress\]/relayhost = 127\.0\.0\.1:1025/' $postfix_file
                sudo chmod o-w $postfix_file
                sudo systemctl enable --now postfix
        fi
}

function maildev_docker()
{
        if [ `systemctl is-enabled docker.service` = "disabled" ] ; then
                sudo systemctl enable --now docker.service
        fi
        if ! sudo docker ps | grep mail; then
                sudo docker run -d --restart unless-stopped -p 1080:1080 -p 1025:1025 dominikserafin/maildev:latest
        fi
}

function enable_services_vmware ()
{
	sudo systemctl enable vmware-networks.service  vmware-usbarbitrator.service 
	sudo systemctl start vmware-networks.service  vmware-usbarbitrator.service
	sudo modprobe -a vmw_vmci vmmon
}

function move_default_picture()
{
	rsync -avPh ./Pictures ~/
}

function disable_error_network ()
{
	sudo systemctl disable systemd-networkd-wait-online.service
	sudo systemctl mask systemd-networkd-wait-online.service
}

function update_config()
{
        rsync -avPh ./config/* ~/.config/
        rsync -avPh ./.alacritty.toml ~/
}

function main()
{
        install_packages
        configuration_yay
        install_aur
        configure_keyboard_french_canada
        enable_network_manager
        configure_mariadb
        configure_ohMyZsh
        configure_postfix
        maildev_docker
        enable_services_vmware
        move_default_picture
 	disable_error_network
 	update_config
}

main
