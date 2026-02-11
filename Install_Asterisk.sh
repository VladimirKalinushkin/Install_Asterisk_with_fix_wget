#!/bin/bash


#========Apt install packages============
apt update
apt install -y wget curl tar ca-certificates curl gnupg cron ufw \
    gcc g++ automake autoconf libtool make libncurses5-dev flex bison patch linux-headers-$(uname -r) \
    sqlite3 libsqlite3-dev libnewt-dev build-essential zlib1g-dev \
    unixodbc-dev unixodbc


timedatectl set-timezone Europe/Moscow

apt -y install chrony
systemctl start chrony
systemctl enable chrony

apt install -y ufw
ufw enable
ufw allow 5060
ufw allow 5061
ufw allow 10000:20000/udp

#=======================================

#=====Download nd configure files=======
# 
# If you want download Asterisk myself, use this script:
# 
# while true
# do
#     wget \
#     --no-check-certificate \
#     --timeout=0 \
#     --tries=1 \
#     --read-timeout=2 \
#     --user-agent="Mozilla/5.0" \
#    -c \
#    -O asterisk.tar.gz \
#    https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz
# 
#     if [ $? -eq 0 ]; then
#         echo "Загрузка завершена!"
#         break
#     else
#         echo "Попытка неудачна, повторяем..."
#         sleep 1
#     fi
# done

cp Lib_Asterisk_Main/asterisk-20-current.tar.gz asterisk-20-current.tar.gz
tar -xzf asterisk-20-current.tar.gz



#=======================================

#===========Make========================

cd asterisk-*/

./contrib/scripts/install_prereq install
make distclean
# ./contrib/scripts/get_mp3_source.sh
./configure
make menuselect
make
   
cd ..

cp ./Includes/Sounds/* asterisk-20.18.2/sounds/
cp ./Includes/Make_feauched/sounds/Makefile asterisk-20.18.2/sounds/Makefile

cd asterisk-*/

make install
make samples
make config
ldconfig

#=======================================

#========Configure======================

# The first: most to do it - 
# 
# nano /etc/default/asterisk
# 
# AST_USER="asterisk" 
# AST_GROUP="asterisk"
# 
# nano /etc/asterisk/asterisk.conf
# 
# 
# runuser = asterisk              ; The user to run as.
# rungroup = asterisk             ; The group to run as. 
# 

vim /etc/default/asterisk
vim /etc/asterisk/asterisk.conf


#=======================================

#=============Configure users===========

groupadd asterisk
useradd asterisk -m
useradd -r -d /var/lib/asterisk -g asterisk asterisk
usermod -aG audio,dialout asterisk


useradd -r -d /var/lib/asterisk -g asterisk asterisk
chown -R asterisk:asterisk /etc/asterisk
chown -R asterisk:asterisk /var/{lib,log,spool,run}/asterisk
chown -R asterisk:asterisk /usr/lib/asterisk

#=======================================

#========Start Asterisk=================

systemctl start asterisk
systemctl enable asterisk

#=======================================

#==Configure dialplan nd second start===

cd ..


sed -i 's";\[radius\]"\[radius\]"g' /etc/asterisk/cdr.conf
sed -i 's";radiuscfg => /usr/local/etc/radiusclient-ng/radiusclient.conf"radiuscfg => /etc/radcli/radiusclient.conf"g' /etc/asterisk/cdr.conf


cp /etc/asterisk/pjsip.conf /etc/asterisk/pjsip.conf_backup
cp /etc/asterisk/extensions.conf /etc/asterisk/extensions.conf_backup

echo > /etc/asterisk/pjsip.conf
echo > /etc/asterisk/extensions.conf


cp ./Includes/Examples/pjsip_example.conf /etc/asterisk/pjsip.conf
cp ./Includes/Examples/extensions_example.conf /etc/asterisk/extensions.conf

chown -R asterisk:asterisk /etc/asterisk
chown -R asterisk:asterisk /var/{lib,log,spool,run}/asterisk
chown -R asterisk:asterisk /usr/lib/asterisk


systemctl restart asterisk
systemctl status asterisk

#=============Clear=====================

rm -rf asterisk-20-current.tar.gz
rm -rf asterisk-20.18.2

#=======================================


