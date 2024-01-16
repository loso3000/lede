#!/usr/bin/env bash

config_generate=package/base-files/files/bin/config_generate
[ ! -d files/root ] || mkdir -p files/root

color() {
	case $1 in
		cy) echo -e "\033[1;33m$2\033[0m" ;;
		cr) echo -e "\033[1;31m$2\033[0m" ;;
		cg) echo -e "\033[1;32m$2\033[0m" ;;
		cb) echo -e "\033[1;34m$2\033[0m" ;;
	esac
}

git_exp() {
    local repo_url branch target_dir source_dir current_dir destination_dir
    if [[ "$1" == */* ]]; then
        repo_url="$1"
        shift
    else
        branch="-b $1"
        repo_url="$2"
        shift 2
    fi

    if ! git clone -q $branch --depth 1 "https://github.com/$repo_url" gitemp; then
        echo -e "$(color cr 拉取) https://github.com/$repo_url [ $(color cr ✕) ]" | _printf
        return 0
    fi

    for target_dir in "$@"; do
        source_dir=$(find gitemp -maxdepth 5 -type d -name "$target_dir" -print -quit)
        current_dir=$(find package/ feeds/ target/ -maxdepth 5 -type d -name "$target_dir" -print -quit)
        destination_dir="${current_dir:-package/A/$target_dir}"
        if [[ -d $current_dir && $destination_dir != $current_dir ]]; then
            mv -f "$current_dir" ../
        fi

        if [[ -d $source_dir ]]; then
            if mv -f "$source_dir" "$destination_dir"; then
                if [[ $destination_dir = $current_dir ]]; then
                    echo -e "$(color cg 替换) $target_dir [ $(color cg ✔) ]" | _printf
                else
                    echo -e "$(color cb 添加) $target_dir [ $(color cb ✔) ]" | _printf
                fi
            fi
        fi
    done

    rm -rf gitemp
}

_printf() {
	awk '{printf "%s %-40s %s %s %s\n" ,$1,$2,$3,$4,$5}'
}

git_url() {
	# set -x
	for x in $@; do
		name="${x##*/}"
		if [[ "$(grep "^https" <<<$x | egrep -v "helloworld$|build$|openwrt-passwall-packages$")" ]]; then
			g=$(find package/ target/ feeds/ -maxdepth 5 -type d -name "$name" 2>/dev/null | grep "/${name}$" | head -n 1)
			if [[ -d $g ]]; then
				mv -f $g ../ && k="$g"
			else
				k="package/A/$name"
			fi

			git clone -q $x $k && f="1"

			if [[ -n $f ]]; then
				if [[ $k = $g ]]; then
					echo -e "$(color cg 替换) $name [ $(color cg ✔) ]" | _printf
				else
					echo -e "$(color cb 添加) $name [ $(color cb ✔) ]" | _printf
				fi
			else
				echo -e "$(color cr 拉取) $name [ $(color cr ✕) ]" | _printf
				if [[ $k = $g ]]; then
					mv -f ../${g##*/} ${g%/*}/ && \
					echo -e "$(color cy 回退) ${g##*/} [ $(color cy ✔) ]" | _printf
				fi
			fi
			unset -v f k g
		else
			for w in $(grep "^https" <<<$x); do
				git clone -q $w ../${w##*/} && {
					for z in `ls -l ../${w##*/} | awk '/^d/{print $NF}' | grep -Ev 'dump$|dtest$'`; do
						g=$(find package/ feeds/ target/ -maxdepth 5 -type d -name $z 2>/dev/null | head -n 1)
						if [[ -d $g ]]; then
							rm -rf $g && k="$g"
						else
							k="package/A"
						fi
						if mv -f ../${w##*/}/$z $k; then
							if [[ $k = $g ]]; then
								echo -e "$(color cg 替换) $z [ $(color cg ✔) ]" | _printf
							else
								echo -e "$(color cb 添加) $z [ $(color cb ✔) ]" | _printf
							fi
						fi
						unset -v k g
					done
				} && rm -rf ../${w##*/}
			done
		fi
	done
	# set +x
}

_packages() {
	for z in $@; do
		[[ $z =~ ^# ]] || echo "CONFIG_PACKAGE_$z=y" >>.config
	done
}

_delpackage() {
	for z in $@; do
		[[ $z =~ ^# ]] || sed -i -E "s/(CONFIG_PACKAGE_.*$z)=y/# \1 is not set/" .config
	done
}

[[ -n $CONFIG_S ]] || CONFIG_S=Super

sed -i "s/ImmortalWrt/OpenWrt/" {package/base-files/files/bin/config_generate,include/version.mk}
sed -i "s/ImmortalWrt/openwrt/" ./feeds/luci/modules/luci-mod-system/htdocs/luci-static/resources/view/system/flash.js  #改登陆域名
#删除冲突插件
# rm -rf $(find ./feeds/luci/ -type d -regex ".*\(argon\|design\|openclash\).*")
rm -rf package/feeds/packages/prometheus-node-exporter-lua
rm -rf feeds/packages/prometheus-node-exporter-lua

rm -rf $(find ./package/emortal/ -type d -regex ".*\(autocore\|automount\|autosamba\|default-settings\).*")
mv -rf ./package/emortal2/autocore  ./package/emortal/autocore 
mv -rf  ./package/emortal2/default-settings   ./package/emortal/default-settings 
mv -rf  ./package/emortal2/automount   ./package/emortal/automount
mv -rf  ./package/emortal2/autosamba   ./package/emortal/autosamba

case "${CONFIG_S}" in
Plus)
;;
Bypass)
;;
Vip-Plus)
;;
Vip-Bypass)
;;
*)
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json
sed -i 's/nas/services/g' ./feeds/luci/applications/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json
;;
esac

case "${CONFIG_S}" in
"Vip"*)
#修改默认IP地址
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate
CONFIG_Y="$CONFIG_S"
;;
*)
#修改默认IP地址
sed -i 's/192.168.1.1/192.168.8.1/g' package/base-files/files/bin/config_generate
CONFIG_Y="Free-$CONFIG_S"
;;
esac
sed -i 's/services/status/g' ./feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json

# rm -rf ./package/emortal2
#rm -rf  package/js2

rm -rf  feeds/packages/net/wrtbwmon
rm -rf  ./feeds/luci/applications/luci-app-wrtbwmon 
rm -rf  ./feeds/luci/applications/luci-app-arpbind
rm -rf  ./feeds/luci/applications/luci-app-netdata
rm -rf  ./feeds/packages/net/open-app-filter
rm -rf  ./feeds/packages/net/oaf
rm -rf  ./feeds/luci/applications/luci-app-appfilter
#rm -rf  ./package/wget 
rm -rf  ./feeds/packages/net/wget
mv -rf ./package/wget  ./feeds/packages/net/wget
#aria2
rm -rf ./feeds/packages/net/aria2
rm -rf ./feeds/packages/net/ariang
rm -rf ./feeds/luci/applications/luci-app-aria2  package/feeds/packages/luci-app-aria2

rm -rf ./feeds/luci/applications/chinadns-ng package/feeds/packages/chinadns-ng
# git clone https://github.com/xiaorouji/openwrt-passwall2.git package/passwall2
# git clone https://github.com/xiaorouji/openwrt-passwall package/passwall
# git clone https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall

rm -rf ./package/openwrt-passwall/v2ray-geodata
rm -rf ./package/openwrt-passwall/mosdns

git_exp QiuSimons/OpenWrt-Add  trojan-plus
git_exp fw876/helloworld lua-neturl
git_exp fw876/helloworld shadow-tls
git_exp fw876/helloworld srelay

#bypass
# rm -rf ./feeds/luci/applications/luci-app-passwall
# rm -rf ./feeds/luci/applications/luci-app-passwall2
rm -rf ./feeds/luci/applications/luci-app-vssr
rm -rf ./feeds/luci/applications/luci-app-ssr-plus  package/feeds/packages/luci-app-ssr-plus
# rm -rf ./feeds/luci/applications/luci-app-passwall  package/feeds/packages/luci-app-passwall

git_exp loso3000/other luci-app-bypass 
git_exp loso3000/other luci-app-ssr-plus

rm ./package/A/luci-app-bypass/po/zh_Hans
mv ./package/A/luci-app-bypass/po/zh-cn ./package/A/luci-app-bypass/po/zh_Hans
rm ./package/A/luci-app-ssr-plus/po/zh_Hans
mv ./package/A/luci-app-ssr-plus/po/zh-cn ./package/A/luci-app-ssr-plus/po/zh_Hans
sed -i 's,default n,default y,g' package/A/luci-app-bypass/Makefile


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

rm -rf ./feeds/luci/themes/luci-theme-design
 git clone -b js https://github.com/gngpp/luci-theme-design.git  package/luci-theme-design
#rm -rf ./feeds/luci/themes/luci-theme-argon
sed -i 's,media .. \"\/b,resource .. \"\/b,g' ./feeds/luci/themes/luci-theme-argon/luasrc/view/themes/argon/sysauth.htm

#修改默认主机名
sed -i "s/hostname='.*'/hostname='EzOpWrt'/g" ./package/base-files/files/bin/config_generate
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" ./package/base-files/files/bin/config_generate
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" ./package/base-files/files/bin/config_generate

# rm -rf ./package/network/utils/iproute2/
# svn export https://github.com/openwrt/openwrt/trunk/package/network/utils/iproute2 ./package/network/utils/iproute2

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

# Add ddnsto & linkease
# git_exp linkease/nas-packages-luci luci
# git_exp linkease/nas-packages services ffmpeg-remux
# git_exp linkease/istore luci
git clone  https://github.com/linkease/nas-packages-luci ./package/nas-packages-luci
git clone  https://github.com/linkease/nas-packages ./package/nas-packages
git clone  https://github.com/linkease/istore ./package/istore
# svn export https://github.com/linkease/nas-packages-luci/trunk/luci/ ./package/diy1/luci
# svn export https://github.com/linkease/nas-packages/trunk/network/services/ ./package/diy1/linkease
# svn export https://github.com/linkease/nas-packages/trunk/multimedia/ffmpeg-remux/ ./package/diy1/ffmpeg-remux
# svn export https://github.com/linkease/istore/trunk/luci/ ./package/diy1/istore
sed -i 's/1/0/g' ./package/nas-packages/network/services/linkease/files/linkease.config
sed -i 's/luci-lib-ipkg/luci-base/g' package/istore/luci/luci-app-store/Makefile
# svn export https://github.com/linkease/istore-ui/trunk/app-store-ui package/app-store-ui

#qbittorrent
rm -rf packages/qbittorrent
#rm -rf ./feeds/packages/net/qbittorrent
#rm -rf ./feeds/packages/net/qBittorrent-Enhanced-Edition
#rm -rf ./feeds/packages/net/qBittorrent-static
#rm -rf ./feeds/luci/applications/luci-app-qbittorrent  package/feeds/packages/luci-app-qbittorrent

rm -rf ./feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
git clone https://github.com/sbwml/v2ray-geodata feeds/packages/net/v2ray-geodata
rm -rf ./feeds/packages/net/mosdns
rm -rf ./feeds/luci/luci-app-mosdns
# git_exp sbwml/luci-app-mosdns luci-app-mosdns
# git_exp sbwml/luci-app-mosdns mosdns

# 添加额外软件包alist
git clone https://github.com/sbwml/luci-app-alist package/alist
sed -i 's/网络存储/存储/g' ./package/alist/luci-app-alist/po/zh-cn/alist.po
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 20.x feeds/packages/lang/golang

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
sed -i 's/+libcap /+libcap +libcap-bin /' package/new/luci-app-openclash/Makefile

sed -i 's/START=95/START=99/' `find package/ -follow -type f -path */ddns-scripts/files/ddns.init`

# Remove some default packages
# sed -i 's/luci-app-ddns//g;s/luci-app-upnp//g;s/luci-app-adbyby-plus//g;s/luci-app-vsftpd//g;s/luci-app-ssr-plus//g;s/luci-app-unblockmusic//g;s/luci-app-vlmcsd//g;s/luci-app-wol//g;s/luci-app-nlbwmon//g;s/luci-app-accesscontrol//g' include/target.mk
# sed -i 's/luci-app-adbyby-plus//g;s/luci-app-vsftpd//g;s/luci-app-ssr-plus//g;s/luci-app-unblockmusic//g;s/luci-app-vlmcsd//g;s/luci-app-wol//g;s/luci-app-nlbwmon//g;s/luci-app-accesscontrol//g' include/target.mk
#Add x550
# git clone https://github.com/shenlijun/openwrt-x550-nbase-t package/openwrt-x550-nbase-t

sed -i 's/START=95/START=99/' `find package/ -follow -type f -path */ddns-scripts/files/ddns.init`

# 修改makefile
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/include\ \.\.\/\.\.\/luci\.mk/include \$(TOPDIR)\/feeds\/luci\/luci\.mk/g' {}
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/include\ \.\.\/\.\.\/lang\/golang\/golang\-package\.mk/include \$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang\-package\.mk/g' {}

# 修复 hostapd 报错
cp -f  ./patch/011-fix-mbo-modules-build.patch package/network/services/hostapd/patches/011-fix-mbo-modules-build.patch

# 取消主题默认设置
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;
sed -i '/check_signature/d' ./package/system/opkg/Makefile   # 删除IPK安装签名

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


VER1="$(grep "KERNEL_PATCHVER:="  ./target/linux/x86/Makefile | cut -d = -f 2)"
ver54=`grep "LINUX_VERSION-5.4 ="  include/kernel-5.4 | cut -d . -f 3`
ver515=`grep "LINUX_VERSION-5.15 ="  include/kernel-5.15 | cut -d . -f 3`
ver61=`grep "LINUX_VERSION-6.1 ="  include/kernel-6.1 | cut -d . -f 3`

date1="${CONFIG_Y}-${DATA}_by_Sirpdboy"
if [ "$VER1" = "5.4" ]; then
date2="EzOpWrt ${CONFIG_S}-${DATA}-${VER1}.${ver54}_by_Sirpdboy"
elif [ "$VER1" = "5.15" ]; then
date2="EzOpWrt ${CONFIG_S}-${DATA}-${VER1}.${ver515}_by_Sirpdboy"
elif [ "$VER1" = "6.1" ]; then
date2="EzOpWrt ${CONFIG_S}-${DATA}-${VER1}.${ver61}_by_Sirpdboy"
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
rm -rf  bin/targets/x86/64/*.vmdk
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
cd bin/targets/*/*

md5sum ${md5_EzOpWrt} > EzOpWrt_combined.md5  || true
md5sum ${md5_EzOpWrt_uefi} > EzOpWrt_combined-efi.md5 || true
exit 0
EOF

cat>bakkmod.sh<<-\EOF
#!/bin/bash
kmoddirdrv=./files/etc/kmod.d/drv
kmoddirdocker=./files/etc/kmod.d/docker
bakkmodfile=../patch/kmod.source
nowkmodfile=./files/etc/kmod.now
mkdir -p $kmoddirdrv 2>/dev/null
mkdir -p $kmoddirdocker 2>/dev/null
cp -rf ./patch/list.txt $bakkmodfile
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
	uci -q get dockerd.globals 2>/dev/null && {
		uci -q set dockerd.globals.data_root='/opt/docker/'
		uci -q set dockerd.globals.auto_start='1'
  		uci commit dockerd
  		/etc/init.d/dockerd enabled
		rm -rf /tmp/luci*
		/etc/init.d/dockerd restart
		/etc/init.d/rpcd restart
	}
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
case "${CONFIG_S}" in
"Vip"*)
cat  ./x86_64/comm  >> .config
;;
esac
