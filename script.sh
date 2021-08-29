#!/bin/bash
#При составлении скрипта использовались материалы:
#https://otus.ru/lessons/linux-professional/
#https://kamaok.org.ua/?p=1808
#https://habr.com/ru/post/248073/

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y mdadm smartmontools hdparm gdisk nano
yum install -y mdadm smartmontools hdparm gdisk nano mc
sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/#g' /etc/ssh/sshd_config
systemctl restart sshd

@@ -19,6 +19,7 @@ sfdisk -d /dev/sda | sfdisk -f /dev/sdb
#Меняем ИД раздела на Linux raid autodetect
sfdisk --change-id /dev/sdb 1 fd

#Включаем модели для работы в массивами
modprobe raid1

#Создаем raid1 из /dev/sdb1 и несуществующего диска
@@ -45,9 +46,9 @@ mkdir /mnt
#Сохраняем конфигурацию mdadm.conf
#mkdir /etc/mdadm
mdadm --detail --scan --verbose > /etc/mdadm.conf
#echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
#mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
echo "DEVICE partitions" > /etc/mdadm.conf
#mdadm --detail --scan --verbose > /etc/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm.conf
#Прописываем загрузку с /dev/md0 в fstab и grub 
sed -i -e "s/$(blkid -o value /dev/sda1 | grep -)/$(blkid -o value /dev/md0 | grep -)/g" /etc/fstab
sed -i -e "s/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"rd.auto=1 /g" /etc/default/grub
#Обновляем загрузчик
mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.old
dracut -f /boot/initramfs-$(uname -r).img
#Пересоздаем конфигурационный файл GRUB
grub2-mkconfig -o /boot/grub2/grub.cfg
#Устанавливаем загрузчик на оба диска
grub2-install /dev/sdb
grub2-install /dev/sda
#Указываем SELinux на новый диск
touch /.autorelabel
EOF
shutdown -r now
#sfdisk --change-id /dev/sda 1 fd
#mdadm --manage --add /dev/md0 /dev/sda1
