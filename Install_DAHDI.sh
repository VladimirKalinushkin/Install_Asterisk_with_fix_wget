#!/bin/bash


apt install -y gcc g++ automake autoconf libtool make libncurses5-dev flex bison patch linux-headers-$(uname -r) \
    sqlite3 libsqlite3-dev libnewt-dev build-essential zlib1g-dev \
    unixodbc-dev unixodbc

cp dahdi-linux-complete-current.tar.gz ~/dahdi-linux-complete-current.tar.gz

cd ~
tar -xvf dahdi-linux-complete-current.tar.gz
rm -rf dahdi-linux-complete-current.tar.gz
cd dahdi-linux-complete-*/


make
make install
make config


