# Домашняя работа №2 курса Otus Linux.Professional  
## Сборка RAID1 при запуске виртуальной машины

При запуске vagrant файла установочный скрипт script.sh собирает RAID1 из одного диска, переносит работающею систему на него, а затем загружает ОС с этого массива  

После перезагрузки системы необходимо запустить с правами root скрипт script2.sh для подключения диска на котором ранее была ОС к существующему массиву 
Скрипт array_work.sh собирает RAID5, переводит один из дисков (/dev/sdd) в режим ошибки и заменяет его другим (/dev/sdg).