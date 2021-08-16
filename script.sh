#!/bin/bash

mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}

#Копируем структура диска sda->sdb
sfdisk -d /dev/sda | sfdisk -f /dev/sdb

modprobe linear
modprobe raid1

#Создаем raid1 из /dev/sdb1 и несуществующего диска
mdadm --create --verbose /dev/md0 -e 0.90 -l 1 -n 2 missing /dev/sdb1

#Форматируем /dev/md0
mkfs.xfs /dev/md0

#Монтируем /dev/md0
mount /dev/md0 /mnt/

#Сохраняем конфигурацию mdadm.conf
mkdir /etc/mdadm
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

#Прописываем загрузку с /dev/md0 в fstab и grub 

sed -i -e "s/$(blkid -o value /dev/sda1 | grep -)/$(blkid -o value /dev/md0 | grep -)/g" /etc/fstab
sed -i -e "s/hd0/hd1/g" /boot/grub2/grub.cfg
sed -i -e "s/$(blkid -o value /dev/sda1 | grep -)/$(blkid -o value /dev/md0 | grep -)/g" /boot/grub2/grub.cfg

#Обновляем загрузчик
dracut -f /boot/initramfs-3.10.0-1127.el7.x86_64.img

cd /

#Переносим систему на /dev/md0
cp -dpRx / /mnt/

grub2-install /dev/sdb