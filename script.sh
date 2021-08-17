#!/bin/bash

#Чистим на всех дисках информацию о raid
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}

#Копируем структура диска sda->sdb
sfdisk -d /dev/sda | sfdisk -f /dev/sdb

#Меняем ИД раздела на Linux raid autodetect
sfdisk --change-id /dev/sdb 1 fd

#modprobe linear
#modprobe raid1

#Создаем raid1 из /dev/sdb1 и несуществующего диска
mdadm --create --verbose /dev/md0 -e 0.90 -l 1 -n 2 missing /dev/sdb1

#Форматируем /dev/md0
mkfs.xfs /dev/md0

#Монтируем /dev/md0
mount /dev/md0 /mnt/

#Переносим систему в /mnt/
#rsync -axu / /mnt/
rsync -axu --exclude '/mnt' / /mnt/

#Монтируем информацию о текущей системе в наш новый корень и делаем chroot в него

mount -o bind /proc /mnt/proc
mount -o bind /dev /mnt/dev
mount -o bind /sys /mnt/sys
chroot /mnt/ << EOF
mkdir /mnt


#Сохраняем конфигурацию mdadm.conf
#mkdir /etc/mdadm
mdadm --detail --scan > /etc/mdadm.conf
#echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
#mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

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

#sfdisk --change-id /dev/sda 1 fd
#mdadm --manage --add /dev/md0 /dev/sda1