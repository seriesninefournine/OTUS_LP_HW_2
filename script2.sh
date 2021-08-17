#!/bin/bash

#Меняем ИД раздела на Linux raid autodetect
sfdisk --change-id /dev/sda 1 fd

#Добавляем в рэйд диск на котором ранее была система
mdadm --manage --add /dev/md0 /dev/sda1