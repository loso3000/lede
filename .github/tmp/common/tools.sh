#!/bin/bash
#=================================================
# File name: preset-terminal-tools.sh
# System Required: Linux
# Version: 1.0
# Lisence: MIT
# Author: SuLingGG
# Blog: https://mlapp.cn
#=================================================
if [ $1 == amd64 ] ;then
BASE_FILES=${GITHUB_WORKSPACE}/openwrt/package/base-files/files
singbox_version="1.8.8"
hysteria_version="2.3.0"
# wget --quiet --no-check-certificate -P /tmp https://github.com/SagerNet/sing-box/releases/download/v${singbox_version}/sing-box-${singbox_version}-linux-amd64.tar.gz
wget --quiet --no-check-certificate -P /tmp https://github.com/apernet/hysteria/releases/download/app%2Fv${hysteria_version}/hysteria-linux-amd64
mkdir  -p ${BASE_FILES}/usr/bin
tar -xvzf /tmp/sing-box-${singbox_version}-linux-amd64.tar.gz -C /tmp
#cp -r /tmp/sing-box-${singbox_version}-linux-amd64/sing-box ${BASE_FILES}/usr/bin
cp -r /tmp/hysteria-linux-amd64 ${BASE_FILES}/usr/bin/hysteria
chmod 777 ${BASE_FILES}/usr/bin/sing-box ${BASE_FILES}/usr/bin/hysteria
fi
mkdir -p files/root
cp  -rf ./patch/z.zshrc ./files/root/.zshrc
pushd files/root

## Install oh-my-zsh
# Clone oh-my-zsh repository
git clone https://github.com/ohmyzsh/ohmyzsh ./.oh-my-zsh

# git clone https://github.com/robbyrussell/oh-my-zsh ./.oh-my-zsh
# Install extra plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ./.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ./.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ./.oh-my-zsh/custom/plugins/zsh-completions
popd
