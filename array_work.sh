#!/bin/bash

modprobe raid456
mdadm --zero-superblock --force /dev/sd{c,d,e,f,g}

for k in c d e f g; do
  parted -s /dev/sd$k mklabel gpt
  parted /dev/sd$k mkpart primary 0% 100%
  sfdisk --change-id /dev/sd$k 1 fd;
done

#Создаем массив RAID5
mdadm --create --verbose /dev/md1 -e 0.90 -l 5 -n 4 /dev/sd{c,d,e,f}1

#Создаем GPT раздел
parted -s /dev/md1 mklabel gpt

#Создаем разделы
parted /dev/md1 mkpart primary ext4 0% 20%
parted /dev/md1 mkpart primary ext4 20% 40%
parted /dev/md1 mkpart primary ext4 40% 60%
parted /dev/md1 mkpart primary ext4 60% 80%
parted /dev/md1 mkpart primary ext4 80% 100%

#Сохраняем конфиг RAID
mdadm --detail --scan --verbose > /etc/mdadm.conf

mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.old
dracut -f /boot/initramfs-$(uname -r).img

#Форматируем разделы и монтируем их

for i in $(seq 1 5); do
  mkfs.ext4 /dev/md1p$i;
  mkdir -p /raid/p$i;
  echo "$(blkid -o export /dev/md1p$i | grep ^UUID=) /raid/p$i                        ext4     rw,exec,auto,nouser        1 2" >> /etc/fstab
done
mount -a

#Сгенерируем файл
dd if=/dev/urandom of=/raid/p3/testfile bs=10M count=3

#Сломаем один из дисков (/dev/sdd)
mdadm /dev/md1 --fail /dev/sdd