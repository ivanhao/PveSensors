#!/bin/bash

js='/usr/share/pve-manager/js/pvemanagerlib.js'
pm='/usr/share/perl5/PVE/API2/Nodes.pm'
sh='/usr/bin/s.sh'

OS=`/usr/bin/pveversion|awk -F'-' 'NR==1{print $1}'`
ver=`/usr/bin/pveversion|awk -F'/' 'NR==1{print $2}'|awk -F'-' '{print $1}'`
pve=$OS$ver
if [ "$OS" != "pve" ];then
    echo "您的系统不是Proxmox VE, 无法安装，马上退出!"
    echo "Your OS is not Proxmox VE.Now quit!"
    exit
fi
if [[ ! -f "$js" || ! -f "$pm" ]];then
    echo "您的Proxmox VE版本不支持此方式，马上退出！"
    echo "Your Proxmox VE's version is not supported,Now quit!"
    exit
fi
if [[ -f "$js.backup" && -f "$sh" ]];then
    echo "您已经安装过本软件，请不要重复安装！"
    echo "You already installed,Now quit!"
    exit
fi
if [ ! -f "/usr/bin/sensors" ];then
    echo "您还没有安装lm-sensors,请先sudo apt-get install lm-sensors然后运行sensors-detect初始化后再来安装本程序！马上退出！"
    echo "you have not installed lm-sensors, please run 'sudo apt-get install lm-sensors' and then 'sensors-detect' to initial sensors first.Now quit! "
    exit
fi
while [ true ]               
  do
     echo "您的系统是：$pve, 您将安装sensors界面, 是否继续?(y/n)"
     echo -n "Your OS：$pve, you will install sensors interface, continue?(y/n)"
     read x
     case "$x" in
       y | yes ) 
	cp $js $js.backup
	cp $pm $pm.backup
	cp ./s.sh /usr/bin/s.sh
	chmod +x /usr/bin/s.sh
	#--create the configs--
	d=`sensors|grep '^[a-zA-Z0-9].[[:print:]]*:.\s*\S*[0-9].\s*[A-Z].' -o|sed 's/:\ */:/g'|sed 's/\ C\ /C/g'|sed 's/\ V\ /V/g'|sed 's/\ RP/RPM/g'|sed 's/\ //g'|awk -F ":" '{print $1}'`
	rm ./p1
cat << EOF >> ./p1
        ,{
            xtype: 'box',
            colspan: 2,
	    title: gettext('Sensors Data:'),
            padding: '0 0 20 0'
        }
	,{
	    itemId: 'Sensors',
	    colspan: 2,
	    printBar: false,
	    title: gettext('Sensors Data:')
	}
EOF
	for i in $d
	do
cat << EOF >> ./p1
	,{
	    itemId: '$i',
	    colspan: 1,
	    printBar: false,
	    title: gettext('$i'),
	    textField: 'tdata',
	    renderer:function(value){
		var d = JSON.parse(value);
		var s = "";
		s = d['$i'];
		return s;
	    }
	}
EOF
	done
	#--configs end--
	h=`sensors|awk 'END{print NR}'`
	let h=$h*9+300
	n=`sed '/widget.pveNodeStatus/,/height/=' $js -n|sed -n '$p'`
	sed -i ''$n'c \ \ \ \ height:\ '$h',' $js 
	n=`sed '/pveversion/,/\}/=' $js -n|sed -n '$p'`
	sed -i ''$n' r ./p1' $js
	n=`sed '/pveversion/,/version_text/=' $pm -n|sed -n '$p'`
	sed -i ''$n' r ./p2' $pm
	systemctl restart pveproxy

	echo "如果没有意外，安装完成! 浏览器打开界面刷新看一下概要界面!"
        echo "Installation Complete! Go to websites and refresh to enjoy!"
        exit
        ;;

       n | no )
        exit
        ;;
      
       * )
        echo "Please input y/n to comfirm!"
     esac
done
