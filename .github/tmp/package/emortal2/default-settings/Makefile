#
# Copyright (C) 2016-2017 GitHub 
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=default-settings
PKG_VERSION:=1.1
PKG_RELEASE:=$(COMMITCOUNT)
PKG_LICENSE:=GPL-3.0


include $(INCLUDE_DIR)/package.mk

define Package/default-settings
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=LuCI support for Default Settings
  DEPENDS:=+luci
  PKGARCH:=all
  DEPENDS:=+luci-lib-base
endef

define Package/default-settings/description
	Default Settings & Language Support Packages.
endef


define Build/Compile
endef

define Package/default-settings/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/99-default-settings $(1)/etc/uci-defaults/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./i18n/default.zh_Hans.po $(1)/usr/lib/lua/luci/i18n/default.zh-cn.lmo
	po2lmo ./i18n/more.zh_Hans.po $(1)/usr/lib/lua/luci/i18n/more.zh-cn.lmo
endef

$(eval $(call BuildPackage,default-settings))
