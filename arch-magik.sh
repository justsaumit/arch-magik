#!/bin/sh

# Prerequisites:
# pacman -Sy git vim
# make a curl link instead!1
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
reflector --verbose --sort rate -l 15 --save /etc/pacman.d/mirrorlist
#reflector --verbose -c $country --sort rate -l 15 --save /etc/pacman.d/mirrorlist
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
pacman --noconfirm -Sy grub efibootmgr mtools dosfstools
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH-LINUX
sed -i 's/quiet/pci=noaer/g' /etc/default/grub
sed -i 's/auto/1920x1080x32/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

pacman --noconfirm --needed -Sy hyprland xdg-desktop-portal-hyprland waybar wl-clipboard wf-recorder \
     gnu-free-fonts ttf-ubuntu-mono-nerd ttf-jetbrains-mono-nerd ttf-joypixels ttf-font-awesome ttf-opensans \
     mpv zathura zathura-pdf-mupdf highlight ffmpeg ffmpegthumbnailer imagemagick libsixel \
     vi vim fzf man-db filezilla firefox ntfs-3g htop nvtop xorg-xhost \
     zip unzip unrar p7zip brightnessctl redshift thunar qt5-wayland qt6-wayland \
     git zsh bc pipewire pipewire-pulse pulsemixer wireplumber rsync libreoffice-fresh \
     ranger libnotify dunst wget jq aria2 bat cowsay neofetch emacs neovim qutebrowser \
     dhcpcd wpa_supplicant networkmanager net-tools ncdu pamixer mpd ncmpcpp \
     zsh-syntax-highlighting tmux pass pass-otp libconfig \
     polkit polkit-gnome trash-cli geoip gparted discord bluez bluez-utils yt-dlp ytfzf &&
#xorg-server xorg-xinit xorg-xkill xorg-xbacklight sxiv xwallpaper python-pywal ueberzug unclutter xclip maim xdotool flameshot sxhkd

systemctl enable NetworkManager.service
sed -i '/ %wheel ALL=(ALL:ALL) ALL/s/^#//g' /etc/sudoers
echo "Enter Username: "
read username
useradd -m -G wheel -s /bin/bash $username
passwd $username
echo "Pre-Installation Finish Reboot now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
echo "Arch Installation is complete!"
exit

#part3
printf '\033c'
cd $HOME
git clone https://github.com/justsaumit/.dotfiles.git

# yay: AUR helper
cd $HOME
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd
aurprogs='waybar-hyprland-git wpaperd brave-bin brillo dragon-drop fsearch arc-darkest-theme-git
	lxappearance element-desktop telegram-desktop whatsapp-nativefier
        gotop-bin btop bashtop jdownloader2 librewolf-bin quich-git spotifywm
	notepadqq galculator pfetch swaylock-effects-git tessen vscodium-bin
        wlr-randr tofi simple-mtpfs downgrade flameshot-git'
nvidia='nvidia nvidia-prime nvidia-utils nvidia-settings'
virt='libvirt qemu virt-manager ebtables libguestfs dnsmasq vde2 bridge-utils openbsd-netcat'
yay --noconfirm -S $aurprogs &&

read -p "Do you wish to install nvidia packages? [y/n]" answer
if [[ $answer = y ]] ; then
	yay -S $nvidia
fi
read -p "Do you wish to install virtualization packages? [y/n]" answer
if [[ $answer = y ]] ; then
	yay -S $virt
fi
wallp="$HOME/pix/Wallpaper/w/wow"
btrls="$HOME/pix/Wallpaper/betterlockscreen"
mkdir -pv $wallp
mkdir -pv $btrls
cd $wallp
wget https://draconyan.xyz/wallp && unzip wallp
cp -r $wallp/* $btrls

#dotfiles management (Use GNU stow in future or not)
cd ~/.dotfiles
\cp -rf .config/ $HOME
\cp -rf .local/ $HOME
\cp -rf .scripts/ $HOME
\cp -rf .bash_logout .bash_profile .bashrc .xinitrc $HOME
sudo mkdir -pv /boot/grub/themes
sudo cp -rf boot/grub/themes/CyberRe /boot/grub/themes/
# using asterisk as separator
sudo sed -i 's*#GRUB_THEME="/path/to/gfxtheme"*GRUB_THEME=/boot/grub/themes/CyberRe/theme.txt*g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg &&
cd
sudo mkdir -pv /etc/X11/xorg.conf.d/ /etc/udev/rules.d/
sudo cp $HOME/.dotfiles/etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
sudo cp $HOME/.dotfiles/etc/udev/rules.d/90-backlight.rules /etc/udev/rules.d/90-backlight.rules &&
echo "Post-Installation Ricing Complete! reboot your system to see the changes"
exit
exit
