#!/bin/bash
#=================================================
cp -Rf ./.github/tmp/* .
chmod +x openwrt/*.sh
bash diy.sh
