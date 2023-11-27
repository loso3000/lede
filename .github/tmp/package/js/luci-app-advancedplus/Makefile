#
# Copyright 2019-2023 sirpdboy 
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk
NAME:=advancedplus
PKG_NAME:=luci-app-$(NAME)
LUCI_TITLE:=LuCI support for Kucat theme setting by sirpdboy
LUCI_DEPENDS:=+luci-compat
LUCI_PKGARCH:=all

PKG_VERSION:=1.6.13
PKG_RELEASE:=20231128

define Package/$(PKG_NAME)/conffiles
/etc/config/advancedplus
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature


