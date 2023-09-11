#!/bin/bash
echo "=================== 1 cp -Rf ../.github/tmp/* .========================="
cp -Rf ../lede/.github/tmp/* .  ||true
ls ../lede/.github/tmp
echo '------------ 2 cp -Rf ../.github/tmp/* .-------------------'
cp -Rf ../.github/tmp/* .  ||true
ls ./.github/tmp/
echo '------------- 3 ls------------------'
ls
chmod +x diy.sh
bash diy.sh
