#!/bin/bash
cp -Rf ../lede/.github/tmp/* .  || true
chmod +x diy.sh
./diy.sh
ls -a
