#!/sbin/ash
#base
sed -i "s/#PasswordAuth/PasswordAuth/g" /etc/ssh/sshd_config
rc-service sshd restart
adduser s -G wheel
echo "http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing" > /etc/apk/repositories
apk add doas curl wget neovim git util-linux pciutils usbutils coreutils binutils findutils grep bash bash-doc bash-completion udisks2 udisks2-doc
echo 'permit persist :wheel' > /etc/doas.conf
chsh root -s /sbin/bash
chsh s -s /sbin/bash
#grub
apk del syslinux
apk add grub grub-bios grub-efi efibootmgr
grub-install "/dev/"$(lsblk -S | awk {'print $1'} | sed -n '2 p')
grub-install --target=x86_64-efi --efi-directory=/boot
sed -i "s/TIMEOUT=2/TIMEOUT=0/g" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
#arch
sudo apk add arch-install-scripts
mkdir /root/chroot /root/chroot/arch
cd /root/chroot/
curl -O https://mirrors.edge.kernel.org/archlinux/iso/latest/archlinux-bootstrap-2022.01.01-x86_64.tar.gz
tar xzf archlinux*.tar.gz && rm archlinux*.tar.gz
rm -rf arch
mv root.x86_64 arch
sed -i '/Server = https:\/\/mirror.rackspace.com\/archlinux\/$repo\/os\/$arch/s/#//g' /root/chroot/arch/etc/pacman.d/mirrorlist
sed -i '/CheckSpace/s/#//g' /root/chroot/arch/etc/pacman.conf
echo 'pacman-key --init
pacman-key --populate archlinux
pacman -Syyu --noconfirm' > /root/chroot/arch/.setup.sh
chmod +x /root/chroot/arch/.setup.sh
cat /root/chroot/arch/.setup.sh | arch-chroot /root/chroot/arch
#update service
echo '#!/sbin/openrc-run
description="Update all packages"
description_reload="Updated packages"
command="/sbin/update"' > /etc/init.d/update
chmod +x /etc/init.d/update
rc-update add update default
#update exec
echo 'if [ -f "/root/.config/alias" ]; then
source "/root/.config/alias"
fi
if [ -d "/root/chroot/arch" ]; then
if [ ! -d "/arch" ]; then
ln -s /root/chroot/arch /arch
fi
for prog in $(ls /arch/bin/)
do
if [ ! -f "/sbin/"$prog ]; then
ln -s /arch/bin/$prog /sbin/$prog
fi
done
pac -Syyu --noconfirm
fi
apk update && apk upgrade' > /sbin/update
chmod +x /sbin/update
#alias exec
mkdir -p /root/.config
echo 'alias oports="netstat -tulpn | grep LISTEN"
alias eal="doas arch-chroot /arch"
alias nvi="nvim"' > /root/.config/alias
chmod +x /root/.config/alias