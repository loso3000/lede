#!/bin/bash

# private gitea
gitea=git.cooluc.com
github="github.com"
mirror=https://init.cooluc.com
mirror=raw.githubusercontent.com/coolsnowwolf/lede/master

function git_clone_path() {
          trap 'rm -rf "$tmpdir"' EXIT
          branch="$1" rurl="$2" mv="$3"
          [[ "$mv" != "mv" ]] && shift 2 || shift 3
          rootdir="$PWD"
          tmpdir="$(mktemp -d)" || exit 1
          if [ ${#branch} -lt 10 ]; then
          git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$rurl" "$tmpdir"
          cd "$tmpdir"
          else
          git clone --filter=blob:none --sparse "$rurl" "$tmpdir"
          cd "$tmpdir"
          git checkout $branch
          fi
          if [ "$?" != 0 ]; then
            echo "error on $rurl"
            exit 1
          fi
          git sparse-checkout init --cone
          git sparse-checkout set $@
          [[ "$mv" != "mv" ]] && cp -rn ./* $rootdir/ || mv -n $@/* $rootdir/$@/
          cd $rootdir
}
# export -f git_clone_path
#安装和更新软件包
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local REPO_NAME=$(echo $PKG_REPO | cut -d '/' -f 2)

	rm -rf $(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune)

	git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

	if [[ $PKG_SPECIAL == "pkg" ]]; then
		cp -rf $(find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune) ./
		rm -rf ./$REPO_NAME/
	elif [[ $PKG_SPECIAL == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
	fi
}
is_vip() {
case "${CONFIG_S}" in
     "Vip"*) return 0 ;;
     *) return 1 ;;
esac
}

mkdir -p files/root
mkdir -p files/etc/opkg
mkdir -p files/usr/share
mkdir -p ./package/emortal

[[ -n $TARGET_DEVICE ]] || TARGET_DEVICE="x86_64"
[[ -n $CONFIG_S ]] || CONFIG_S=Vip-Super

rm -rf ./feeds/luci/themes/luci-theme-argon
rm -rf ./feeds/packages/net/mentohust
rm -rf  ./feeds/luci/applications/luci-app-arpbind
#rm -rf  ./feeds/packages/net/wget

rm -rf  ./feeds/packages/net/ddns-scripts

# rm -rf  ./feeds/packages/rust
# rm -rf  ./feeds/packages/lang/rust

rm -rf  ./feeds/packages/net/zsh
rm -rf  ./feeds/packages/net/homebox
rm -rf  ./feeds/packages/net/naiveproxy

#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" ./package/base-files/files/bin/config_generate
# sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" ./package/base-files/files/bin/config_generate

#修改默认主机名
sed -i "s/hostname='.*'/hostname='EzOpWrt'/g" ./package/base-files/files/bin/config_generate
#sed -i "s/ImmortalWrt/EzOpWrt/" {package/base-files/files/bin/config_generate,include/version.mk}
#sed -i "s/ImmortalWrt/EzopWrt/" ./feeds/luci/modules/luci-mod-system/htdocs/luci-static/resources/view/system/flash.js  #改登陆域名
sed -i "s/ImmortalWrt/EzopWrt/g" package/base-files/files/bin/config_generate package/base-files/image-config.in package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc config/Config-images.in Config.in include/u-boot.mk include/version.mk || true
sed -i "s/OpenWrt/EzopWrt/g" package/base-files/files/bin/config_generate package/base-files/image-config.in package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc config/Config-images.in Config.in include/u-boot.mk include/version.mk || true

sed -i '/$(curdir)\/compile:/c\$(curdir)/compile: package/opkg/host/compile' package/Makefile
sed -i "s/DEFAULT_PACKAGES:=/DEFAULT_PACKAGES:=luci-app-advancedplus luci-app-firewall luci-app-package-manager luci-app-upnp luci-app-bypass luci-app-passwall luci-proto-wireguard \
luci-app-netwizard luci-base luci-compat luci-lib-ipkg luci-lib-fs \
coremark wget-ssl curl autocore htop nano zram-swap kmod-lib-zstd kmod-tcp-bbr bash openssh-sftp-server block-mount resolveip ds-lite swconfig luci-app-fan luci-app-filemanager /" include/target.mk

# 移除 SNAPSHOT 标签
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in
sed -i '/CONFIG_BUILDBOT/d' include/feeds.mk
sed -i 's/;)\s*\\/; \\/' include/feeds.mk

#samrtdns
rm -rf ./feeds/luci/applications/luci-app-smartdns
rm -rf ./feeds/luci/applications/luci-app-lucky
rm -rf ./feeds/luci/applications/luci-app-ddns-go
rm -rf ./feeds/luci/applications/luci-app-filetransfer
rm -rf ./feeds/luci/applications/luci-app-fileassistant
rm -rf ./feeds/luci/applications/luci-app-msd_lite
rm -rf ./feeds/luci/applications/luci-app-smartdns
rm -rf ./feeds/luci/applications/luci-app-wolplus
rm -rf ./feeds/luci/applications/luci-app-wrtbwmon

rm -rf ./feeds/luci/applications/luci-app-udpxy
rm -rf ./feeds/luci/applications/luci-app-adguardhome
rm -rf ./feeds/luci/applications/luci-app-mosdns
rm -rf ./feeds/luci/applications/luci-app-passwall
rm -rf ./feeds/luci/applications/luci-app-passwall2


rm -rf  ./feeds/packages/net/wrtbwmon
rm -rf  ./feeds/packages/net/smartdns
rm -rf  ./feeds/packages/net/lucky
rm -rf  ./feeds/packages/net/ddns-go
#istore
rm -rf  ./feeds/jjm2473_apps/homebox
rm -rf  ./feeds/jjm2473_apps/luci-app-homebox
rm -rf  ./feeds/third_party/luci-app-LingTiGameAcc
rm -rf  ./feeds/third_party/luci-app-arpbind
rm -rf  ./feeds/third_party/luci-app-fileassistant
rm -rf  ./feeds/third_party/luci-app-smartdns
rm -rf  ./feeds/third_party/luci-app-socat
rm -rf  ./feeds/third_party/smartdns
rm -rf  ./feeds/third_party/luci-app-netdata
rm -rf  ./feeds/third_party/luci-app-autotimeset
rm -rf ./feeds/openwrt-third/luci-app-netdata
rm -rf ./feeds/openwrt-third/smartdns
rm -rf ./feeds/openwrt-third/luci-app-autotimeset
rm -rf ./feeds/luci/applications/luci-app-autotimeset
rm -rf ./feeds/third/luci-app-autotimeset
rm -rf  ./feeds/packages/ariang
rm -rf  ./feeds/packages/webui-aria2
#error
rm -rf  ./target/linux/ath79

sed -i 's/services/status/g' ./feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
rm -rf  feeds/packages/net/wrtbwmon
rm -rf  ./feeds/luci/applications/luci-app-wrtbwmon 
rm -rf  ./feeds/luci/applications/luci-app-arpbind

rm -rf  ./feeds/packages/devel/binutils   #2410error

rm -rf  ./feeds/luci/applications/luci-app-timecontrol
rm -rf  ./feeds/luci/applications/luci-app-socat
rm -rf  ./feeds/luci/applications/luci-app-fileassistant
rm -rf  ./feeds/luci/applications/luci-app-control-speedlimit
rm -rf  ./feeds/luci/applications/luci-app-syncdial

# rm -rf  ./feeds/packages/net/wget
# mv -rf ./package/wget  ./feeds/packages/net/wget
#aria2
rm -rf ./feeds/packages/net/aria2
rm -rf ./feeds/luci/applications/luci-app-aria2  package/feeds/packages/luci-app-aria2


# Passwall

rm -rf ./feeds/luci/applications/luci-app-ssr-plus  package/feeds/packages/luci-app-ssr-plus
rm -rf ./feeds/luci/applications/luci-app-passwall  package/feeds/packages/luci-app-passwall
rm -rf ./feeds/luci/applications/luci-app-passwall2  package/feeds/packages/luci-app-passwall2

git clone https://github.com/sbwml/openwrt_helloworld  -b v5 ./package/ssr

git clone https://github.com/loso3000/other ./package/add

#oaf 
rm -rf ./feeds/luci/applications/luci-app-appfilter
rm -rf ./feeds/luci/applications/luci-app-filter
rm -rf ./feeds/luci/applications/luci-app-oaf
rm -rf ./feeds/packages/net/open-app-filter
rm -rf  ./feeds/packages/net/oaf
# rm -rf ./package/add/up/tool/OpenAppFilter
# git clone https://github.com/destan19/OpenAppFilter.git ./package/OpenAppFilter
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang


mv -f ./package/add/up/tool/smartdns/luci-app-smartdns ./feeds/luci/applications/luci-app-smartdns
mv -f ./package/add/up/tool/smartdns/smartdns  ./feeds/packages/net/smartdns 

# rm -rf ./package/add/luci-app-mwan3 ./package/add/mwan3
# rm -rf ./feeds/luci/applications/luci-app-mwan3
rm -rf ./feeds/packages/net/mwan3
mv ./package/add/up/tool/mwan3 ./feeds/packages/net/mwan3


#bypass
rm -rf ./package/ssr/luci-app-ssr-plus
# rm -rf ./package/ssr/luci-app-passwall
# rm -rf ./package/ssr/luci-app-passwall2

#rm -rf ./package/ssr/brook
#rm -rf ./package/ssr/chinadns-ng
#rm -rf ./package/ssr/dns2socks
#rm -rf ./package/ssr/dns2tcp
#rm -rf ./package/ssr/pdnsd-alt
#rm -rf ./package/ssr/ipt2socks
#rm -rf ./package/ssr/microsocks
#rm -rf ./package/ssr/lua-neturl
#rm -rf ./package/ssr/naiveproxy
# rm -rf ./package/ssr/redsocks2
# rm -rf ./package/ssr/simple-obfs
# rm -rf ./package/ssr/tcping
# rm -rf ./package/ssr/trojan
# rm -rf ./package/ssr/tuic-client
#rm -rf ./package/ssr/shadowsocks-libev
#rm -rf ./package/ssr/shadowsocks-rust


rm -rf ./package/ssr/mosdns
# rm -rf ./package/ssr/trojan-plus
# rm -rf ./package/ssr/xray-core

#rm -rf ./package/ssr/xray-plugin
# rm -rf ./package/ssr/naiveproxy
#rm -rf ./package/ssr/v2ray-plugin
#rm -rf ./package/ssr/v2ray-core
# rm -rf ./package/ssr/pdnsd
#rm -rf ./package/ssr/lua-neturl
#rm -rf ./package/ssr/redsocks2
#rm -rf ./package/ssr/shadow-tls


 rm -rf ./feeds/packages/net/brook
 rm -rf ./feeds/packages/net/chinadns-ng
 rm -rf ./feeds/packages/net/dns2socks
 rm -rf ./feeds/packages/net/dns2tcp
 rm -rf ./feeds/packages/net/pdnsd-alt
 rm -rf ./feeds/packages/net/hysteria
 rm -rf ./feeds/packages/net/gn
 rm -rf ./feeds/packages/net/ipt2socks
 rm -rf ./feeds/packages/net/microsocks
 rm -rf ./feeds/packages/net/lua-neturl
 rm -rf ./feeds/packages/net/naiveproxy
 rm -rf ./feeds/packages/net/pdnsd
 rm -rf ./feeds/packages/net/redsocks2
 rm -rf ./feeds/packages/net/simple-obfs
 rm -rf ./feeds/packages/net/tcping
 rm -rf ./feeds/packages/net/trojan
 rm -rf ./feeds/packages/net/tuic-client
 rm -rf ./feeds/packages/net/v2ray-geodata

#rm -rf ./feeds/packages/net/shadowsocks-libev
#rm -rf ./feeds/packages/net/shadowsocks-rust
rm -rf ./feeds/packages/net/xray-core
rm -rf ./feeds/packages/net/sing-box
rm -rf ./feeds/packages/net/trojan-plus
rm -rf ./feeds/packages/net/xray-plugin
rm -rf ./feeds/packages/net/naiveproxy
rm -rf ./feeds/packages/net/v2ray-plugin
rm -rf ./feeds/packages/net/v2ray-core
rm -rf ./feeds/packages/net/pdnsd
rm -rf ./feeds/packages/net/lua-neturl
rm -rf ./feeds/packages/net/redsocks2
rm -rf ./feeds/packages/net/shadow-tls

 rm -rf  ./feeds/luci/applications/luci-app-netdata
# mv -f ./package/add/up/netdata ./package/
rm -rf ./feeds/luci/applications/luci-app-socat  ./package/feeds/luci/luci-app-socat
rm -rf ./package/add/up/pass/naiveproxy
rm -rf ./package/add/up/pass/xray-core
rm -rf ./package/add/up/pass/trojan-plus

# 全能推送
rm -rf ./feeds/luci/applications/luci-app-pushbot
git clone https://github.com/zzsj0928/luci-app-pushbot package/luci-app-pushbot
rm -rf ./feeds/luci/applications/luci-app-wechatpush 
git clone https://$github/tty228/luci-app-wechatpush ./feeds/luci/applications/luci-app-wechatpush

git clone  https://github.com/EasyTier/luci-app-easytier ./package/luci-app-easytier
#net eth0
rm -rf ./target/linux/x86/base-files/etc/board.d/99-default_network
rm -rf ./target/linux/x86/base-files/etc/board.d/99-virtualbox_network
curl -fsSL  https://raw.githubusercontent.com/loso3000/other/master/patch/board.d/99-default_network > ./target/linux/x86/base-files/etc/board.d/99-default_network
curl -fsSL  https://raw.githubusercontent.com/loso3000/other/master/patch/board.d/02_network > ./target/linux/x86/base-files/etc/board.d/02_network
# rm -rf $(find ./package/ -type d -regex ".*\(autocore\|automount\|autosamba\|default-settings\).*")
rm -rf ./package/emortal/autocore ./package/emortal/automount  ./package/emortal/autosamba  ./package/emortal/default-settings 
rm -rf ./package/lean/autocore ./package/lean/automount  ./package/lean/autosamba  ./package/lean/default-settings 

rm -rf ./package/add/up/tool/autocore

rm -rf ./package/add/up/pass/xray-core

# Add luci-app-dockerman
rm -rf ./feeds/luci/applications/luci-app-dockerman
# rm -rf ./feeds/luci/applications/luci-app-docker
# rm -rf ./feeds/luci/collections/luci-lib-docker
# mv ./package/add/add/up/docker/docker ./feeds/packages/utils/docker
# mv ./package/add/add/up/docker/dockerd  ./feeds/packages/utils/dockerd 
# mv ./package/add/add/up/docker/docker-compose ./feeds/packages/utils/docker-compose
# sed -i '/sysctl.d/d' feeds/packages/utils/dockerd/Makefile
# sed -i 's,# CONFIG_BLK_CGROUP_IOCOST is not set,CONFIG_BLK_CGROUP_IOCOST=y,g' target/linux/generic/config-5.10
# sed -i 's,# CONFIG_BLK_CGROUP_IOCOST is not set,CONFIG_BLK_CGROUP_IOCOST=y,g' target/linux/generic/config-5.15
# sed -i 's/+dockerd/+dockerd +cgroupfs-mount/' ./package/new/luci-app-dockerman/Makefile
# sed -i '$i /etc/init.d/dockerd restart &' ./package/new/luci-app-dockerman/root/etc/uci-defaults/*
# Docker
rm -rf feeds/luci/applications/luci-app-dockerman
git clone https://git.kejizero.online/zhao/luci-app-dockerman feeds/luci/applications/luci-app-dockerman
rm -rf feeds/packages/utils/{docker,dockerd,containerd,runc}
git clone https://git.kejizero.online/zhao/packages_utils_docker feeds/packages/utils/docker
git clone https://git.kejizero.online/zhao/packages_utils_dockerd feeds/packages/utils/dockerd
git clone https://git.kejizero.online/zhao/packages_utils_containerd feeds/packages/utils/containerd
git clone https://git.kejizero.online/zhao/packages_utils_runc feeds/packages/utils/runc
sed -i '/sysctl.d/d' feeds/packages/utils/dockerd/Makefile
pushd feeds/packages
    curl -s https://raw.githubusercontent.com/oppen321/OpenWrt-Patch/refs/heads/kernel-6.6/docker/0001-dockerd-fix-bridge-network.patch | patch -p1
    curl -s https://raw.githubusercontent.com/oppen321/OpenWrt-Patch/refs/heads/kernel-6.6/docker/0002-docker-add-buildkit-experimental-support.patch | patch -p1
    curl -s https://raw.githubusercontent.com/oppen321/OpenWrt-Patch/refs/heads/kernel-6.6/docker/0003-dockerd-disable-ip6tables-for-bridge-network-by-defa.patch | patch -p1
popd

rm -rf ./package/add/up/docke


#istoreos-files
rm -rf ./package/diy
rm -rf ./package/istoreos-files

cat  patch/banner > ./package/base-files/files/etc/banner
cat  patch/profile > ./package/base-files/files/etc/profile
cat  patch/profiles > ./package/base-files/files/etc/profiles
cat  patch/sysctl.conf > ./package/base-files/files/etc/sysctl.conf

#  coremark
# sed -i '/echo/d' ./feeds/packages/utils/coremark/coremark

rm -rf ./feeds/packages/net/lucky
rm -rf  ./feeds/luci/applications/luci-app-lucky
git clone https://github.com/sirpdboy/luci-app-lucky ./package/lucky
rm -rf ./feeds/packages/net/ddns-go
rm -rf  ./feeds/luci/applications/luci-app-ddns-go
git clone https://github.com/sirpdboy/luci-app-ddns-go ./package/ddns-go

wget -N https://raw.githubusercontent.com/openwrt/packages/master/lang/golang/golang/Makefile -P feeds/packages/lang/golang/golang/


git_clone_path master https://github.com/coolsnowwolf/lede mv target/linux/generic/hack-6.6

rm -rf package/system/fstools
git_clone_path master https://github.com/coolsnowwolf/lede package/system/fstools

rm -rf target/linux/generic/hack-6.6/929-Revert-genetlink* target/linux/generic/hack-6.6/767-net-phy-realtek-add-led*
wget -N https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/generic/pending-6.6/613-netfilter_optional_tcp_window_check.patch -P target/linux/generic/pending-6.6/

# nlbwmon
# sed -i 's/524288/16777216/g' feeds/packages/net/nlbwmon/files/nlbwmon.config
# 可以设置汉字名字
# sed -i '/o.datatype = "hostname"/d' feeds/luci/modules/luci-mod-admin-full/luasrc/model/cbi/admin_system/system.lua
# sed -i '/= "hostname"/d' /usr/lib/lua/luci/model/cbi/admin_system/system.lua

git clone  https://github.com/linkease/nas-packages-luci ./package/nas-packages-luci
git clone  https://github.com/linkease/nas-packages ./package/nas-packages
git clone  https://github.com/linkease/istore ./package/istore
sed -i 's/1/0/g' ./package/nas-packages/network/services/linkease/files/linkease.config
sed -i 's/luci-lib-ipkg/luci-base/g' package/istore/luci/luci-app-store/Makefile

rm -rf ./feeds/packages/net/mosdns
# rm -rf  ./feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
# git clone https://github.com/sbwml/luci-app-mosdns -b v5-lua package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
git clone https://github.com/sbwml/v2ray-geodata feeds/packages/net/v2ray-geodata

# luci-compat - fix translation
sed -i 's/<%:Up%>/<%:Move up%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm
sed -i 's/<%:Down%>/<%:Move down%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm
# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's|/bin/login|/bin/login -f root|' ./feeds/packages/utils/ttyd/files/ttyd.config

sed -i '$a  \
  CONFIG_CPU_FREQ_GOV_POWERSAVE=y \
  CONFIG_CPU_FREQ_GOV_USERSPACE=y \
  CONFIG_CPU_FREQ_GOV_ONDEMAND=y \
  CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y \
  CONFIG_CRYPTO_CHACHA20_NEON=y \
  CONFIG_CRYPTO_CHACHA20POLY1305=y \
  CONFIG_FAT_DEFAULT_IOCHARSET="utf8" \
  ' `find target/linux -path "target/linux/*/config-*"`
  
cp -rf ipq40xx/. ./

# luci
pushd feeds/luci
    # curl -s https://git.kejizero.online/zhao/files/raw/branch/main/patch/luci/0001-luci-mod-status-firewall-disable-legacy-firewall-rul.patch | patch -p1
    curl -fsSL  https://raw.githubusercontent.com/sirpdboy/other/master/patch/0001-luci-mod-status-firewall-disable-legacy-firewall-rul.patch | patch -p1
popd
# uwsgi
sed -i 's,procd_set_param stderr 1,procd_set_param stderr 0,g' feeds/packages/net/uwsgi/files/uwsgi.init
sed -i 's,buffer-size = 10000,buffer-size = 131072,g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's,logger = luci,#logger = luci,g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i '$a cgi-timeout = 600' feeds/packages/net/uwsgi/files-luci-support/luci-*.ini
sed -i 's/threads = 1/threads = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/processes = 3/processes = 4/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/cheaper = 1/cheaper = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini

# UPnP
rm -rf ./package/add/up/luci-app-upnp
rm -rf feeds/{packages/net/miniupnpd,luci/applications/luci-app-upnp}
git clone https://$gitea/sbwml/miniupnpd feeds/packages/net/miniupnpd -b v2.3.7
git clone https://$gitea/sbwml/luci-app-upnp feeds/luci/applications/luci-app-upnp -b main

sed -i "/listen_https/ {s/^/#/g}" package/*/*/*/files/uhttpd.config

sed -i 's/"Argon 主题设置"/"Argon设置"/g' `grep "Argon 主题设置" -rl ./`
sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' `grep "Turbo ACC 网络加速" -rl ./`
sed -i 's/"网络存储"/"存储"/g' `grep "网络存储" -rl ./`
sed -i 's/"USB 打印服务器"/"打印服务"/g' `grep "USB 打印服务器" -rl ./`
sed -i 's/"P910nd - 打印服务器"/"打印服务"/g' `grep "P910nd - 打印服务器" -rl ./`
sed -i 's/"带宽监控"/"监控"/g' `grep "带宽监控" -rl ./`
sed -i 's/实时流量监测/流量/g'  `grep "实时流量监测" -rl ./`
sed -i 's/解锁网易云灰色歌曲/解锁灰色歌曲/g'  `grep "解锁网易云灰色歌曲" -rl ./`
sed -i 's/解除网易云音乐播放限制/解锁灰色歌曲/g'  `grep "解除网易云音乐播放限制" -rl ./`
sed -i 's/家庭云//g'  `grep "家庭云" -rl ./`

sed -i 's/msgstr "挂载 SMB 网络共享"/msgstr "挂载网络共享"/g'  `grep "挂载 SMB 网络共享" -rl ./`


#cifs挂pan
# sed -i '/mcsub_renew.datatype/d'  ./feeds/luci/applications/luci-app-udpxy/luasrc/model/cbi/udpxy.lua  #修复UDPXY设置延时55的错误

#断线不重拨
# sed -i 's/q reload/q restart/g' ./package/network/config/firewall/files/firewall.hotplug

# echo '默认开启 Irqbalance'
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config
# nlbwmon - disable syslog
# sed -i 's/stderr 1/stderr 0/g' feeds/packages/net/nlbwmon/files/nlbwmon.init

git clone https://github.com/yaof2/luci-app-ikoolproxy.git package/luci-app-ikoolproxy
sed -i 's/, 1).d/, 11).d/g' ./package/luci-app-ikoolproxy/luasrc/controller/koolproxy.lua
# Add OpenClash
rm -rf  ./feeds/luci/applications/luci-app-openclash
git clone --depth=1 https://github.com/vernesong/OpenClash package/openclash
sed -i 's/+libcap /+libcap +libcap-bin /' package/openclash/luci-app-openclash/Makefile

rm -rf ./feeds/luci/themes/luci-theme-design
 git clone -b js https://github.com/gngpp/luci-theme-design.git  package/luci-theme-design
rm -rf ./feeds/luci/themes/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon.git  package/luci-theme-argon

# 使用默认取消自动
# sed -i "s/bootstrap/chuqitopd/g" feeds/luci/modules/luci-base/root/etc/config/luci
# sed -i 's/bootstrap/chuqitopd/g' feeds/luci/collections/luci/Makefile
# echo "修改默认主题"
sed -i 's/+luci-theme-bootstrap/+luci-theme-kucat/g' feeds/luci/collections/luci/Makefile
# sed -i "s/luci-theme-bootstrap/luci-theme-$OP_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
# sed -i 's/+luci-theme-bootstrap/+luci-theme-opentopd/g' feeds/luci/collections/luci/Makefile
# sed -i '/set luci.main.mediaurlbase=/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
# sed -i '/set luci.main.mediaurlbase/d' ./package/luci-theme-arn/root/etc/uci-defaults/30_luci-theme-arn
# sed -i '/set luci.main.mediaurlbase/d' feeds/luci/themes/luci-theme-arn/root/etc/uci-defaults/30_luci-theme-arn
# sed -i '/set luci.main.mediaurlbase/d' package/luci-theme-arn/root/etc/uci-defaults/30_luci-theme-arn
# sed -i '/set luci.main.mediaurlbase=/d' feeds/luci/themes/luci-theme-material/root/etc/uci-defaults/30_luci-theme-material
# sed -i '/set luci.main.mediaurlbase=/d' feeds/luci/themes/luci-theme-design/root/etc/uci-defaults/30_luci-luci-theme-design
# sed -i '/set luci.main.mediaurlbase=/d' package/luci-theme-design/root/etc/uci-defaults/30_luci-theme-design

# 取消主题默认设置
# find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;
sed -i '/check_signature/d' ./package/system/opkg/Makefile   # 删除IPK安装签名

#Add x550
git clone https://github.com/shenlijun/openwrt-x550-nbase-t package/openwrt-x550-nbase-t

# netdata
sed -i 's/syslog/none/g' feeds/packages/admin/netdata/files/netdata.conf

# luci-app-filemanager
rm -rf feeds/luci/applications/luci-app-filemanager
git clone https://$github/sbwml/luci-app-filemanager package/new/luci-app-filemanager
# curl - fix passwall `time_pretransfer` check
rm -rf feeds/packages/net/curl
git clone https://$github/sbwml/feeds_packages_net_curl feeds/packages/net/curl

# 修改makefile
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/include\ \.\.\/\.\.\/luci\.mk/include \$(TOPDIR)\/feeds\/luci\/luci\.mk/g' {}
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/include\ \.\.\/\.\.\/lang\/lang\/lang\-package\.mk/include \$(TOPDIR)\/feeds\/packages\/lang\/lang\/golang\-package\.mk/g' {}

# sed -i 's/KERNEL_PATCHVER:=6.1/KERNEL_PATCHVER:=5.4/g' ./target/linux/*/Makefile
# sed -i 's/KERNEL_PATCHVER:=5.15/KERNEL_PATCHVER:=5.4/g' ./target/linux/*/Makefile
# echo '默认开启 Irqbalance'
if  [[ $TARGET_DEVICE == 'x86_64' ]] ;then
VER1="$(grep "KERNEL_PATCHVER:="  ./target/linux/x86/Makefile | cut -d = -f 2)"
CLASH="amd64"
else
VER1="$(grep "KERNEL_PATCHVER:="  ./target/linux/rockchip/Makefile | cut -d = -f 2)"
CLASH="arm64"
fi
if [[ $DATE_S == 'default' ]]; then
   DATA=`TZ=UTC-8 date +%y%m%d%H%M`
   # DATA=`TZ=UTC-8 date +%y%m%d%H%M`
else 
   DATA=$DATE_S
fi
for sh_file in `ls ${GITHUB_WORKSPACE}/openwrt/package/add/common/*.sh`;do
    source $sh_file $CLASH
done

source common/clash.sh $CLASH
source common/tools.sh $CLASH

ver54=`grep "LINUX_VERSION-5.4 ="  include/kernel-5.4 | cut -d . -f 3`
ver515=`grep "LINUX_VERSION-5.15 ="  include/kernel-5.15 | cut -d . -f 3`
ver61=`grep "LINUX_VERSION-6.1 ="  include/kernel-6.1 | cut -d . -f 3`
ver66=`grep "LINUX_VERSION-6.6 ="  include/kernel-6.6 | cut -d . -f 3`
ver612=`grep "LINUX_VERSION-6.12 ="  include/kernel-6.12 | cut -d . -f 3`
date1="${CONFIG_S}-${DATA}_by Sirpdboy"
if [ "$VER1" = "5.4" ]; then
date2="EzOpWrt ${CONFIG_S}-${DATA}-${VER1}.${ver54}_by Sirpdboy"
date1="${CONFIG_S}-${DATA}-${VER1}.${ver54}"
elif [ "$VER1" = "5.15" ]; then
date2="EzOpWrt ${CONFIG_S}-${DATA}-${VER1}.${ver515}_by Sirpdboy"
date1="${CONFIG_S}-${DATA}-${VER1}.${ver515}"
elif [ "$VER1" = "6.1" ]; then
date2="EzOpWrt ${CONFIG_S}-${DATA}-${VER1}.${ver61}_by Sirpdboy"
date1="${CONFIG_S}-${DATA}-${VER1}.${ver61}"
elif [ "$VER1" = "6.6" ]; then
date2="EzOpWrt ${CONFIG_S}-${DATA}-${VER1}.${ver66}_by Sirpdboy"
date1="${CONFIG_S}-${DATA}-${VER1}.${ver66}"
elif [ "$VER1" = "6.12" ]; then
date2="EzOpWrt ${CONFIG_S}-${DATA}-${VER1}.${ver612}_by Sirpdboy"
date1="${CONFIG_S}-${DATA}-${VER1}.${ver612}"
fi
echo "${date1}" > ./package/base-files/files/etc/ezopenwrt_version
echo "${date2}" >> ./package/base-files/files/etc/banner
echo '---------------------------------' >> ./package/base-files/files/etc/banner
[ -f ./files/root/.zshrc ] || mv -f ./package/add/patch/z.zshrc ./files/root/.zshrc
[ -f ./files/root/.zshrc ] || curl -fsSL  https://raw.githubusercontent.com/loso3000/other/master/patch/z.zshrc > ./files/root/.zshrc
[ -f ./files/etc/profiles ] || mv -f ./package/add/patch/profiles ./files/etc/profiles
[ -f ./files/etc/profiles ] || curl -fsSL  https://raw.githubusercontent.com/loso3000/other/master/patch/profiles > ./files/etc/profiles

cat>buildmd5.sh<<-\EOF
#!/bin/bash

r_version=`cat ./package/base-files/files/etc/ezopenwrt_version`
# gzip bin/targets/*/*/*.img | true

pushd bin/targets/*/*/
rm -rf   config.buildinfo
rm -rf   feeds.buildinfo
rm -rf   *.manifest
rm -rf   *rootfs.tar.gz
rm -rf   *generic-squashfs-rootfs.img*
rm -rf   *generic-rootfs*
rm -rf  *generic.manifest
rm -rf  sha256sums
rm -rf version.buildinfo
rm -rf *generic-ext4-rootfs.img*
rm -rf  *generic-ext4-combined-efi.img*
rm -rf  *generic-ext4-combined.img*
rm -rf  profiles.json
rm -rf  *kernel.bin
# BINDIR=`pwd`
sleep 2

mv  *generic-squashfs-combined.img.gz       EzOpWrt-${r_version}-${TARGET_DEVICE}-dev.img.gz   
mv  *generic-squashfs-combined-efi.img.gz   EzOpWrt-${r_version}-${TARGET_DEVICE}-dev-efi.img.gz
md5_EzOpWrt=EzOpWrt-${r_version}-${TARGET_DEVICE}-dev.img.gz   
md5_EzOpWrt_uefi=EzOpWrt-${r_version}-${TARGET_DEVICE}-dev-efi.img.gz

ip=` cat  package/base-files/files/bin/config_generate | grep "n) ipad" |awk -F '\"' '{print $2}'`
[[ -n $ip ]] || ip=` cat package/base-files/luci2/bin/config_generate | grep "n) ipad" |awk -F '\"' '{print $2}'`
[[ -n $ip ]] || ip=192.168.10.1
#md5
[ -f ${md5_EzOpWrt}] && md5sum ${md5_EzOpWrt} > EzOpWrt_dev.md5 &&echo "ip=$ip" >> EzOpWrt_dev.md5
[ -f ${md5_EzOpWrt_uefi} ] && md5sum ${md5_EzOpWrt_uefi} > EzOpWrt_dev-efi.md5 &&echo "ip=$ip" >> EzOpWrt_dev-efi.md5

if [ ${CONFIG_S} = "Vip-Super" ] ; then
cp ../../../../ezotafooter  ./ota.footer
cp ../../../../ezverlatest   ./ver.latest 
fi
popd

EOF

cat>bakkmod.sh<<-\EOF
#!/bin/bash
kmoddirdrv=./files/etc/kmod.d/drv
kmoddirdocker=./files/etc/kmod.d/docker
bakkmodfile=./kmod.source
cp -rf ./patch/list.txt $bakkmodfile
nowkmodfile=./files/etc/kmod.now
mkdir -p $kmoddirdrv 2>/dev/null
mkdir -p $kmoddirdocker 2>/dev/null
while IFS= read -r line; do  
    cp -v $(find bin/ -type f -name "*${line}*") $kmoddirdrv
    echo "$line"  
        a=`find ./bin/ -name "$line" `
    echo $a
    if [ -z "$a" ]; then
        echo "no find: $line"
    else
        cp -f $a $kmoddirdrv
	echo $line >> $nowkmodfile
        if [ $? -eq 0 ]; then
            echo "cp ok: $line"
        else
            echo "no cp:$line"
        fi
    fi
done < "$bakkmodfile"
    # find ./bin/ -name  $file | xargs -i cp -f {}  $kmoddirdrv
    # cp -v $(find bin/targets/ -type f -name "*${FIRMWARE_TYPE}*") ../firmware
find ./bin/ -name "*dockerman*" | xargs -i cp -f {} $kmoddirdocker
find ./bin/ -name "*dockerd*" | xargs -i cp -f {} $kmoddirdocker
EOF
case "${CONFIG_S}" in
     "Vip"*)  
#修改默认IP地址
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate
#修改immortalwrt.lan关联IP
#sed -i "s/192\.168\.[0-9]*\.[0-9]*/192.168.10.1/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#修改默认IP地址
#sed -i "s/192\.168\.[0-9]*\.[0-9]*/192.168.10.1/g" package/base-files/files/bin/config_generate    #config_generate

#修改默认IP地址
sed -i 's/192\.168\.1\.1/192\.168\.10\.1/g' package/base-files/files/bin/config_generate

#sed -i 's/192.168.100.1/192.168.10.1/g' package/istoreos-files/Makefile
#sed -i 's/luci-theme-argon/luci-theme-kucat/g' package/istoreos-files/Makefile

#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/192\.168\.10\.1/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#修改默认IP地址
# sed -i "s/192\.168\.[0-9]*\.[0-9]*/192\.168\.10\.1/g" package/base-files/files/bin/config_generate

cat>./package/base-files/files/etc/kmodreg<<-\EOF
#!/bin/bash
# EzOpWrt By Sirpdboy
IPK=$1
nowkmoddir=/etc/kmod.d/$IPK
[ -d $nowkmoddir ]  || exit
is_docker() {
     [ -s "/usr/lib/lua/luci/controller/dockerman.lua" ] && return 0  || return 1
}

run_drv() {
opkg update
echo "正在安装全部驱动（包括有线和无线）,请耐心等待...大约需要1-5分钟 "
for file in `ls $nowkmoddir/*.ipk`;do
    opkg install "$file"  --force-depends
done
echo "所有驱动已经安装完成！请重启系统生效！ "
}

run_docker() {
if is_docker; then
	echo " Docker服务已经存在！无须安装！"
else

    local opkg_conf="/etc/opkg.conf"
    sed -i '/option check_signature/d' "$opkg_conf"
	opkg update
	echo "正在安装Docker及相关服务...请耐心等待...大约需要1-5分钟 "
	# opkg install $nowkmoddir/dockerd*.ipk --force-depends >/dev/null 2>&1
	# opkg install $nowkmoddir/luci-app-dockerman*.ipk --force-depends  >/dev/null 2>&1
	# opkg install $nowkmoddir/luci-i18n-dockerman*.ipk --force-depends  >/dev/null 2>&1
	opkg install --force-depends luci-app-dockerman >/dev/null 2>&1
    	opkg install --force-depends luci-i18n-dockerman-zh-cn	 >/dev/null 2>&1
    	opkg install --force-depends avahi-daemon >/dev/null 2>&1
	if is_docker; then
		echo "本地成功安装Docker及相关服务！"
	else
   		echo "本地安装失败！"
   		echo "在线重新安装Docker及相关服务...请耐心等待...大约需要1-5分钟"
   		opkg install dockerd --force-depends >/dev/null 2>&1
    		opkg install luci-app-dockerman >/dev/null 2>&1
    		opkg install luci-i18n-dockerman* >/dev/null 2>&1
    		opkg install avahi-daemon >/dev/null 2>&1
    		if is_docker; then 
    		    echo "在线成功安装Docker及相关服务！" 
    		fi

	fi
fi
if is_docker; then
      		echo "设置Docker服务自动启动成功！"
      		echo "Docker菜单注销重新登陆才能看到！"
		uci -q get dockerd.globals 2>/dev/null && {
		uci -q set dockerd.globals.data_root='/opt/docker/'
		uci -q set dockerd.globals.auto_start='1'
		uci commit dockerd
  		/etc/init.d/dockerd enabled
		rm -rf /tmp/luci*
		 /etc/init.d/avahi-daemon enabled
		 /etc/init.d/avahi-daemon start
		/etc/init.d/dockerd restart
		}
    else
      echo "安装Docker失败！请保证出国插件线路和网络正常！BUG请联系TG群：sirpdboy！"
    fi
}
case "$IPK" in
	"drv")
		run_drv
	;;
	"docker")
		run_docker
	;;
esac

EOF
;;
"Free"*) 

#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/192\.168\.8\.1/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
sed -i "s/192\.168\.[0-9]*\.[0-9]*/192\.168\.8\.1/g" package/base-files/files/bin/config_generate

cat>./package/base-files/files/etc/kmodreg<<-\EOF
#!/bin/bash
# EzOpWrt By Sirpdboy
IPK=$1
nowkmoddir=/etc/kmod.d/$IPK
[ -d $nowkmoddir ]  || exit
run_drv() {
echo "目前此功能仅限VIP版本提供！ "
exit
}
run_docker() {
echo "目前此功能仅限VIP版本提供！ "
exit
}
case "$IPK" in
	"drv")
		run_drv
	;;
	"docker")
		run_docker
	;;
esac
exit
EOF

;;
esac


#UPDATE_PACKAGE "包名" "项目地址" "项目分支" "pkg/name，可选，pkg为从大杂烩中单独提取包名插件；name为重命名为包名"
UPDATE_PACKAGE "nekoclash" "Thaolga/luci-app-nekoclash" "main"
UPDATE_PACKAGE "luci-app-gecoosac" "lwb1978/openwrt-gecoosac" "main"
UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main"
UPDATE_PACKAGE "easytier" "lazyoop/networking-artifact" "main" "pkg"
UPDATE_PACKAGE "vnt" "lazyoop/networking-artifact" "main" "pkg"

./scripts/feeds update -i
./scripts/feeds install -i

# cat  ../.config  > .config
cat  ./x86_64/${CONFIG_S}  > .config

./scripts/feeds update -a
./scripts/feeds install -a
exit
