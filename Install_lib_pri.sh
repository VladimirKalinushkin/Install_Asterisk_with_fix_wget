#!/bin/bash


cp libpri-1-current.tar.gz ~/libpri-1-current.tar.gz

cd ~
tar -xvf libpri-*.tar.gz
rm -rf libpri-1-current.tar.gz
cd libpri-*/


make
make install


