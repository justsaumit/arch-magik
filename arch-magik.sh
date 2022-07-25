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

#Updating mirrorlist for faster downloads
country=$(curl -4 ifconfig.co/country-iso)
pacman --noconfirm -Sy reflector
reflector -c $country -c Worldwide -a 12 -p https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syyy

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
pacstrap /mnt base base-devel linux linux-firmware linux-headers util-linux vim intel-ucode wget --noconfirm --needed
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit 

#part2
printf '\033c'
pacman -S --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
sed -i '/Color/s/^#//g' /etc/pacman.conf
sed -i '/ParallelDownloads = 15/a ILoveCandy' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
sed -i '13,14d' /etc/locale.gen
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
sed -i '/en_US ISO-8859-1/s/^#//g' /etc/locale.gen
sed -i '13 a\#  en_US ISO-8859-1' /etc/locale.gen
sed -i '14 a\#  en_US.UTF-8 UTF-8' /etc/locale.gen
echo "LC_ALL=en_US.UTF-8" | tee -a /etc/environment
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
sed -i 's/auto/1920x1080x32/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

pacman --noconfirm --needed -Sy xorg-server xorg-xinit xorg-xkill xorg-xbacklight \
     gnu-free-fonts ttf-jetbrains-mono ttf-joypixels ttf-font-awesome \
     sxiv mpv zathura zathura-pdf-mupdf ffmpeg ffmpegthumbnailer imagemagick  \
     vi vim fzf man-db xwallpaper python-pywal unclutter xclip maim \
     zip unzip unrar p7zip nvidia xdotool brightnessctl redshift \
     git sxhkd zsh pipewire pipewire-pulse rsync qutebrowser \
     ranger libnotify dunst wget jq aria2 cowsay neofetch neovim \
     dhcpcd wpa_supplicant networkmanager pamixer mpd ncmpcpp \
     zsh-syntax-highlighting tmux xdg-user-dirs pass pass-otp libconfig \
     polkit polkit-gnome trash-cli geoip bluez bluez-utils yt-dlp && 

systemctl enable NetworkManager.service 
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
#sed -i '/ %wheel ALL=(ALL:ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers
echo "Enter Username: "
read username
useradd -m -G wheel -s /bin/bash $username
passwd $username
echo "Pre-Installation Finish Reboot now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username
echo "Arch Installation is complete! Onto Ricing" 
exit

#part3
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
git clone https://github.com/justsaumit/dwmblocks.git ~/.local/src/dwmblocks
cd ~/.local/src/dwmblocks
sudo make clean install &&
git remote set-url origin git@github.com:justsaumit/dwmblocks.git

# pikaur: AUR helper
cd $HOME
git clone https://aur.archlinux.org/pikaur.git
cd pikaur
makepkg -fsri --noconfirm
cd
aurprogs='nerd-fonts-fira-code nerd-fonts-ubuntu-mono adobe-source-code-pro-fonts 
	libxft-bgra picom-git betterlockscreen brave-bin brillo dragon-drop fsearch 
	gotop-bin bashtop jdownloader2 librewolf-bin quich-git whatsapp-nativefier 
	spotify ytfzf notepadqq arc-darkest-theme-git galculator gparted'

sudo pikaur --noconfirm -S $aurprogs &&
wallp=~/pix/Wallpaper/w/wow
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
sudo mkdir -pv /boot/grub/themes
sudo cp -rf boot/grub/themes/CyberRe /boot/grub/themes/
# using asterisk as separatpr
sudo sed -i 's*#GRUB_THEME="/path/to/gfxtheme"*GRUB_THEME=/boot/grub/themes/CyberRe/theme.txt*g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
cd
sudo mkdir -pv /etc/X11/xorg.conf.d/ /etc/udev/rules.d/
sudo cp $HOME/.dotfiles/etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
sudo cp $HOME/.dotfiles/etc/udev/rules.d/90-backlight.rules /etc/udev/rules.d/90-backlight.rules

#sudo sed -i '/ %wheel ALL=(ALL:ALL) ALL/s/^#//g' /etc/sudoers
#sudo sed -i 's/^[^#]* %wheel ALL=(ALL:ALL) NOPASSWD: ALL/#&/' /etc/sudoers
# Remove no password sudo rights
sudo sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sudo sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sudo sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sudo sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
echo "Post-Installation Ricing Complete! reboot your system to see the changes"
exit

