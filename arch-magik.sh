#!/bin/sh

# Prerequisites:
# pacman -Sy git vim
# cd arch-magik
#part1
printf '\033c'
echo "Welcome to Saumit's arch installer and ricing bootstraping script"

# For faster overall Download of packages
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
sed -i '/Color/s/^#//g' /etc/pacman.conf
sed -i '/ParallelDownloads = 15/a ILoveCandy' /etc/pacman.conf

pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
lsblk
echo "Enter the drive for partitioning: (cfdisk /dev/sda or /dev/nvme0n1)"
read drive
cfdisk $drive
lsblk
echo "Enter EFI partition: "
read efipartition
mkfs.vfat -F 32 $efipartition
read -p "Did you also create a swap partition? [y/n]" answer
if [[ $answer = y ]] ; then
  echo "Enter the swap partition: "
  read swappartition
  mkswap $swappartition
  swapon $swappartition
fi
echo "Enter the root partition: "
read rpartition
mkfs.ext4 $rpartition 

read -p "Did you also create a home partition? [y/n]" answerhome
if [[ $answerhome = y ]] ; then
  echo "Enter the home partition: "
  read hpartition
  mkfs.ext4 $hpartition
fi
mount $rpartition /mnt
mkdir /mnt/boot /mnt/home
mount $efipartition /mnt/boot
if [[ $answerhome = y ]] ; then
	mount $hpartition /mnt/home
fi
pacstrap /mnt base base-devel linux linux-firmware linux-headers util-linux vim intel-ucode
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit 

#part2
printf '\033c'
pacman -S --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
sed -i '/en_US ISO-8859-1/s^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "Hostname: (name of the device)"
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
echo "Enter root password"
passwd
pacman --noconfirm -S grub efibootmgr mtools dosfstools
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH-LINUX
sed -i 's/quiet/pci=noaer/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

pacman --noconfirm -S xorg-server xorg-xinit xorg-xkill xorg-xbacklight \
     gnu-free-fonts ttf-jetbrains-mono ttf-joypixels ttf-font-awesome \
     sxiv mpv zathura zathura-pdf-mupdf ffmpeg imagemagick  \
     fzf man-db xwallpaper python-pywal unclutter xclip maim \
     zip unzip unrar p7zip xdotool brightnessctl redshift \
     git sxhkd zsh pipewire pipewire-pulse rsync qutebrowser \
     ranger libnotify dunst wget jq aria2 cowsay \
     dhcpcd wpa_supplicant networkmanager pamixer mpd ncmpcpp \
     zsh-syntax-highlighting xdg-user-dirs libconfig \
     bluez bluez-utils && 

systemctl enable NetworkManager.service 
sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers
echo "Enter Username: "
read username
useradd -m -G wheel -s /bin/bash $username
passwd $username
echo "Pre-Installation Finish Reboot now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
sed '1,/^#ltr/d' arch_install2.sh > /home/$username/ltr.sh
sed -i '/sudo/s/^#//g' /home/$username/ltr.sh && 
exit && 
reboot

#part3
# To be run as user

printf '\033c'
cd $HOME
git clone https://github.com/justsaumit/.dotfiles.git
# dwm: Window Manager
git clone https://github.com/justsaumit/dwm.git ~/.local/src/dwm
cd ~/.local/src/dwm
sudo make clean install &&
git remote set-url origin git@github.com:justsaumit/dwm.git

# st: Terminal Emulator
git clone  https://github.com/justsaumit/st.git ~/.local/src/st
cd ~/.local/src/st
sudo make clean install &&
git remote set-url origin git@github.com:justsaumit/st.git

# dmenu: Program Menu
git clone https://github.com/justsaumit/dmenu.git ~/.local/src/dmenu
cd ~/.local/src/dmenu
sudo make clean install &&
git remote set-url origin git@github.com:justsaumit/dmenu.git

# dwmblocks: Status bar for dwm
git clone https://github.com/bugswriter/dwmblocks.git ~/.local/src/dwmblocks
cd ~/.local/src/dwmblocks
sudo make clean install &&
git remote set-url origin git@github.com:justsaumit/dwmblocks.git

# yay: AUR helper
cd $HOME
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -S nerd-fonts-ubuntu-mono adobe-source-code-pro-fonts 

wallp=pix/Wallpaper/w/wow
mkdir -pv $wallp
wget -P $wallp https://images5.alphacoders.com/125/1255724.jpg & 
wget -P $wallp https://images4.alphacoders.com/144/14.jpg &
wget -P $wallp https://images2.alphacoders.com/689/689285.jpg &
wget -P $wallp https://images4.alphacoders.com/673/673338.jpg &
wget -P $wallp https://images6.alphacoders.com/101/1017426.png &
wget -P $wallp https://images.alphacoders.com/687/687596.jpg &
wget -P $wallp https://images6.alphacoders.com/107/1078795.jpg 

# dotfiles management (Use GNU stow in future or not)
cd ~/.dotfiles
\cp -rf .config/ $HOME
\cp -rf .local/ $HOME
\cp -rf .scripts/ $HOME
\cp -rf .bash_logout .bash_profile .bashrc .xinitrc $HOME
sed '1,/^#ltr/d' $ai3_path > $HOME/ltr.sh
sed -i '/sudo/s/^#//g' $HOME/ltr.sh

#ltr to be run with sudo privilleges by user
#sudo mkdir -pv /etc/X11/xorg.conf.d/ /etc/udev/rules.d/
#sudo cp $HOME/.dotfiles/etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
#sudo cp $HOME/.dotfiles/etc/udev/rules.d/90-backlight.rules /etc/udev/rules.d/90-backlight.rules
