#!/bin/bash
ls -a ../
cp -Rf ../lede/.github/tmp/* .  || true
ls -a ../lede/.github/tmp/*
[ -f ./diy.sh ] || cp -Rf ./.github/tmp/* . 
ls -a ./.github/tmp
chmod +x diy.sh
./diy.sh
ls -a
