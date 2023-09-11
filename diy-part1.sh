#!/bin/bash
#=================================================
cp -Rf ../lede/.github/tmp/* .  ||true
ls ../lede/.github/tmp
echo '-------------------------------'
cp -Rf ../.github/tmp/* .  ||true
ls ./.github/tmp/
echo '-------------------------------'
ls
chmod +x diy.sh
bash diy.sh
