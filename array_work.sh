#!/bin/bash

modprobe raid456
mdadm --zero-superblock --force /dev/sd{c,d,e,f,g}

#Создаем массив RAID5
mdadm --create --verbose /dev/md1 -e 1.2 -l 5 -n 4 /dev/sd{c,d,e,f}

#Сохраняем конфиг RAID
echo "DEVICE partitions" > /etc/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm.conf

#Обновляем загрузчик
mv -f /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.old
dracut -f /boot/initramfs-$(uname -r).img

#Создаем GPT раздел
parted -s /dev/md1 mklabel gpt

#Создаем разделы
parted /dev/md1 mkpart primary ext4 0% 20%
parted /dev/md1 mkpart primary ext4 20% 40%
parted /dev/md1 mkpart primary ext4 40% 60%
parted /dev/md1 mkpart primary ext4 60% 80%
parted /dev/md1 mkpart primary ext4 80% 100%


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

#Убираем его из массива
mdadm /dev/md1 --remove /dev/sdd

#Добавляем в массив другой диск
mdadm /dev/md1 --add /dev/sdg