#!/bin/bash

set -e
set -x

function install_packages ()
{
	sudo pacman -Syyu --needed --noconfirm \
		fuse2 \
		wine \
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
		picom
}

function configuration_yay
{
        if [ ! -d ./yay-bin ]; then
                if [ ! -f /usr/bin/git ]; then
                        sudo pacman -S --needed git base-devel
                fi
                rm -Rf ./yay-bin/
                git clone https://aur.archlinux.org/yay-bin.git
                cd ./yay-bin/
                makepkg -si --noconfirm
		cd ../
		rm -Rf ./yay-bin/
        fi
}

function configure_keyboard_french_canada() 
{
        keyboard_file=/etc/X11/xorg.conf.d/00-keyboard.conf
        if ! grep "ca(fr)" $keyboard_file &>/dev/null; then
                sudo rsync -avPh ./xorg.conf.d/00-keyboard.conf $keyboard_file
        fi
}

function update_config() 
{
	rsync -avPh ./config/* ~/.config/
}

function main ()
{
	install_packages
	configuration_yay
	configure_keyboard_french_canada
	update_config
}

main
