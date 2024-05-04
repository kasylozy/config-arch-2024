# Enable multilib
sudo vim /etc/pacman.conf

search multilib
#[multilib]
#Include = /etc/pacman.d/mirrorlist

edit to :
[multilib]
Include = /etc/pacman.d/mirrorlist

