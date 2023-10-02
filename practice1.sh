#!/bin/bash


backports() {
          #creating backup of sources.list
          cp /etc/apt/sources.list /etc/apt/sources.list.bak
          #checking of backports and adding if not exist
          repo=backports

          if
          ! grep -q "^deb .*$repo" /etc/apt/sources.list /etc/apt/sources.list.d/*;
          then echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse | sudo tee -a /etc/apt/sources.list
          fi
          #updating
          apt -qq update
}


update() {
         #update packages and upgrade system
         echo -e "\e[33m Updating in process..\e[0m"
         apt update -y && apt upgrade -y
         apt list -u -q 2>/dev/null | grep "/" | cut -d/ -f1 | xargs -n 1 apt -y install
         echo -e "\e[33m Upgrading complete!\e[0m"
}


installApache() {
         #installing and starting Apache2
         echo -e "\e[33m Installing Apache..\e[0m"
         apt install -qy apache2
         sleep 10
         systemctl start apache2
}


installPython() {
         #installing Python
         echo -e "\e[33m Installing Python..\e[0m"
         cd /tmp/
         wget https://www.python.org/ftp/python/3.11.2/Python-3.11.2.tgz
         tar -xzvf Python-3.11.2.tgz && cd Python-3.11.2/
         ./configure --enable-optimizations
         make -j `nproc`
         make altinstall
         apt install -y python3-pip
         python3.11 --version
         echo -e "\e[33m Installation complete!\e[0m" 
}


installSsh() {
         #installing SSH
         if [[ $1 = "-ss" ]]; then
         echo -e "\e[33m Manage SSH Server..\e[0m"
         apt install -y openssh-server
         fi
         
         if [[ $1 = "-ssEnable" ]]; then
         systemctl enable ssh
         systemctl start ssh
         systemctl status ssh
         fi
}


installSmb() {
         #installing SMB
         echo -e "\e[33m Installing SMB..\e[0m"
         apt install -y smbclient
}


mount() {
         echo -e "\e[33m  Проверяю доступность сервера..\e[0m"
         ping -c 1 192.168.1.112 > /dev/null 2>&1
         x="$?"
         echo $x
         if [ $x -eq 0 ]; then
         echo -e "\e[32m  Сервер доступен! =) \e[0m"
         else
         echo -e "\e[31m Сервер не доступен! =( \e[0m"
         fi
         
         #creating config for smbclient
         touch ~/.credentials
         tee -a ~/.credentials > /dev/null <<EOT
         username=VM
         password=12345678
         EOT
         chmod 600 ~/.credentials

         sleep 1

         #creating mounting point
         if [ -d /mnt/Distr ]; then
         echo -e "\e[32m Точка монтирования обнаружена! \e[0m"
         else
         echo -e "\e[31m Точка монтирования не обнаружена! Создаю... \e[0m"
         mkdir /mnt/Distr
         fi

         cd /mnt/Distr > /dev/null 2>&1
         y="$?"
         echo $y

         #mounting net source
         if [ $y -eq 0 ]; then
         echo -e "\e[31m Смонтировано! \e[0m"
         else
         echo -e "\e[33m Монтирую... \e[0m"
         mount -t cifs -o credentials=/home/kenny/.credentials,iocharset=utf8,file_mode=0777,dir_mode=0777 //192.168.1.112/Distr /mnt/Distr
         sleep 1
         echo -e "\e[32m  Смонтированно. Все! \e[0m"
         fi
         
         #automount
         echo //192.168.1.112/Distr /mnt/Distr cifs user,rw,credentials=/home/kenny/.credentials,iocharset=utf8,nofail,_netdev 0 0 | sudo tee -a /etc/fstab
}

         #RUN
         backports
	 update
	 installApache
	 installPython
	 installSsh
	 installSmb 
	 mount
