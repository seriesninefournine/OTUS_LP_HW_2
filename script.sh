#!/bin/bash

#Создаем зеркальный том (R1)
zpool create pool_R1 mirror /dev/sd{b,c}

#Создадим несколько пулов с разными алгоритмами сжатия
#И загрузим в них файлы
curl -O http://www.gutenberg.org/ebooks/2600.txt.utf-8

for i in {gzip,gzip-9,zle,lzjb,lz4}; do
  zfs create pool_R1/compress_$i
  zfs set compression=$i pool_R1/compress_$i
  for k in $(seq 1 10); do
    cp 2600.txt.utf-8 /pool_R1/compress_$i/$k.2600.txt.utf-8
  done
  cp -R /etc/ /pool_R1/compress_$i
done

#Вывод команды из которой видно какой из алгоритмов лучше
#[root@server ~]# zfs get compression,compressratio
#NAME                     PROPERTY       VALUE     SOURCE
#pool_R1                  compression    off       default
#pool_R1                  compressratio  2.22x     -
#pool_R1/compress_gzip    compression    gzip      local
#pool_R1/compress_gzip    compressratio  3.60x     -
#pool_R1/compress_gzip-9  compression    gzip-9    local
#pool_R1/compress_gzip-9  compressratio  3.69x     -
#pool_R1/compress_lz4     compression    lz4       local
#pool_R1/compress_lz4     compressratio  2.35x     -
#pool_R1/compress_lzjb    compression    lzjb      local
#pool_R1/compress_lzjb    compressratio  2.08x     -
#pool_R1/compress_zle     compression    zle       local
#pool_R1/compress_zle     compressratio  1.27x     -


#Скачиваем файл от преподавателя и подключаем к zpool
curl -o zfs_task1.tar.gz https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/jg4htf0hk936p3md8mafrrs062pbarem/1630270500000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg
tar -xzf zfs_task1.tar.gz
zpool import ./zpoolexport/filea otus

#Получаем настройки zfs
zfs get type,available,recordsize,checksum,compression,compressratio
#zfs get compression,compressratio
curl -o otus_task2.file https://doc-00-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/69mg21cgr2it7pdikq3met4ie4talroh/1630273500000/16189157874053420687/*/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG
zfs receive otus/storage < otus_task2.file

#Читаем содержимое секретного сообщения
cat $(find /otus/storage -maxdepth 10 -type f -iname "secret_message")
#https://github.com/sindresorhus/awesome
