#!/bin/bash

js='/usr/share/pve-manager/js/pvemanagerlib.js'
pm='/usr/share/perl5/PVE/API2/Nodes.pm'
sh='/usr/bin/s.sh'

OS=`/usr/bin/pveversion|awk -F'-' 'NR==1{print $1}'`
ver=`/usr/bin/pveversion|awk -F'/' 'NR==1{print $2}'|awk -F'-' '{print $1}'`
pve=$OS$ver
if [ "$OS" != "pve" ];then
    echo "您的系统不是Proxmox VE,马上退出!"
    echo "Your OS is not Proxmox VE.Now quit!"
    exit
fi
if [[ ! -f "$js" || ! -f "$pm" ]];then
    echo "您的Proxmox VE版本不支持此方式，马上退出！"
    echo "Your Proxmox VE's version is not supported,Now quit!"
    exit
fi
if [[ ! -f "$js.backup" && ! -f "$sh" ]];then
    echo "您未安装过本软件，马上退出！"
    echo "You are not installed,Now quit!"
    exit
fi
while [ true ]               
  do
     echo "您的系统是：$pve, 您将卸载sensors界面, 是否继续?(y/n)"
     echo -n "Your OS：$pve, you will uninstall sensors interface, continue?(y/n)"
     read x
     case "$x" in
       y | yes ) 
	mv $js.backup $js
	mv $pm.backup $pm
	rm /usr/bin/s.sh
	systemctl restart pveproxy

	echo "卸载完成! 浏览器打开界面刷新看一下概要界面!"
        echo "Uninstallation Complete! Go to websites and refresh!"
        exit
        ;;

       n | no )
        exit
        ;;
      
       * )
        echo "Please input y/n to comfirm!"
     esac
done
