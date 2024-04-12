#!/bin/bash

is_vip() {
case "${CONFIG_S}" in
     "Vip"*) return 0 ;;
     *) return 1 ;;
esac
}
config_generate=package/base-files/files/bin/config_generate
[ ! -d files/root ] || mkdir -p files/root

[[ -n $CONFIG_S ]] || CONFIG_S=Super

sed -i "s/ImmortalWrt/OpenWrt/" {package/base-files/files/bin/config_generate,include/version.mk}
sed -i "s/ImmortalWrt/openwrt/" ./feeds/luci/modules/luci-mod-system/htdocs/luci-static/resources/view/system/flash.js  #改登陆域名
#删除冲突插件
# rm -rf $(find ./feeds/luci/ -type d -regex ".*\(argon\|design\|openclash\).*")
# rm -rf package/feeds/packages/prometheus-node-exporter-lua
# rm -rf feeds/packages/prometheus-node-exporter-lua
#samrtdns
rm -rf ./feeds/luci/applications/luci-app-smartdns
rm -rf  ./feeds/packages/net/smartdns

export github=github.com
export mirror=raw.githubusercontent.com/coolsnowwolf/lede/master

# kernel - 5.4
# curl -s https://$mirror/tags/kernel-5.4 > include/kernel-5.4

# kenrel Vermagic
# sed -ie 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk
# grep HASH include/kernel-5.4 | awk -F'HASH-' '{print $2}' | awk '{print $1}' | md5sum | awk '{print $1}' > .vermagic

# alist
rm -rf ./feeds/packages/net/alist
rm -rf  ./feeds/luci/applications/luci-app-alist
# alist
git clone https://$github/sbwml/luci-app-alist package/alist
# git clone -b v3.23.0 --depth 1 https://$github/sbwml/luci-app-alist package/alist
# rm -rf ./package/alist/alist

# sed -i 's/网络存储/存储/g' ./package/alist/luci-app-alist/po/*/alist.po

case "${CONFIG_S}" in

Vip-Super)
sed -i '/45)./d' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua  #zerotier
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua   #zerotier
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/view/zerotier/zerotier_status.htm   #zerotier
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-samba4/luasrc/controller/samba4.lua 
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-cifs-mount/luasrc/controller/cifs.lua 
sed -i 's/vpn/services/g' ./feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/root/usr/share/luci/menu.d/luci-app-alist.json
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/luasrc/controller/alist.lua
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/view/alist/admin_info.htm
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/view/alist/alist_status.htm
sed -i 's/nas/services/g' ./package/alist/luci-app-alist/luasrc/controller/alist.lua
sed -i '/NAS/d' ./feeds/luci/applications/luci-app-alist/luasrc/controller/alist.lua
sed -i '/NAS/d' ./package/alist/luci-app-alist/luasrc/controller/alist.lua
sed -i 's/nas/services/g' ./package/alist/luci-app-alist/view/alist/admin_info.htm
sed -i 's/nas/services/g' ./package/alist/luci-app-alist/view/alist/alist_status.htm
;;
Vip-Mini)
sed -i '/45)./d' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua  #zerotier
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua   #zerotier
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/view/zerotier/zerotier_status.htm   #zerotier
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-samba4/luasrc/controller/samba4.lua 
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-cifs-mount/luasrc/controller/cifs.lua 
sed -i 's/vpn/services/g' ./feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/root/usr/share/luci/menu.d/luci-app-alist.json
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/luasrc/controller/alist.lua
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/view/alist/admin_info.htm
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/view/alist/alist_status.htm
sed -i 's/nas/services/g' ./package/alist/luci-app-alist/luasrc/controller/alist.lua
sed -i 's/nas/services/g' ./package/alist/luci-app-alist/view/alist/admin_info.htm
sed -i '/NAS/d' ./feeds/luci/applications/luci-app-alist/luasrc/controller/alist.lua
sed -i '/NAS/d' ./package/alist/luci-app-alist/luasrc/controller/alist.lua
sed -i 's/nas/services/g' ./package/alist/luci-app-alist/view/alist/alist_status.htm
;;
Vip-Bypass)
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua   #zerotier
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-zerotier/luasrc/view/zerotier/zerotier_status.htm   #zerotier
sed -i 's/services/nas/g' ./feeds/luci/applications/luci-app-samba4/luasrc/controller/samba4.lua 
sed -i 's/services/nas/g' ./feeds/luci/applications/luci-app-cifs-mount/luasrc/controller/cifs.lua 
sed -i 's/services/vpn/g' ./feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json
sed -i 's/services/nas/g' ./feeds/luci/applications/luci-app-alist/root/usr/share/luci/menu.d/luci-app-alist.json
sed -i 's/services/nas/g' ./feeds/luci/applications/luci-app-alist/luasrc/controller/alist.lua
sed -i 's/services/nas/g' ./feeds/luci/applications/luci-app-alist/view/alist/admin_info.htm
sed -i 's/services/nas/g' ./feeds/luci/applications/luci-app-alist/view/alist/alist_status.htm
sed -i 's/services/nas/g' ./package/alist/luci-app-alist/luasrc/controller/alist.lua
sed -i '/NAS/d' ./feeds/luci/applications/luci-app-alist/luasrc/controller/alist.lua
sed -i '/NAS/d' ./package/alist/luci-app-alist/luasrc/controller/alist.lua
sed -i 's/services/nas/g' ./package/alist/luci-app-alist/view/alist/admin_info.htm
sed -i 's/services/nas/g' ./package/alist/luci-app-alist/view/alist/alist_status.htm
;;
Free-Super)
sed -i '/45)./d' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua  #zerotier
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua   #zerotier
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/view/zerotier/zerotier_status.htm   #zerotier
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-samba4/luasrc/controller/samba4.lua
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-cifs-mount/luasrc/controller/cifs.lua
sed -i 's/vpn/services/g' ./feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/root/usr/share/luci/menu.d/luci-app-alist.json
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/luasrc/controller/alist.lua
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/view/alist/admin_info.htm
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/view/alist/alist_status.htm
sed -i 's/nas/services/g' ./package/alist/luci-app-alist/luasrc/controller/alist.lua
sed -i '/NAS/d' ./feeds/luci/applications/luci-app-alist/luasrc/controller/alist.lua
sed -i '/NAS/d' ./package/alist/luci-app-alist/luasrc/controller/alist.lua
sed -i 's/nas/services/g' ./package/alist/luci-app-alist/view/alist/admin_info.htm
sed -i 's/nas/services/g' ./package/alist/luci-app-alist/view/alist/alist_status.htm
;;
*)
sed -i '/45)./d' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua  #zerotier
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua   #zerotier
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/view/zerotier/zerotier_status.htm   #zerotier
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-samba4/luasrc/controller/samba4.lua
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-cifs-mount/luasrc/controller/cifs.lua
sed -i 's/vpn/services/g' ./feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/root/usr/share/luci/menu.d/luci-app-alist.json
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/luasrc/controller/alist.lua
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/view/alist/admin_info.htm
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-alist/view/alist/alist_status.htm
sed -i '/NAS/d' ./feeds/luci/applications/luci-app-alist/luasrc/controller/alist.lua
sed -i '/NAS/d' ./package/alist/luci-app-alist/luasrc/controller/alist.lua
sed -i 's/nas/services/g' ./package/alist/luci-app-alist/luasrc/controller/alist.lua
sed -i 's/nas/services/g' ./package/alist/luci-app-alist/view/alist/admin_info.htm
sed -i 's/nas/services/g' ./package/alist/luci-app-alist/view/alist/alist_status.htm
;;
esac

sed -i 's/services/status/g' ./feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json

# rm -rf ./package/emortal2
#rm -rf  package/js2

rm -rf  feeds/packages/net/wrtbwmon
rm -rf  ./feeds/luci/applications/luci-app-wrtbwmon 
rm -rf  ./feeds/luci/applications/luci-app-arpbind
rm -rf  ./feeds/packages/net/open-app-filter
rm -rf  ./feeds/packages/net/oaf
rm -rf  ./feeds/luci/applications/luci-app-appfilter
rm -rf  ./feeds/luci/applications/luci-app-timecontrol
rm -rf  ./feeds/luci/applications/luci-app-socat
rm -rf  ./feeds/luci/applications/luci-app-fileassistant
rm -rf  ./feeds/luci/applications/luci-app-control-speedlimit

# rm -rf  ./feeds/packages/net/wget
# mv -rf ./package/wget  ./feeds/packages/net/wget
#aria2
rm -rf ./feeds/packages/net/aria2
rm -rf ./feeds/luci/applications/luci-app-aria2  package/feeds/packages/luci-app-aria2


# Passwall

rm -rf ./feeds/luci/applications/luci-app-ssr-plus  package/feeds/packages/luci-app-ssr-plus
rm -rf ./feeds/luci/applications/luci-app-passwall  package/feeds/packages/luci-app-passwall
rm -rf ./feeds/luci/applications/luci-app-passwall2  package/feeds/packages/luci-app-passwall2

# git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 ./package/passwall2
# git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall ./package/passwall
git clone https://github.com/sbwml/openwrt_helloworld  ./package/ssr
git clone https://github.com/loso3000/other ./package/other

rm -rf ./package/ssr/luci-app-passwall2/htdocs/luci-static/resources/
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

rm -rf ./package/ssr/shadowsocks-libev
rm -rf ./package/ssr/shadowsocks-rust

rm -rf ./package/ssr/mosdns
rm -rf ./package/ssr/trojan-plus
rm -rf ./package/ssr/xray-core
rm -rf ./package/ssr/xray-plugin
rm -rf ./package/ssr/naiveproxy
rm -rf ./package/ssr/v2ray-plugin
rm -rf ./package/ssr/v2ray-core
# rm -rf ./package/ssr/pdnsd
rm -rf ./package/ssr/lua-neturl
rm -rf ./package/ssr/redsocks2
rm -rf ./package/ssr/shadow-tls



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
rm -rf ./feeds/packages/net/xray-plugin

rm -rf ./feeds/packages/net/sing-box

rm -rf ./feeds/packages/net/mosdns
rm -rf ./feeds/packages/net/trojan-plus
rm -rf ./feeds/packages/net/xray-core
rm -rf ./feeds/packages/net/xray-plugin
rm -rf ./feeds/packages/net/naiveproxy
rm -rf ./feeds/packages/net/v2ray-plugin
rm -rf ./feeds/packages/net/v2ray-core
rm -rf ./feeds/packages/net/pdnsd
rm -rf ./feeds/packages/net/lua-neturl
rm -rf ./feeds/packages/net/redsocks2
rm -rf ./feeds/packages/net/shadow-tls

rm -rf  ./feeds/luci/applications/luci-app-netdata
# rm -rf ./feeds/packages/admin/netdata
# git clone https://github.com/muink/openwrt-netdata-ssl ./package/diy/netdata-ssl
mv -f ./package/other/up/netdata ./package/
rm -rf ./feeds/luci/applications/luci-app-socat  ./package/feeds/luci/luci-app-socat
mv -f ./package/other/up/tool ./package/
mv -f ./package/other/up/pass ./package/pass
sed -i 's,default n,default y,g' ./package/pass/luci-app-bypass/Makefile

# kernel modules
# rm -rf  ./feeds/packages/network/utils/iptables
rm -rf  ./package/kucat/iptables
# mv -f  ./package/kucat/iptables  ./feeds/packages/network/utils/iptables
# rm -f ./package/kernel/linux/modules/netfilter.mk
# wget -P ./package/kernel/linux/modules/ https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/kernel/linux/modules/netfilter.mk
# wget -P ./package/kernel/linux/modules/ https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/package/kernel/linux/modules/netfilter.mk

#rm -rf package/kernel/linux
#git checkout package/kernel/linux
#pushd package/kernel/linux/modules
    # rm -f [a-z]*.mk
    #curl -Os https://$mirror/package/kernel/linux/modules/netfilter.mk
#popd

#dae
#rm -rf  ./feeds/packages/net/daed
#rm -rf  ./package/kernel/bpf-headers
#rm -rf  ./feeds/luci/applications/luci-app-daed

rm -rf ./package/other

# Add luci-app-dockerman
# rm -rf ./feeds/luci/applications/luci-app-dockerman
# rm -rf ./feeds/luci/collections/luci-lib-docker
# git clone --depth=1 https://$github/lisaac/luci-lib-docker ./package/new/luci-lib-docker
# git clone --depth=1 https://$github/lisaac/luci-app-dockerman ./package/new/dockerman

cat patch/dockerman.lua > ./feeds/luci/applications/luci-app-dockerman/luasrc/controller/dockerman.lua
cat  patch/banner > ./package/base-files/files/etc/banner
cat  patch/profile > ./package/base-files/files/etc/profile
cat  patch/profiles > ./package/base-files/files/etc/profiles
cat  patch/sysctl.conf > ./package/base-files/files/etc/sysctl.conf

mkdir -p files/usr/share
mkdir -p files/etc/root
# rm -rf $(find ./package/emortal/ -type d -regex ".*\(autocore\|automount\|autosamba\|default-settings\).*")
rm -rf ./package/emortal/autocore ./package/emortal/automount  ./package/emortal/autosamba  ./package/emortal/default-settings 
mv -rf ./package/emortal2/autocore  ./package/emortal/autocore 
mv -rf  ./package/emortal2/default-settings   ./package/emortal/default-settings 
mv -rf  ./package/emortal2/automount   ./package/emortal/automount
mv -rf  ./package/emortal2/autosamba   ./package/emortal/autosamba


#修改默认主机名
sed -i "s/hostname='.*'/hostname='EzOpWrt'/g" ./package/base-files/files/bin/config_generate
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" ./package/base-files/files/bin/config_generate
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" ./package/base-files/files/bin/config_generate


#  coremark
sed -i '/echo/d' ./feeds/packages/utils/coremark/coremark

git clone https://github.com/sirpdboy/luci-app-lucky ./package/lucky
rm ./package/lucky/luci-app-lucky/po/zh_Hans
mv ./package/lucky/luci-app-lucky/po/zh-cn ./package/ddns-go/luci-app-lucky/po/zh_Hans

rm -rf ./feeds/packages/net/ddns-go
rm -rf  ./feeds/luci/applications/luci-app-ddns-go
git clone https://github.com/sirpdboy/luci-app-ddns-go ./package/ddns-go
rm ./package/ddns-go/luci-app-ddns-go/po/zh_Hans
mv ./package/ddns-go/luci-app-ddns-go/po/zh-cn ./package/ddns-go/luci-app-ddns-go/po/zh_Hans

# nlbwmon
sed -i 's/524288/16777216/g' feeds/packages/net/nlbwmon/files/nlbwmon.config
# 可以设置汉字名字
sed -i '/o.datatype = "hostname"/d' feeds/luci/modules/luci-mod-admin-full/luasrc/model/cbi/admin_system/system.lua
# sed -i '/= "hostname"/d' /usr/lib/lua/luci/model/cbi/admin_system/system.lua

git clone  https://github.com/linkease/nas-packages-luci ./package/nas-packages-luci
git clone  https://github.com/linkease/nas-packages ./package/nas-packages
git clone  https://github.com/linkease/istore ./package/istore
sed -i 's/1/0/g' ./package/nas-packages/network/services/linkease/files/linkease.config
sed -i 's/luci-lib-ipkg/luci-base/g' package/istore/luci/luci-app-store/Makefile


rm -rf ./feeds/packages/net/mosdns
rm -rf  ./feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
git clone https://github.com/sbwml/v2ray-geodata feeds/packages/net/v2ray-geodata

rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 21.x feeds/packages/lang/golang
# git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang

#设置upnpd
#sed -i 's/option enabled.*/option enabled 0/' feeds/*/*/*/*/upnpd.config
#sed -i 's/option dports.*/option enabled 2/' feeds/*/*/*/*/upnpd.config

sed -i "s/ImmortalWrt/EzOpWrt/" {package/base-files/files/bin/config_generate,include/version.mk}
sed -i "s/OpenWrt/EzOpWrt/" {package/base-files/files/bin/config_generate,include/version.mk}
sed -i "/listen_https/ {s/^/#/g}" package/*/*/*/files/uhttpd.config
sed -i 's/msgstr "Socat"/msgstr "端口转发"/g' ./feeds/luci/applications/luci-app-socat/po/*/socat.po

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

sed -i 's/监听端口/监听端口 用户名admin密码adminadmin/g' ./feeds/luci/applications/luci-app-qbittorrent/po/*/qbittorrent.po
# echo  "        option tls_enable 'true'" >> ./feeds/luci/applications/luci-app-frpc/root/etc/config/frp   #FRP穿透问题
sed -i 's/invalid/# invalid/g' ./package/network/services/samba36/files/smb.conf.template  #共享问题
sed -i '/mcsub_renew.datatype/d'  ./feeds/luci/applications/luci-app-udpxy/luasrc/model/cbi/udpxy.lua  #修复UDPXY设置延时55的错误
sed -i '/filter_/d' ./package/network/services/dnsmasq/files/dhcp.conf   #DHCP禁用IPV6问题
sed -i 's/请输入用户名和密码。/管理登陆/g' ./feeds/luci/modules/luci-base/po/*/base.po   #用户名密码

#cifs挂pan
sed -i 's/mount -t cifs/busybox mount -t cifs/g' ./feeds/luci/applications/luci-app-cifs-mount/root/etc/init.d/cifs

#cifs
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-cifs-mount/luasrc/controller/cifs.lua   #dnsfilter
sed -i 's/a.default = "0"/a.default = "1"/g' ./feeds/luci/applications/luci-app-cifsd/luasrc/controller/cifsd.lua   #挂问题
echo  "        option tls_enable 'true'" >> ./feeds/luci/applications/luci-app-frpc/root/etc/config/frp   #FRP穿透问题
sed -i 's/invalid/# invalid/g' ./package/network/services/samba36/files/smb.conf.template  #共享问题
sed -i '/mcsub_renew.datatype/d'  ./feeds/luci/applications/luci-app-udpxy/luasrc/model/cbi/udpxy.lua  #修复UDPXY设置延时55的错误

#断线不重拨
sed -i 's/q reload/q restart/g' ./package/network/config/firewall/files/firewall.hotplug

#echo "其他修改"
sed -i 's/option commit_interval.*/option commit_interval 1h/g' feeds/packages/net/nlbwmon/files/nlbwmon.config #修改流量统计写入为1h
# sed -i 's#option database_directory /var/lib/nlbwmon#option database_directory /etc/config/nlbwmon_data#g' feeds/packages/net/nlbwmon/files/nlbwmon.config #修改流量统计数据存放默认位置

# echo '默认开启 Irqbalance'
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config
# nlbwmon - disable syslog
sed -i 's/stderr 1/stderr 0/g' feeds/packages/net/nlbwmon/files/nlbwmon.init

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

sed -i 's,media .. \"\/b,resource .. \"\/b,g' ./package/luci-theme-argon/luasrc/view/themes/argon/sysauth.htm
sed -i 's,media .. \"\/b,resource .. \"\/b,g' ./feeds/luci/themes/luci-theme-argon/luasrc/view/themes/argon/sysauth.htm
# 使用默认取消自动
# sed -i "s/bootstrap/chuqitopd/g" feeds/luci/modules/luci-base/root/etc/config/luci
# sed -i 's/bootstrap/chuqitopd/g' feeds/luci/collections/luci/Makefile
echo "修改默认主题"
sed -i 's/+luci-theme-bootstrap/+luci-theme-kucat/g' feeds/luci/collections/luci/Makefile
# sed -i "s/luci-theme-bootstrap/luci-theme-$OP_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
# sed -i 's/+luci-theme-bootstrap/+luci-theme-opentopd/g' feeds/luci/collections/luci/Makefile
sed -i '/set luci.main.mediaurlbase=/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
sed -i '/set luci.main.mediaurlbase/d' ./package/luci-theme-argon/root/etc/uci-defaults/30_luci-theme-argon
sed -i '/set luci.main.mediaurlbase/d' feeds/luci/themes/luci-theme-argon/root/etc/uci-defaults/30_luci-theme-argon
sed -i '/set luci.main.mediaurlbase/d' package/luci-theme-argon/root/etc/uci-defaults/30_luci-theme-argon
sed -i '/set luci.main.mediaurlbase=/d' feeds/luci/themes/luci-theme-material/root/etc/uci-defaults/30_luci-theme-material
sed -i '/set luci.main.mediaurlbase=/d' feeds/luci/themes/luci-theme-design/root/etc/uci-defaults/30_luci-luci-theme-design
sed -i '/set luci.main.mediaurlbase=/d' package/luci-theme-design/root/etc/uci-defaults/30_luci-theme-design


# 取消主题默认设置
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;
sed -i '/check_signature/d' ./package/system/opkg/Makefile   # 删除IPK安装签名
sed -i 's/START=95/START=99/' `find package/ -follow -type f -path */ddns-scripts/files/ddns.init`
#Add x550
git clone https://github.com/shenlijun/openwrt-x550-nbase-t package/openwrt-x550-nbase-t


# 修改makefile
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/include\ \.\.\/\.\.\/luci\.mk/include \$(TOPDIR)\/feeds\/luci\/luci\.mk/g' {}
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/include\ \.\.\/\.\.\/lang\/golang\/golang\-package\.mk/include \$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang\-package\.mk/g' {}

# 修复 hostapd 报错
#cp -f $GITHUB_WORKSPACE/scriptx/011-fix-mbo-modules-build.patch package/network/services/hostapd/patches/011-fix-mbo-modules-build.patch


# sed -i 's/KERNEL_PATCHVER:=6.1/KERNEL_PATCHVER:=5.4/g' ./target/linux/*/Makefile
# sed -i 's/KERNEL_PATCHVER:=5.15/KERNEL_PATCHVER:=5.4/g' ./target/linux/*/Makefile

# 预处理下载相关文件，保证打包固件不用单独下载
for sh_file in `ls ${GITHUB_WORKSPACE}/openwrt/common/*.sh`;do
    source $sh_file amd64
done

if [[ $DATE_S == 'default' ]]; then
   DATA=`TZ=UTC-8 date +%Y.%m.%d -d +"12"hour`
else 
   DATA=$DATE_S
fi


ver54=`grep "LINUX_VERSION-5.4 ="  include/kernel-5.4 | cut -d . -f 3`
ver515=`grep "LINUX_VERSION-5.15 ="  include/kernel-5.15 | cut -d . -f 3`
ver61=`grep "LINUX_VERSION-6.1 ="  include/kernel-6.1 | cut -d . -f 3`
ver66=`grep "LINUX_VERSION-6.6 ="  include/kernel-6.6 | cut -d . -f 3`
date1="${CONFIG_S}-${DATA}_by_Sirpdboy"
if [ "$VER1" = "5.4" ]; then
date2="EzOpWrt ${CONFIG_S}-${DATA}-${VER1}.${ver54}_by_Sirpdboy"
elif [ "$VER1" = "5.15" ]; then
date2="EzOpWrt ${CONFIG_S}-${DATA}-${VER1}.${ver515}_by_Sirpdboy"
elif [ "$VER1" = "6.1" ]; then
date2="EzOpWrt ${CONFIG_S}-${DATA}-${VER1}.${ver61}_by_Sirpdboy"
elif [ "$VER1" = "6.6" ]; then
date2="EzOpWrt ${CONFIG_S}-${DATA}-${VER1}.${ver66}_by_Sirpdboy"
fi
echo "${date1}" > ./package/base-files/files/etc/ezopenwrt_version
echo "${date2}" >> ./package/base-files/files/etc/banner
echo '---------------------------------' >> ./package/base-files/files/etc/banner
[ -f ./files/root/.zshrc ] || mv -f ./package/other/patch/z.zshrc ./files/root/.zshrc
[ -f ./files/root/.zshrc ] || curl -fsSL  https://raw.githubusercontent.com/loso3000/other/master/patch/.zshrc > ./files/root/.zshrc
[ -f ./files/etc/profiles ] || mv -f ./package/other/patch/profiles ./files/etc/profiles
[ -f ./files/etc/profiles ] || curl -fsSL  https://raw.githubusercontent.com/loso3000/other/master/patch/profiles > ./files/etc/profiles

if [ ${TARGET_DEVICE} = "x86_64" ] ; then
cat>buildmd5.sh<<-\EOF
#!/bin/bash

r_version=`cat ./package/base-files/files/etc/ezopenwrt_version`
VER1="$(grep "KERNEL_PATCHVER:="  ./target/linux/x86/Makefile | cut -d = -f 2)"
ver54=`grep "LINUX_VERSION-5.4 ="  include/kernel-5.4 | cut -d . -f 3`
ver515=`grep "LINUX_VERSION-5.15 ="  include/kernel-5.15 | cut -d . -f 3`
ver61=`grep "LINUX_VERSION-6.1 ="  include/kernel-6.1 | cut -d . -f 3`
ver66=`grep "LINUX_VERSION-6.6 ="  include/kernel-6.6 | cut -d . -f 3`
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
if [ "$VER1" = "5.4" ]; then
mv  *generic-squashfs-combined.img.gz       EzOpenWrt-${r_version}_${VER1}.${ver54}-${TARGET_DEVICE}-combined.img.gz   
mv  *generic-squashfs-combined-efi.img.gz   EzOpenWrt-${r_version}_${VER1}.${ver54}-${TARGET_DEVICE}-combined-efi.img.gz
md5_EzOpWrt=EzOpenWrt-${r_version}_${VER1}.${ver54}-${TARGET_DEVICE}-combined.img.gz   
md5_EzOpWrt_uefi=EzOpenWrt-${r_version}_${VER1}.${ver54}-${TARGET_DEVICE}-combined-efi.img.gz
elif [ "$VER1" = "5.15" ]; then
mv  *generic-squashfs-combined.img.gz       EzOpenWrt-${r_version}_${VER1}.${ver515}-${TARGET_DEVICE}-combined.img.gz   
mv  *generic-squashfs-combined-efi.img.gz   EzOpenWrt-${r_version}_${VER1}.${ver515}-${TARGET_DEVICE}-combined-efi.img.gz
md5_EzOpWrt=EzOpenWrt-${r_version}_${VER1}.${ver515}-${TARGET_DEVICE}-combined.img.gz   
md5_EzOpWrt_uefi=EzOpenWrt-${r_version}_${VER1}.${ver515}-${TARGET_DEVICE}-combined-efi.img.gz
elif [ "$VER1" = "6.1" ]; then
mv  *generic-squashfs-combined.img.gz       EzOpenWrt-${r_version}_${VER1}.${ver61}-${TARGET_DEVICE}-combined.img.gz   
mv  *generic-squashfs-combined-efi.img.gz   EzOpenWrt-${r_version}_${VER1}.${ver61}-${TARGET_DEVICE}-combined-efi.img.gz
md5_EzOpWrt=EzOpenWrt-${r_version}_${VER1}.${ver61}-${TARGET_DEVICE}-combined.img.gz   
md5_EzOpWrt_uefi=EzOpenWrt-${r_version}_${VER1}.${ver61}-${TARGET_DEVICE}-combined-efi.img.gz
elif [ "$VER1" = "6.6" ]; then
mv  *generic-squashfs-combined.img.gz       EzOpenWrt-${r_version}_${VER1}.${ver66}-${TARGET_DEVICE}-combined.img.gz   
mv  *generic-squashfs-combined-efi.img.gz   EzOpenWrt-${r_version}_${VER1}.${ver66}-${TARGET_DEVICE}-combined-efi.img.gz
md5_EzOpWrt=EzOpenWrt-${r_version}_${VER1}.${ver66}-x86-64-combined.img.gz   
md5_EzOpWrt_uefi=EzOpenWrt-${r_version}_${VER1}.${ver66}-x86-64-combined-efi.img.gz
fi
#md5
md5sum ${md5_EzOpWrt} > EzOpWrt_combined.md5  || true
md5sum ${md5_EzOpWrt_uefi} > EzOpWrt_combined-efi.md5 || true
popd

EOF
else
cat>buildmd5.sh<<-\EOF
#!/bin/bash

r_version=`cat ./package/base-files/files/etc/ezopenwrt_version`
ver54=`grep "LINUX_VERSION-5.4 ="  include/kernel-5.4 | cut -d . -f 3`
ver515=`grep "LINUX_VERSION-5.15 ="  include/kernel-5.15 | cut -d . -f 3`
ver61=`grep "LINUX_VERSION-6.1 ="  include/kernel-6.1 | cut -d . -f 3`
ver66=`grep "LINUX_VERSION-6.6 ="  include/kernel-6.6 | cut -d . -f 3`
# gzip bin/targets/*/*/*.img | true

VER1="$(grep "KERNEL_PATCHVER:=" ./target/linux/rockchip/Makefile | cut -d = -f 2)"
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

if [ "$VER1" = "5.4" ]; then
mv   *squashfs-sysupgrade.img.gz EzOpenWrt-${r_version}_${VER1}.${ver54}-${TARGET_DEVICE}-squashfs-sysupgrade.img.gz 
mv  *ext4-sysupgrade.img.gz EzOpenWrt-${r_version}_${VER1}.${ver54}-${TARGET_DEVICE}-ext4-sysupgrade.img.gz
md5_EzOpWrt=*squashfs-sysupgrade.img.gz  
md5_EzOpWrt_uefi=*ext4-sysupgrade.img.gz
elif [ "$VER1" = "5.15" ]; then
mv   *squashfs-sysupgrade.img.gz EzOpenWrt-${r_version}_${VER1}.${ver515}-${TARGET_DEVICE}-squashfs-sysupgrade.img.gz 
mv   *ext4-sysupgrade.img.gz EzOpenWrt-${r_version}_${VER1}.${ver515}-${TARGET_DEVICE}-ext4-sysupgrade.img.gz
md5_EzOpWrt=*squashfs-sysupgrade.img.gz  
md5_EzOpWrt_uefi=*ext4-sysupgrade.img.gz
elif [ "$VER1" = "6.1" ]; then
mv *squashfs-sysupgrade.img.gz EzOpenWrt-${r_version}_${VER1}.${ver61}-${TARGET_DEVICE}-squashfs-sysupgrade.img.gz 
mv *ext4-sysupgrade.img.gz EzOpenWrt-${r_version}_${VER1}.${ver61}-${TARGET_DEVICE}-ext4-sysupgrade.img.gz
md5_EzOpWrt=*squashfs-sysupgrade.img.gz  
md5_EzOpWrt_uefi=*ext4-sysupgrade.img.gz
fi
#md5
md5sum ${md5_EzOpWrt} > EzOpWrt_squashfs-sysupgrade.md5  || true
md5sum ${md5_EzOpWrt_uefi} > EzOpWrt_ext4-sysupgrade.md5 || true

popd
exit 0
EOF
fi
cat>bakkmod.sh<<-\EOF
#!/bin/bash
kmoddirdrv=./files/etc/kmod.d/drv
kmoddirdocker=./files/etc/kmod.d/docker
bakkmodfile=./package/other/patch/kmod.source
nowkmodfile=./files/etc/kmod.now
mkdir -p $kmoddirdrv 2>/dev/null
mkdir -p $kmoddirdocker 2>/dev/null
while IFS= read -r file; do
    a=`find ./bin/ -name "$file" `
    echo $a
    if [ -z "$a" ]; then
        echo "no find: $file"
    else
        cp -f $a $kmoddirdrv
	echo $file >> $nowkmodfile
        if [ $? -eq 0 ]; then
            echo "cp ok: $file"
        else
            echo "no cp:$file"
        fi
    fi
done < $bakkmodfile
find ./bin/ -name "*dockerman*.ipk" | xargs -i cp -f {} $kmoddirdocker
find ./bin/ -name "*dockerd*.ipk" | xargs -i cp -f {} $kmoddirdocker
EOF

if  is_vip ; then
#修改默认IP地址
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

cat>./package/base-files/files/etc/kmodreg<<-\EOF
#!/bin/bash
# EzOpenWrt By Sirpdboy
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
	opkg install $nowkmoddir/dockerd*.ipk --force-depends >/dev/null 2>&1
	opkg install $nowkmoddir/luci-app-dockerman*.ipk --force-depends  >/dev/null 2>&1
	opkg install $nowkmoddir/luci-i18n-dockerman*.ipk --force-depends  >/dev/null 2>&1
	if is_docker; then
		echo "本地成功安装Docker及相关服务！"
	else
   		echo "本地安装失败！"
   		echo "在线重新安装Docker及相关服务...请耐心等待...大约需要1-5分钟"
   		opkg install dockerd --force-depends >/dev/null 2>&1
    		opkg install luci-app-dockerman >/dev/null 2>&1
    		opkg install luci-i18n-dockerman-zh-cn >/dev/null 2>&1
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
      echo "Docker失败！请检查网络和系统环境设置等！或者联系TG群：sirpdboy！"
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

else

#修改默认IP地址
sed -i 's/192.168.1.1/192.168.8.1/g' package/base-files/files/bin/config_generate
cat>./package/base-files/files/etc/kmodreg<<-\EOF
#!/bin/bash
# EzOpenWrt By Sirpdboy
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

fi
./scripts/feeds update -i
./scripts/feeds install -i
cat  ./x86_64/${CONFIG_S}  > .config
case "${CONFIG_S}" in
"Vip"*)
cat  ./x86_64/comm  >> .config
;;
*)
cat  ./x86_64/comm  >> .config
;;
esac
exit
