#!/sbin/ash
#base
sed -i "/PasswordAuth yes/s/#//g" /etc/ssh/sshd_config
rc-service sshd restart
adduser s -G wheel
echo "https://dl-cdn.alpinelinux.org/alpine/edge/main
https://dl-cdn.alpinelinux.org/alpine/edge/community
https://dl-cdn.alpinelinux.org/alpine/edge/testing" > /etc/apk/repositories
apk update && apk upgrade
apk add doas curl wget neovim git util-linux pciutils usbutils coreutils binutils findutils grep bash bash-doc bash-completion udisks2 udisks2-doc bash bash-doc bash-completion
echo 'permit persist :wheel' > /etc/doas.conf
chsh root -s /bin/bash
chsh s -s /bin/bash
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
command="/sbin/update"
command_args' > /etc/init.d/update
chmod +x /etc/init.d/update
rc-update add update default
#update exec
echo 'if [ -f /root/.config/alias ]; then
source "/root/.config/alias"
fi
for prog in $(ls /root/chroot/arch/bin/)
do
if [[ ! $(cat /root/chroot/exclude) == *$prog* ]]; then
ln -s /root/chroot/arch/usr/bin/$prog /sbin/$prog
fi
done
echo "pacman -Syyu --noconfirm" | doas arch-chroot /root/chroot/arch
apk update && apk upgrade' > /sbin/update
chmod +x /sbin/update
#alias exec
mkdir -p /root/.config
echo 'alias oports="netstat -tulpn | grep LISTEN"
alias eal="doas arch-chroot /root/chroot/arch"
alias pac="shift; echo pacman\"$@\" | doas arch-chroot /root/chroot/arch"
alias nvi="nvim"' > /root/.config/alias
chmod +x /root/.config/alias
echo 'addgnupghome
addpart
agetty
applygnupgdefaults
arch-chroot
argon2
arpd
arping
arptables-nft
arptables-nft-restore
arptables-nft-save
asn1Coding
asn1Decoding
asn1Parser
attr
audisp-remote
audisp-syslog
audispd-zos-remote
auditctl
auditd
augenrules
aulast
aulastlog
aureport
ausearch
ausyscall
autopoint
autrace
auvirt
awk
b2sum
badblocks
base32
base64
basename
basenc
bash
bashbug
blkdeactivate
blkdiscard
blkid
blkzone
blockdev
bootctl
bridge
brotli
bsdcat
bsdcpio
bsdtar
bunzip2
busctl
bzcat
bzdiff
bzgrep
bzip2
bzip2recover
bzmore
c_rehash
cal
capsh
captest
captoinfo
cat
catchsegv
certtool
cfdisk
chacl
chage
chattr
chcon
chcpu
chfn
chgpasswd
chgrp
chmem
chmod
choom
chown
chpasswd
chroot
chrt
chsh
chvt
cksum
clear
clockdiff
col
colcrt
colrm
column
comm
compile_et
coredumpctl
cp
croco-0.6-config
cryptsetup
cryptsetup-reencrypt
csplit
csslint-0.6
ctrlaltdel
ctstat
curl
curl-config
cut
date
dbus-cleanup-sockets
dbus-daemon
dbus-launch
dbus-monitor
dbus-run-session
dbus-send
dbus-test-tool
dbus-update-activation-environment
dbus-uuidgen
dcb
dd
deallocvt
debugfs
delpart
depmod
derb
devlink
df
dir
dircolors
dirmngr
dirmngr-client
dirname
dmesg
dmeventd
dmsetup
dmstats
du
dumpe2fs
dumpkeys
dumpsexp
e2freefrag
e2fsck
e2image
e2label
e2mmpstatus
e2scrub
e2scrub_all
e2undo
e4crypt
e4defrag
ebtables-nft
ebtables-nft-restore
ebtables-nft-save
echo
egrep
eject
env
envsubst
escapesrc
expand
expiry
expr
factor
faillock
faillog
fallocate
false
fdisk
fgconsole
fgrep
file
filecap
filefrag
fincore
find
findfs
findmnt
flock
fmt
fold
free
fsck
fsck.cramfs
fsck.ext2
fsck.ext3
fsck.ext4
fsck.minix
fsfreeze
fstrim
fuser
gapplication
gawk
gawk-5.1.1
gdbus
gdbus-codegen
genbrk
gencat
genccode
gencfu
gencmn
gencnval
gendict
genfstab
genl
genl-ctrl-list
gennorm2
genrb
gensprep
getcap
getconf
getent
getfacl
getfattr
getkeycodes
getopt
getpcaps
gettext
gettext.sh
gettextize
gio
gio-querymodules
glib-compile-resources
glib-compile-schemas
glib-genmarshal
glib-gettextize
glib-mkenums
gnutls-cli
gnutls-cli-debug
gnutls-serv
gobject-query
gpasswd
gpg
gpg-agent
gpg-connect-agent
gpg-error
gpg-error-config
gpg-wks-server
gpg2
gpgconf
gpgme-config
gpgme-json
gpgme-tool
gpgparsemail
gpgrt-config
gpgscm
gpgsm
gpgsplit
gpgtar
gpgv
gpgv2
grep
gresource
groupadd
groupdel
groupmems
groupmod
groups
grpck
grpconv
grpunconv
gsettings
gss-client
gss-server
gtester
gtester-report
gunzip
gzexe
gzip
halt
hardlink
head
hexdump
hmac256
homectl
hostid
hostnamectl
hwclock
i386
iconv
iconvconfig
icu-config
icuexportdata
icuinfo
icupkg
id
idiag-socket-details
idn2
ifcfg
ifstat
infocmp
infotocap
init
insmod
install
integritysetup
ionice
ip
ip6tables
ip6tables-apply
ip6tables-legacy
ip6tables-legacy-restore
ip6tables-legacy-save
ip6tables-nft
ip6tables-nft-restore
ip6tables-nft-save
ip6tables-restore
ip6tables-restore-translate
ip6tables-save
ip6tables-translate
ipcmk
ipcrm
ipcs
iptables
iptables-apply
iptables-legacy
iptables-legacy-restore
iptables-legacy-save
iptables-nft
iptables-nft-restore
iptables-nft-save
iptables-restore
iptables-restore-translate
iptables-save
iptables-translate
iptables-xml
irqtop
isosize
join
journalctl
k5srvutil
kadmin
kadmin.local
kadmind
kbd_mode
kbdinfo
kbdrate
kbxutil
kdb5_ldap_util
kdb5_util
kdestroy
kernel-install
key.dns_resolver
keyctl
kill
killall
kinit
klist
kmod
kpasswd
kprop
kpropd
kproplog
krb5-config
krb5-send-pr
krb5kdc
ksba-config
ksu
kswitch
ktutil
kvno
last
lastb
lastlog
ldattach
ldconfig
ldd
less
lessecho
lesskey
libassuan-config
libgcrypt-config
link
linux32
linux64
ln
lnstat
loadkeys
loadunimap
locale
locale-gen
localectl
localedef
logger
login
loginctl
logname
logsave
look
losetup
ls
lsattr
lsblk
lscpu
lsipc
lsirq
lslocks
lslogins
lsmem
lsmod
lsns
lspci
lz4
lz4c
lz4cat
lzcat
lzcmp
lzdiff
lzegrep
lzfgrep
lzgrep
lzless
lzma
lzmadec
lzmainfo
lzmore
machinectl
makeconv
makedb
makepkg
makepkg-template
mapscrn
mcookie
md5sum
memusage
memusagestat
mesg
mk_cmds
mkdir
mke2fs
mkfifo
mkfs
mkfs.bfs
mkfs.cramfs
mkfs.ext2
mkfs.ext3
mkfs.ext4
mkfs.minix
mkhomedir_helper
mklost+found
mknod
mkswap
mktemp
modinfo
modprobe
more
mount
mountpoint
mpicalc
msgattrib
msgcat
msgcmp
msgcomm
msgconv
msgen
msgexec
msgfilter
msgfmt
msggrep
msginit
msgmerge
msgunfmt
msguniq
mtrace
mv
namei
ncursesw6-config
netcap
nettle-hash
nettle-lfib-stream
nettle-pbkdf2
networkctl
newgidmap
newgrp
newuidmap
newusers
nf-ct-add
nf-ct-events
nf-ct-list
nf-exp-add
nf-exp-delete
nf-exp-list
nf-log
nf-monitor
nf-queue
nfbpf_compile
nfnl_osf
ngettext
nice
ninfod
nl
nl-addr-add
nl-addr-delete
nl-addr-list
nl-class-add
nl-class-delete
nl-class-list
nl-classid-lookup
nl-cls-add
nl-cls-delete
nl-cls-list
nl-fib-lookup
nl-link-enslave
nl-link-ifindex2name
nl-link-list
nl-link-name2ifindex
nl-link-release
nl-link-set
nl-link-stats
nl-list-caches
nl-list-sockets
nl-monitor
nl-neigh-add
nl-neigh-delete
nl-neigh-list
nl-neightbl-list
nl-pktloc-lookup
nl-qdisc-add
nl-qdisc-delete
nl-qdisc-list
nl-route-add
nl-route-delete
nl-route-get
nl-route-list
nl-rule-list
nl-tctree-list
nl-util-addr
nohup
nologin
nproc
npth-config
nscd
nsenter
nstat
numfmt
ocsptool
od
oomctl
openssl
openvt
p11-kit
p11tool
pacman
pacman-conf
pacman-db-upgrade
pacman-key
pacstrap
pam_namespace_helper
pam_timestamp_check
partx
passwd
paste
pathchk
pcap-config
pcprofiledump
pcre-config
pcre2-config
pcre2grep
pcre2test
pcregrep
pcretest
peekfd
pgrep
pidof
pinentry
pinentry-curses
pinentry-emacs
pinentry-gnome3
pinentry-gtk-2
pinentry-qt
pinentry-tty
ping
pinky
pivot_root
pkcs1-conv
pkgdata
pkill
pldd
pluginviewer
pmap
portablectl
poweroff
pr
printenv
printf
prlimit
prtstat
ps
pscap
psfaddtable
psfgettable
psfstriptable
psfxtable
psktool
psl
pslog
pstree
pstree.x11
ptx
pwait
pwck
pwconv
pwd
pwdx
pwhistory_helper
pwunconv
pzstd
rarpd
raw
rdisc
rdma
readlink
readprofile
realpath
reboot
recode-sr-latin
rename
renice
repo-add
repo-elephant
repo-remove
request-key
reset
resize2fs
resizecons
resizepart
resolvectl
rev
rfkill
rm
rmdir
rmmod
routef
routel
rtacct
rtcwake
rtmon
rtpr
rtstat
runcon
runuser
sasldblistusers2
saslpasswd2
sclient
scmp_sys_resolver
script
scriptlive
scriptreplay
secret-tool
sed
seq
setarch
setcap
setfacl
setfattr
setfont
setkeycodes
setleds
setmetamode
setpci
setpriv
setsid
setterm
setvtrgb
sexp-conv
sfdisk
sg
sh
sha1sum
sha224sum
sha256sum
sha384sum
sha512sum
showconsolefont
showdb
showjournal
showkey
showstat4
showwal
shred
shuf
shutdown
sim_client
sim_server
slabtop
sleep
sln
sort
sotruss
split
sprof
sqldiff
sqlite3
srptool
ss
sserver
stat
stdbuf
stty
su
sulogin
sum
swaplabel
swapoff
swapon
switch_root
sync
sysctl
systemctl
systemd-analyze
systemd-ask-password
systemd-cat
systemd-cgls
systemd-cgtop
systemd-creds
systemd-cryptenroll
systemd-delta
systemd-detect-virt
systemd-dissect
systemd-escape
systemd-firstboot
systemd-hwdb
systemd-id128
systemd-inhibit
systemd-machine-id-setup
systemd-mount
systemd-notify
systemd-nspawn
systemd-path
systemd-repart
systemd-resolve
systemd-run
systemd-socket-activate
systemd-stdio-bridge
systemd-sysext
systemd-sysusers
systemd-tmpfiles
systemd-tty-ask-password-agent
systemd-umount
tabs
tac
tail
tar
taskset
tc
tee
test
testpkg
tic
timedatectl
timeout
tipc
tload
toe
top
touch
tput
tr
tracepath
true
truncate
trust
tset
tsort
tty
tune2fs
tzselect
uclampset
uconv
udevadm
ul
umount
uname
uname26
uncompress
unexpand
unicode_start
unicode_stop
uniq
unix_chkpwd
unix_update
unlink
unlz4
unlzma
unshare
unxz
unzstd
update-ca-trust
update-pciids
uptime
useradd
userdbctl
userdel
usermod
users
utmpdump
uuclient
uuidd
uuidgen
uuidparse
uuserver
vdir
vdpa
vercmp
veritysetup
vigr
vipw
vlock
vmstat
w
wall
watch
watchgnupg
wc
wdctl
whereis
who
whoami
wipefs
write
x86_64
xargs
xgettext
xml2-config
xmlcatalog
xmllint
xmlwf
xtables-legacy-multi
xtables-monitor
xtables-nft-multi
xtrace
xz
xzcat
xzcmp
xzdec
xzdiff
xzegrep
xzfgrep
xzgrep
xzless
xzmore
yat2m
yes
zcat
zcmp
zdiff
zdump
zegrep
zfgrep
zforce
zgrep
zic
zless
zmore
znew
zramctl
zstd
zstdcat
zstdgrep
zstdless' > /root/chroot/exclude
update