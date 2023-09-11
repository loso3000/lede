#!/bin/bash
#=================================================
cp -Rf ./sc/.github/tmp/* .
chmod +x openwrt/*.sh
mv openwrt/package/pd/luci-theme-catjs   openwrt/package/luci-theme-kucat
bash diy-part1.sh