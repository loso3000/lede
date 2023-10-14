#!/bin/bash
#=================================================
# Description: Build OpenWrt using GitHub Actions
WORKDIR=/workdir
HOSTNAME="EzOpWrt"
IPADDRESS="192.168.10.1"
OP_THEME="kucat"
SSID=Sirpdboy
ENCRYPTION=psk2
KEY=123456
config_generate=package/base-files/files/bin/config_generate

sed -i "s/ImmortalWrt/OpenWrt/" {package/base-files/files/bin/config_generate,include/version.mk}
sed -i "s/ImmortalWrt/openwrt/" ./feeds/luci/modules/luci-mod-system/htdocs/luci-static/resources/view/system/flash.js  #改登陆域名
#删除冲突插件
#rm -rf $(find ./feeds/luci/ -type d -regex ".*\(argon\|design\|openclash\).*")
# rm -rf $(find ./package/emortal/ -type d -regex ".*\(autocore\|default-settings\).*")

rm -rf ./package/emortal/autocore 
rm -rf  ./package/emortal/default-settings 
rm -rf  feeds/packages/net/wrtbwmon
rm -rf  ./feeds/luci/applications/luci-app-wrtbwmon 
rm -rf  ./feeds/luci/applications/luci-app-netdata
rm -rf  ./feeds/packages/net/open-app-filter
rm -rf  ./feeds/packages/net/oaf
rm -rf  ./feeds/luci/applications/luci-app-appfilter

#rm -rf  ./package/wget 
rm -rf  ./feeds/packages/net/wget
mv -rf ./package/wget  ./feeds/packages/net/wget

cat  patch/banner > ./package/base-files/files/etc/banner
cat  patch/profile > ./package/base-files/files/etc/profile
cat  patch/profiles > ./package/base-files/files/etc/profiles
cat  patch/sysctl.conf > ./package/base-files/files/etc/sysctl.conf

mkdir -p files/usr/share
mkdir -p files/etc/root
#touch files/etc/ezopenwrt_version
#touch files/usr/share/kmodreg

# 使用默认取消自动
# sed -i "s/bootstrap/chuqitopd/g" feeds/luci/modules/luci-base/root/etc/config/luci
# sed -i 's/bootstrap/chuqitopd/g' feeds/luci/collections/luci/Makefile
echo "修改默认主题"
# sed -i 's/+luci-theme-bootstrap/+luci-theme-kucat/g' feeds/luci/collections/luci/Makefile
# sed -i "s/luci-theme-bootstrap/luci-theme-$OP_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
# sed -i 's/+luci-theme-bootstrap/+luci-theme-opentopd/g' feeds/luci/collections/luci/Makefile
# sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap

 git clone -b js https://github.com/gngpp/luci-theme-design.git  package/luci-theme-design
#rm -rf ./feeds/luci/themes/luci-theme-argon
sed -i 's,media .. \"\/b,resource .. \"\/b,g' ./feeds/luci/themes/luci-theme-argon/luasrc/view/themes/argon/sysauth.htm

#修改默认IP地址
# sed -i "s/192\.168\.[0-9]*\.[0-9]*/$IPADDRESS/g" ./package/base-files/files/bin/config_generate
#sed -i 's/US/CN/g ; s/OpenWrt/iNet/g ; s/none/psk2/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate
# sed -i "s/192.168.6.1/192.168.10.1/g"  package/base-files/files/bin/config_generate

#修改默认主机名
sed -i "s/hostname='.*'/hostname='EzOpWrt'/g" ./package/base-files/files/bin/config_generate
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" ./package/base-files/files/bin/config_generate
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" ./package/base-files/files/bin/config_generate

# 清理
#rm -rf feeds/*/*/{smartdns,wrtbwmon,luci-app-smartdns,luci-app-timecontrol,luci-app-ikoolproxy,luci-app-smartinfo,luci-app-socat,luci-app-netdata,luci-app-wolplus,luci-app-arpbind,luci-app-baidupcs-web}
# rm -rf package/*/{autocore,autosamba,default-settings}
# rm -rf feeds/*/*/{luci-app-dockerman,luci-app-aria2,luci-app-beardropper,oaf,luci-app-adguardhome,luci-app-appfilter,open-app-filter,luci-app-openclash,luci-app-vssr,luci-app-ssr-plus,luci-app-passwall,luci-app-bypass,luci-app-wrtbwmon,luci-app-samba,luci-app-samba4,luci-app-unblockneteasemusic}

#fserror
#sed -i 's/fs\/cifs/fs\/smb\/client/g'  ./package/kernel/linux/modules/fs.mk
#sed -i 's/fs\/smbfs_common/fs\/smb\/common/g'  ./package/kernel/linux/modules/fs.mk

# rm -rf ./package/network/utils/iproute2/
# svn export https://github.com/openwrt/openwrt/trunk/package/network/utils/iproute2 ./package/network/utils/iproute2

#  coremark
sed -i '/echo/d' ./feeds/packages/utils/coremark/coremark

git clone https://github.com/sirpdboy/luci-app-lucky ./package/lucky
# git clone https://github.com/sirpdboy/luci-app-ddns-go ./package/ddns-go

# nlbwmon
sed -i 's/524288/16777216/g' feeds/packages/net/nlbwmon/files/nlbwmon.config
# 可以设置汉字名字
sed -i '/o.datatype = "hostname"/d' feeds/luci/modules/luci-mod-admin-full/luasrc/model/cbi/admin_system/system.lua
# sed -i '/= "hostname"/d' /usr/lib/lua/luci/model/cbi/admin_system/system.lua

# Add ddnsto & linkease
svn export https://github.com/linkease/nas-packages-luci/trunk/luci/ ./package/diy1/luci
svn export https://github.com/linkease/nas-packages/trunk/network/services/ ./package/diy1/linkease
svn export https://github.com/linkease/nas-packages/trunk/multimedia/ffmpeg-remux/ ./package/diy1/ffmpeg-remux
svn export https://github.com/linkease/istore/trunk/luci/ ./package/diy1/istore
sed -i 's/1/0/g' ./package/diy1/linkease/linkease/files/linkease.config
sed -i 's/luci-lib-ipkg/luci-base/g' package/diy1/istore/luci-app-store/Makefile
# svn export https://github.com/linkease/istore-ui/trunk/app-store-ui package/app-store-ui

rm -rf feeds/packages/net/v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
git clone https://github.com/sbwml/v2ray-geodata feeds/packages/net/v2ray-geodata
rm -rf package/mosdns/mosdns

# alist 
#git clone https://github.com/sbwml/luci-app-alist package/alist
#sed -i 's/网络存储/存储/g' ./package/alist/luci-app-alist/po/zh-cn/alist.po
#rm -rf feeds/packages/lang/golang
# svn export https://github.com/sbwml/packages_lang_golang/branches/19.x feeds/packages/lang/golang
#git clone https://github.com/sbwml/packages_lang_golang -b 20.x feeds/packages/lang/golang


#cifs
#sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-cifs-mount/luasrc/controller/cifs.lua   #dnsfilter

#dnsmasq
#rm -rf ./package/network/services/dnsmasq package/feeds/packages/dnsmasq
#svn export https://github.com/immortalwrt/immortalwrt/branches/openwrt-18.06-k5.4/package/network/services/dnsmasq ./package/network/services/dnsmasq

#upnp
#rm -rf ./feeds/packages/net/miniupnpd
#svn export https://github.com/sirpdboy/sirpdboy-package/trunk/upnpd/miniupnp   ./feeds/packages/net/miniupnp
#rm -rf ./feeds/luci/applications/luci-app-upnp  package/feeds/packages/luci-app-upnp
#svn export https://github.com/sirpdboy/sirpdboy-package/trunk/upnpd/luci-app-upnp ./feeds/luci/applications/luci-app-upnp

#无链接
# mv -f ./package/other/patch/index.htm ./package/lean/autocore/files/x86/index.htm


#设置
sed -i 's/option enabled.*/option enabled 0/' feeds/*/*/*/*/upnpd.config
sed -i 's/option dports.*/option enabled 2/' feeds/*/*/*/*/upnpd.config

sed -i "s/ImmortalWrt/OpenWrt/" {package/base-files/files/bin/config_generate,include/version.mk}
sed -i "/listen_https/ {s/^/#/g}" package/*/*/*/files/uhttpd.config

echo '替换smartdns'
# rm -rf ./feeds/packages/net/smartdns package/feeds/packages/smartdns
# svn export https://github.com/sirpdboy/sirpdboy-package/trunk/smartdns ./feeds/packages/net/smartdns


# netdata 
#rm -rf ./feeds/luci/applications/luci-app-netdata package/feeds/packages/luci-app-netdata
# rm -rf ./feeds/packages/admin/netdata
#svn export https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-netdata ./feeds/luci/applications/luci-app-netdata
# svn export https://github.com/loso3000/mypk/trunk/up/netdata ./feeds/packages/admin/netdata
#ln -sf ../../../feeds/luci/applications/luci-app-netdata ./package/feeds/luci/luci-app-netdata

#rm -rf ./feeds/luci/applications/luci-app-arpbind
#svn export https://github.com/loso3000/other/trunk/up/luci-app-arpbind ./feeds/luci/applications/luci-app-arpbind 
#ln -sf ../../../feeds/luci/applications/luci-app-arpbind ./package/feeds/luci/luci-app-arpbind
#rm -rf ./package/other/up/luci-app-arpbind

# Add luci-app-dockerman
# rm -rf ./feeds/luci/applications/luci-app-dockerman
# rm -rf ./feeds/luci/applications/luci-app-docker
# rm -rf ./feeds/luci/collections/luci-lib-docker
# rm -rf ./package/diy/luci-app-dockerman
# rm -rf ./feeds/packages/utils/docker
# git clone --depth=1 https://github.com/lisaac/luci-lib-docker ./package/new/luci-lib-docker
# git clone --depth=1 https://github.com/lisaac/luci-app-dockerman ./package/new/luci-app-dockerman

# svn export https://github.com/lisaac/luci-lib-docker/trunk/collections/luci-lib-docker ./package/new/luci-lib-docke
# svn export https://github.com/lisaac/luci-app-dockerman/trunk/applications/luci-app-dockerman ./package/new/luci-app-dockerman
# sed -i '/auto_start/d' ./package/diy/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
# sed -i '/sysctl.d/d' feeds/packages/utils/dockerd/Makefile
# sed -i 's,# CONFIG_BLK_CGROUP_IOCOST is not set,CONFIG_BLK_CGROUP_IOCOST=y,g' target/linux/generic/config-5.10
# sed -i 's,# CONFIG_BLK_CGROUP_IOCOST is not set,CONFIG_BLK_CGROUP_IOCOST=y,g' target/linux/generic/config-5.15
# sed -i 's/+dockerd/+dockerd +cgroupfs-mount/' ./package/new/luci-app-dockerman/Makefile
# sed -i '$i /etc/init.d/dockerd restart &' ./package/new/luci-app-dockerman/root/etc/uci-defaults/*

# Add luci-aliyundrive-webdav
rm -rf ./feeds/luci/applications/luci-app-aliyundrive-webdav 
rm -rf ./feeds/luci/applications/aliyundrive-webdav

#svn export https://github.com/messense/aliyundrive-webdav/trunk/openwrt/aliyundrive-webdav ./feeds/luci/applications/aliyundrive-webdav
#svn export https://github.com/messense/aliyundrive-webdav/trunk/openwrt/luci-app-aliyundrive-webdav ./feeds/luci/applications/luci-app-aliyundrive-webdav 

# samba4
# rm -rf ./package/other/up/samba4
# rm -f ./feeds/packages/net/samba4  package/feeds/packages/samba4
# mv ./package/other/up/samba4 ./feeds/packages/net/samba4 
# svn export https://github.com/loso3000/other/trunk/up/samba4 ./feeds/packages/net/samba4
# rm -rf ./feeds/luci/applications/luci-app-samba4  ./package/other/up/luci-app-samba4
#svn export https://github.com/loso3000/other/trunk/up/luci-app-samba4 ./feeds/luci/applications/luci-app-samba4

#zerotier 
# rm -rf  luci-app-zerotier && git clone https://github.com/rufengsuixing/luci-app-zerotier.git feeds/luci/applications/luci-app-zerotier  #取消防火墙
# svn export https://github.com/immortalwrt/luci/trunk/applications/luci-app-zerotier feeds/luci/applications/luci-app-zerotier
# ln -sf ../../../feeds/luci/applications/luci-app-zerotier ./package/feeds/luci/luci-app-zerotier
# rm -rf ./feeds/packages/net/zerotier
# svn export https://github.com/openwrt/packages/trunk/net/zerotier feeds/packages/net/zerotier
# rm -rf ./feeds/packages/net/zerotier/files/etc/init.d/zerotier

# rm -rf ./feeds/packages/net/softethervpn5 package/feeds/packages/softethervpn5
# svn export https://github.com/loso3000/other/trunk/up/softethervpn5 ./feeds/packages/net/softethervpn5

# rm -rf ./feeds/luci/applications/luci-app-socat  ./package/feeds/luci/luci-app-socat
# svn export https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-socat ./feeds/luci/applications/luci-app-socat
# ln -sf ../../../feeds/luci/applications/luci-app-socat ./package/feeds/luci/luci-app-socat

sed -i 's/msgstr "Socat"/msgstr "端口转发"/g' ./feeds/luci/applications/luci-app-socat/po/*/socat.po

sed -i 's/"Argon 主题设置"/"Argon设置"/g' `grep "Argon 主题设置" -rl ./`
sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' `grep "Turbo ACC 网络加速" -rl ./`
sed -i 's/"网络存储"/"存储"/g' `grep "网络存储" -rl ./`
sed -i 's/"USB 打印服务器"/"打印服务"/g' `grep "USB 打印服务器" -rl ./`
sed -i 's/"带宽监控"/"监控"/g' `grep "带宽监控" -rl ./`
sed -i 's/实时流量监测/流量/g'  `grep "实时流量监测" -rl ./`
sed -i 's/解锁网易云灰色歌曲/解锁灰色歌曲/g'  `grep "解锁网易云灰色歌曲" -rl ./`
sed -i 's/解除网易云音乐播放限制/解锁灰色歌曲/g'  `grep "解除网易云音乐播放限制" -rl ./`
sed -i 's/家庭云//g'  `grep "家庭云" -rl ./`

sed -i 's/监听端口/监听端口 用户名admin密码adminadmin/g' ./feeds/luci/applications/luci-app-qbittorrent/po/*/qbittorrent.po
# echo  "        option tls_enable 'true'" >> ./feeds/luci/applications/luci-app-frpc/root/etc/config/frp   #FRP穿透问题
sed -i 's/invalid/# invalid/g' ./package/network/services/samba36/files/smb.conf.template  #共享问题
sed -i '/mcsub_renew.datatype/d'  ./feeds/luci/applications/luci-app-udpxy/luasrc/model/cbi/udpxy.lua  #修复UDPXY设置延时55的错误
sed -i '/filter_/d' ./package/network/services/dnsmasq/files/dhcp.conf   #DHCP禁用IPV6问题
sed -i 's/请输入用户名和密码。/管理登陆/g' ./feeds/luci/modules/luci-base/po/*/base.po   #用户名密码

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


# Fix libssh
# rm -rf feeds/packages/libs
# svn export https://github.com/openwrt/packages/trunk/libs/libssh feeds/packages/libs/

# git clone https://github.com/yaof2/luci-app-ikoolproxy.git package/luci-app-ikoolproxy
# sed -i 's/, 1).d/, 11).d/g' ./package/luci-app-ikoolproxy/luasrc/controller/koolproxy.lua

# Add OpenClash

# Add OpenClash
rm -rf  ./feeds/luci/applications/luci-app-openclash
svn export https://github.com/vernesong/OpenClash/trunk/luci-app-openclash ./package/diy/luci-app-openclash
# svn export https://github.com/vernesong/OpenClash/branches/dev/luci-app-openclash package/new/luci-app-openclash
# sed -i 's/+libcap /+libcap +libcap-bin /' package/new/luci-app-openclash/Makefile

rm -rf  ./feeds/luci/applications/luci-app-passwall
rm -rf  ./feeds/luci/applications/luci-app-passwall2
git clone https://github.com/xiaorouji/openwrt-passwall2.git package/passwall2
git clone https://github.com/xiaorouji/openwrt-passwall package/passwall
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
#bypass
svn export https://github.com/loso3000/other/trunk/up/pass/luci-app-bypass ./package/luci-app-bypass
rm ./package/luci-app-bypass/po/zh_Hans && mv ./package/luci-app-bypass/po/zh-cn ./package/luci-app-bypass/po/zh_Hans
# sed -i 's,default n,default y,g' package/luci-app-bypass/Makefile

sed -i 's/START=95/START=99/' `find package/ -follow -type f -path */ddns-scripts/files/ddns.init`

# Remove some default packages
# sed -i 's/luci-app-ddns//g;s/luci-app-upnp//g;s/luci-app-adbyby-plus//g;s/luci-app-vsftpd//g;s/luci-app-ssr-plus//g;s/luci-app-unblockmusic//g;s/luci-app-vlmcsd//g;s/luci-app-wol//g;s/luci-app-nlbwmon//g;s/luci-app-accesscontrol//g' include/target.mk
# sed -i 's/luci-app-adbyby-plus//g;s/luci-app-vsftpd//g;s/luci-app-ssr-plus//g;s/luci-app-unblockmusic//g;s/luci-app-vlmcsd//g;s/luci-app-wol//g;s/luci-app-nlbwmon//g;s/luci-app-accesscontrol//g' include/target.mk
#Add x550
# git clone https://github.com/shenlijun/openwrt-x550-nbase-t package/openwrt-x550-nbase-t

# config_file_turboacc=`find package/ -follow -type f -path '*/luci-app-turboacc/root/etc/config/turboacc'`
# sed -i "s/option hw_flow '1'/option hw_flow '0'/" $config_file_turboacc
# sed -i "s/option sfe_flow '1'/option sfe_flow '0'/" $config_file_turboacc
# sed -i "s/option sfe_bridge '1'/option sfe_bridge '0'/" $config_file_turboacc
# sed -i "/dep.*INCLUDE_.*=n/d" `find package/ -follow -type f -path '*/luci-app-turboacc/Makefile'`

sed -i "s/option limit_enable '1'/option limit_enable '0'/" `find package/ -follow -type f -path '*/nft-qos/files/nft-qos.config'`
sed -i "s/option enabled '1'/option enabled '0'/" `find package/ -follow -type f -path '*/vsftpd-alt/files/vsftpd.uci'`

#设置
sed -i 's/option enabled.*/option enabled 0/' feeds/*/*/*/*/upnpd.config
# sed -i 's/option dports.*/option enabled 0/' feeds/*/*/*/*/upnpd.config

sed -i 's/START=95/START=99/' `find package/ -follow -type f -path */ddns-scripts/files/ddns.init`

# 修改makefile
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/include\ \.\.\/\.\.\/luci\.mk/include \$(TOPDIR)\/feeds\/luci\/luci\.mk/g' {}
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/include\ \.\.\/\.\.\/lang\/golang\/golang\-package\.mk/include \$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang\-package\.mk/g' {}

# 修复 hostapd 报错
cp -f  ./patch/011-fix-mbo-modules-build.patch package/network/services/hostapd/patches/011-fix-mbo-modules-build.patch
# 取消主题默认设置
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;
sed -i '/check_signature/d' ./package/system/opkg/Makefile   # 删除IPK安装签名

# sed -i 's/kmod-usb-net-rtl8152/kmod-usb-net-rtl8152-vendor/' target/linux/rockchip/image/armv8.mk target/linux/sunxi/image/cortexa53.mk target/linux/sunxi/image/cortexa7.mk

# sed -i 's/KERNEL_PATCHVER:=6.1/KERNEL_PATCHVER:=5.4/g' ./target/linux/*/Makefile
# sed -i 's/KERNEL_PATCHVER:=5.15/KERNEL_PATCHVER:=5.4/g' ./target/linux/*/Makefile

#zzz-default-settingsim
# curl -fsSL  https://raw.githubusercontent.com/loso3000/other/master/patch/default-settings/zzz-default-settingsim > ./package/lean/default-settings/files/zzz-default-settings

# 预处理下载相关文件，保证打包固件不用单独下载
for sh_file in `ls ${GITHUB_WORKSPACE}/openwrt/common/*.sh`;do
    source $sh_file amd64
done

if [[ $DATE_S == 'default' ]]; then
   DATA=`TZ=UTC-8 date +%Y.%m.%d -d +"12"hour`
else 
   DATA=$DATE_S
fi
[[ -n $CONFIG_S ]] || CONFIG_S=Super
VER1="$(grep "KERNEL_PATCHVER:="  ./target/linux/x86/Makefile | cut -d = -f 2)"
ver54=`grep "LINUX_VERSION-5.4 ="  include/kernel-5.4 | cut -d . -f 3`
ver515=`grep "LINUX_VERSION-5.15 ="  include/kernel-5.15 | cut -d . -f 3`
ver61=`grep "LINUX_VERSION-6.1 ="  include/kernel-6.1 | cut -d . -f 3`
date1="VIP-${CONFIG_S}-${DATA}_by_Sirpdboy"
if [ "$VER1" = "5.4" ]; then
date2="EzOpWrt VIP-${CONFIG_S}-${DATA}-${VER1}.${ver54}_by_Sirpdboy"
elif [ "$VER1" = "5.15" ]; then
date2="EzOpWrt VIP-${CONFIG_S}-${DATA}-${VER1}.${ver515}_by_Sirpdboy"
elif [ "$VER1" = "6.1" ]; then
date2="EzOpWrt VIP-${CONFIG_S}-${DATA}-${VER1}.${ver61}_by_Sirpdboy"
fi
echo "${date1}" > ./package/base-files/files/etc/ezopenwrt_version
echo "${date2}" >> ./package/base-files/files/etc/banner
echo '---------------------------------' >> ./package/base-files/files/etc/banner
[ ! -d files/root ] || mkdir -p files/root
[ -f ./files/root/.zshrc ] || cp  -Rf patch/z.zshrc files/root/.zshrc
[ -f ./files/root/.zshrc ] || cp  -Rf ./z.zshrc ./files/root/.zshrc

cat>buildmd5.sh<<-\EOF
#!/bin/bash
rm -rf  bin/targets/x86/64/config.buildinfo
rm -rf  bin/targets/x86/64/feeds.buildinfo
rm -rf  bin/targets/x86/64/*x86-64-generic-kernel.bin
rm -rf  bin/targets/x86/64/*x86-64-generic-squashfs-rootfs.img.gz
rm -rf  bin/targets/x86/64/*x86-64-generic-rootfs.tar.gz
rm -rf  bin/targets/x86/64/*x86-64-generic.manifest
rm -rf  bin/targets/x86/64/sha256sums
rm -rf  bin/targets/x86/64/version.buildinfo
rm -rf bin/targets/x86/64/*x86-64-generic-ext4-rootfs.img.gz
rm -rf bin/targets/x86/64/*x86-64-generic-ext4-combined-efi.img.gz
rm -rf bin/targets/x86/64/*x86-64-generic-ext4-combined.img.gz
rm -rf bin/targets/x86/64/profiles.json
sleep 2
r_version=`cat ./package/base-files/files/etc/ezopenwrt_version`
VER1="$(grep "KERNEL_PATCHVER:="  ./target/linux/x86/Makefile | cut -d = -f 2)"
ver54=`grep "LINUX_VERSION-5.4 ="  include/kernel-5.4 | cut -d . -f 3`
ver515=`grep "LINUX_VERSION-5.15 ="  include/kernel-5.15 | cut -d . -f 3`
ver61=`grep "LINUX_VERSION-6.1 ="  include/kernel-6.1 | cut -d . -f 3`
sleep 2
if [ "$VER1" = "5.4" ]; then
mv  bin/targets/x86/64/*-x86-64-generic-squashfs-combined.img.gz       bin/targets/x86/64/EzOpenWrt-${r_version}_${VER1}.${ver54}-x86-64-combined.img.gz   
mv  bin/targets/x86/64/*-x86-64-generic-squashfs-combined-efi.img.gz   bin/targets/x86/64/EzOpenWrt-${r_version}_${VER1}.${ver54}-x86-64-combined-efi.img.gz
md5_EzOpWrt=EzOpenWrt-${r_version}_${VER1}.${ver54}-x86-64-combined.img.gz   
md5_EzOpWrt_uefi=EzOpenWrt-${r_version}_${VER1}.${ver54}-x86-64-combined-efi.img.gz
elif [ "$VER1" = "5.15" ]; then
mv  bin/targets/x86/64/*-x86-64-generic-squashfs-combined.img.gz       bin/targets/x86/64/EzOpenWrt-${r_version}_${VER1}.${ver515}-x86-64-combined.img.gz   
mv  bin/targets/x86/64/*-x86-64-generic-squashfs-combined-efi.img.gz   bin/targets/x86/64/EzOpenWrt-${r_version}_${VER1}.${ver515}-x86-64-combined-efi.img.gz
md5_EzOpWrt=EzOpenWrt-${r_version}_${VER1}.${ver515}-x86-64-combined.img.gz   
md5_EzOpWrt_uefi=EzOpenWrt-${r_version}_${VER1}.${ver515}-x86-64-combined-efi.img.gz
elif [ "$VER1" = "6.1" ]; then
mv  bin/targets/x86/64/*-x86-64-generic-squashfs-combined.img.gz       bin/targets/x86/64/EzOpenWrt-${r_version}_${VER1}.${ver61}-x86-64-combined.img.gz   
mv  bin/targets/x86/64/*-x86-64-generic-squashfs-combined-efi.img.gz   bin/targets/x86/64/EzOpenWrt-${r_version}_${VER1}.${ver61}-x86-64-combined-efi.img.gz
md5_EzOpWrt=EzOpenWrt-${r_version}_${VER1}.${ver61}-x86-64-combined.img.gz   
md5_EzOpWrt_uefi=EzOpenWrt-${r_version}_${VER1}.${ver61}-x86-64-combined-efi.img.gz
fi
#md5
cd bin/targets/x86/64
md5sum ${md5_EzOpWrt} > EzOpWrt_combined.md5  || true
md5sum ${md5_EzOpWrt_uefi} > EzOpWrt_combined-efi.md5 || true
exit 0
EOF

cat>bakkmod.sh<<-\EOF
#!/bin/bash
kmoddirdrv=./files/etc/kmod.d/drv
kmoddirdocker=./files/etc/kmod.d/docker
bakkmodfile=./kmod.source
nowkmodfile=./files/etc/kmod.now
mkdir -p $kmoddirdrv 2>/dev/null
mkdir -p $kmoddirdocker 2>/dev/null
cp -rf ./patch/list.txt $bakkmodfile
mkdir -p files/etc/uci-defaults/
cp -rf ./patch/init-settings.sh files/etc/uci-defaults/99-init-settings
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
EOF

cat>./package/base-files/files/etc/kmodreg<<-\EOF
#!/bin/bash
# https://github.com/sirpdboy/openWrt
# EzOpenWrt By Sirpdboy
IPK=$1
nowkmoddir=/etc/kmod.d/$IPK
[ ! -d $nowkmoddir ]  || return

run_drv() {
opkg update
for file in `ls $nowkmoddir/*.ipk`;do
    opkg install "$file"  --force-depends
done

}
run_docker() {
opkg update
opkg install $nowkmoddir/luci-app-dockerman*.ipk --force-depends
opkg install $nowkmoddir/luci-i18n-dockerman*.ipk --force-depends

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


./scripts/feeds update -i
cat  ./x86_64/${CONFIG_S}  > .config
cat  ./x86_64/comm  >> .config
