install
lang en_US.UTF-8
keyboard us
timezone Europe/Moscow
network --bootproto=dhcp --hostname=centos7
auth --usershadow --enablemd5
services --enabled=NetwrokManager,sshd
eula --agreed
ignoredisk --only-use=vda
reboot

bootloader --location=mbr
zerombr
clearpart --all --initlabel
part swap --asprimary --fstype="swap"

