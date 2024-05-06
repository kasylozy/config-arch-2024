#!/bin/bash

set -e

function install_packages()
{
        sudo pacman -Syyu --needed --noconfirm \
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
                bitwarden \
                base-devel \
                dkms \
                arc-gtk-theme \
                gnome-screenshot \
                gnome-disk-utility \
                nautilus \
                docker \
		transmission-gtk \
		dosfstools \
		perl-text-iconv \
		extra/xdebug \
		extra/gnome-calculator \
		composer
}

function install_php ()
{
	yay -Syyu --needed --noconfirm \
		aur/php83 \
		aur/php83-gd \
		aur/php83-pdo \
		aur/php83-gmp \
		aur/php83-ftp \
		aur/php83-zip \
		aur/php83-cli \
		aur/php83-xml \
		aur/php83-xsl \
		aur/php83-bz2 \
		aur/php83-ffi \
		aur/php83-dom \
		aur/php83-dba \
		aur/php83-cgi \
		aur/php83-phar \
		aur/php83-pecl \
		aur/php83-pear \
		aur/php83-tidy \
		aur/php83-snmp \
		aur/php83-odbc \
		aur/php83-ldap \
		aur/php83-intl \
		aur/php83-curl \
		aur/php83-exif \
		aur/php83-imap \
		aur/php83-pcntl \
		aur/php83-shmop \
		aur/php83-posix \
		aur/php83-pgsql \
		aur/php83-mysql \
		aur/php83-iconv \
		aur/php83-embed \
		aur/php83-ctype \
		aur/php83-pspell \
		aur/php83-redis \
		aur/php83-sqlite \
		aur/php83-bcmath \
		aur/php83-sodium \
		aur/php83-mcrypt \
		aur/php83-igbinary \
		aur/php83-enchant \
		aur/php83-sockets \
		aur/php83-openssl \
		aur/php83-gettext \
		aur/php83-opcache \
		aur/php83-firebird \
		aur/php83-xdebug \
		aur/php83-fileinfo \
		aur/php83-calendar \
		aur/php83-mbstring \
		aur/php83-imagick \
		aur/php83-simplexml \
		aur/php83-xmlwriter \
		aur/php83-xmlreader \
		aur/php83-tokenizer \
		php83-xdebug
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
		spotify
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

function move_default_picture()
{
	rsync -avPh ./Pictures ~/
}

function disable_error_network ()
{
	sudo systemctl disable systemd-networkd-wait-online.service
	sudo systemctl mask systemd-networkd-wait-online.service
}

function configure_php ()
{
	sudo rm -f /usr/bin/php
	sudo ln -s /usr/bin/php83 /usr/bin/php
	sudo rsync -avPh ./php/ /etc/php83/conf.d/
}

function install_virtualbox ()
{
	sudo pacman -S virtualbox-host-modules-arch \
		virtualbox \
		--needed --noconfirm
	sudo modprobe vboxdrv
VBOXVERSION=$(vboxmanage -v | cut -dr -f1)
	wget https://download.virtualbox.org/virtualbox/${VBOXVERSION}/Oracle_VM_VirtualBox_Extension_Pack-${VBOXVERSION}.vbox-extpack
	sudo vboxmanage extpack install Oracle_VM_VirtualBox_Extension_Pack-${VBOXVERSION}.vbox-extpack
	sudo usermod -aG vboxusers $USER
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
	install_php
        install_aur
        configure_keyboard_french_canada
        enable_network_manager
        configure_mariadb
        configure_ohMyZsh
        configure_postfix
        maildev_docker
        move_default_picture
 	disable_error_network
 	configure_php
	install_virtualbox
	update_config
}

main

