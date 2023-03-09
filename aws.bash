#!/usr/bin/env bash

#By：皮皮虾 https://ppx.ink
#Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
if [[ ! -d /tmp/aws/ ]]; then
mkdir /tmp/aws/
fi
function confregion(){
echo -e "初始化-配置访问密钥:
1)日本
2)韩国
3)新加坡
4)德国
5)英国
6)爱尔兰
7)印度
8)悉尼
9)美东1
10)美东2
11)美西2
"
echo && stty erase '^H' && read -p "选择你要操作的区域[1-10]: " num
case "$num" in
	1)
	region="ap-northeast-1"
	;;
    2)
    region="ap-northeast-2"
    ;;
	3)
	region="ap-southeast-1"
	;;
	4)
	region="eu-central-1"
	;;
	5)
	region="eu-west-2"
	;;
	6)
	region="eu-west-1"
	;;
	7)
	region="ap-south-1"
	;;
	8)
	region="ap-southeast-2"
	;;
	9)
	region="us-east-1"
	;;
	10)
	region="us-east-2"
	;;
	11)
	region="us-west-2"
	;;
	*)
	echo -e "${Red_font_prefix} please enter the right number [1-10]${Font_color_suffix}"
	;;
esac
configure
}

function listZone(){
echo "
美国：
us-east-1a -- us-east-1f 弗吉尼亚
us-east-2a -- us-east-2c 俄亥俄州
us-west-2a -- us-east-2c 俄勒冈州
欧洲：
eu-west-1a -- eu-west-1c 爱尔兰
eu-west-2a -- eu-west-2b 伦敦
eu-central-1a -- eu-central-1c 德国
亚洲：
ap-northeast-1a ap-northeast-1c 日本
ap-northeast-2a ap-northeast-2b 韩国
ap-southeast-1a ap-southeast-1b 新加坡
ap-southeast-2a -- ap-southeast-2c 悉尼
ap-south-1a ap-south-1b 印度
"
backfirst
}

function configure(){
if [[ -f /etc/aws.conf ]]; then
	echo -e "${Green_font_prefix} 你已经登录过 aws，密钥存放于/etc/aws.conf ${Font_color_suffix}"
	AccessKeyId=`grep "AK" /etc/aws.conf | grep -oP '(?<==).*'`
	SecretKey=`grep "SK" /etc/aws.conf | grep -oP '(?<==).*'`
else
	echo && stty erase '^H' && read -p "输入你的 AccessKeyId: " AccessKeyId
	echo && stty erase '^H' && read -p "输入你的 SecretKey: " SecretKey
	echo -e "AK=${AccessKeyId}\nSK=${SecretKey}" > /etc/aws.conf
fi

aws configure <<EOF
${AccessKeyId}
${SecretKey}
${region}

EOF

echo '1' > /etc/aws.lock
backfirst
}

function getvps(){
# Names=`aws lightsail get-instances | sed -n '/"name"/,/\>/p' | grep "name" |sed -n 'p;n'`
# Ips=`aws lightsail get-instances | grep "publicIpAddress"`
echo "`aws lightsail get-instances | sed -n '/"name"/,/\>/p' | grep "name" |sed -n 'p;n'`" > /tmp/aws/1.logs
echo "`aws lightsail get-instances | grep "publicIpAddress"`" >/tmp/aws/2.logs
paste -d" " /tmp/aws/1.logs /tmp/aws/2.logs > /tmp/aws/3.logs
echo -e "\n"
echo -e "${Red_background_prefix}"
echo -e "实例列表："
cat /tmp/aws/3.logs
echo -e "${Font_color_suffix}"
echo -e "\n"
rm -rf /tmp/aws/*
}

function getinstance(){
getvps
backfirst
}

function iipp(){
A=`aws lightsail get-static-ips | grep name`
B=`aws lightsail get-static-ips | grep ipAddress |grep -o -P "(\d+\.)(\d+\.)(\d+\.)\d+"`
echo "$A" | tr -d " " > /tmp/aws/I.logs
echo "$B" | tr -d " ">/tmp/aws/P.logs
paste -d" " /tmp/aws/I.logs /tmp/aws/P.logs > /tmp/aws/IP.logs
echo -e "\n"
echo -e "${Red_background_prefix}"
echo -e "IP 列表："
cat /tmp/aws/IP.logs
echo -e "${Font_color_suffix}"
echo -e "\n"
rm -rf /tmp/aws/*
}

function getip(){
iipp
backfirst
}

function creatip(){
echo && stty erase '^H' && read -p "需要创建的 IP 名: " ipname
aws lightsail allocate-static-ip --static-ip-name ${ipname}
backfirst 
}

function attachip(){
getvps
iipp
echo && stty erase '^H' && read -p "需要解绑的 IP 名: " ipname
echo && stty erase '^H' && read -p "需要解绑的实例名: " instancename
aws lightsail attach-static-ip --static-ip-name ${ipname} --instance-name ${instancename}
backfirst
}

function delip(){
iipp
echo && stty erase '^H' && read -p "需要删除的 IP 名: " ipname
aws lightsail release-static-ip --static-ip-name ${ipname}
backfirst
}

function setip(){
iipp
getvps
echo && stty erase '^H' && read -p "需要绑定的 IP 名: " ipname
echo && stty erase '^H' && read -p "需要绑定的实例名: " instancename
aws lightsail  attach-static-ip --static-ip-name ${ipname} --instance-name ${instancename}
backfirst
}

function openport(){
getvps
echo && stty erase '^H' && read -p "需要开放的起始端口（默认 0）: " startport
echo && stty erase '^H' && read -p "需要开放的终止端口（默认 65535）: " stopport
echo && stty erase '^H' && read -p "需要开放的端口类型（tcp/udp/all，默认 all）: " protocol
echo && stty erase '^H' && read -p "需要修改的实例名: " instancename
[[ -z ${startport} ]] && startport="0"
[[ -z ${stopport} ]] && stopport="65535"
[[ -z ${protocol} ]] && protocol="all"

Pinfo="fromPort=${startport},toPort=${stopport},protocol=${protocol}"
aws lightsail  open-instance-public-ports --port-info ${Pinfo} --instance-name ${instancename}
backfirst
}

function rebooti(){
getvps
echo && stty erase '^H' && read -p "需要重启的实例名: " instancename
aws lightsail reboot-instance --instance-name ${instancename}
backfirst
}

function starti(){
getvps
echo && stty erase '^H' && read -p "需要启动的实例名: " instancename
aws lightsail reboot-instance --start-name ${instancename}
backfirst
}

function stopi(){
getvps
echo && stty erase '^H' && read -p "需要关闭的实例名: " instancename
aws lightsail reboot-instance --stop-name ${instancename}
backfirst
}

function getos(){
Names=`aws lightsail get-blueprints | grep "name" `
Oss=`aws lightsail get-blueprints | grep "blueprintId"`
echo "$Names" > /tmp/aws/4.logs
echo "$Oss" >/tmp/aws/5.logs
paste -d" " /tmp/aws/4.logs /tmp/aws/5.logs > /tmp/aws/6.logs
echo -e "\n"
echo -e "${Red_background_prefix}"
cat /tmp/aws/6.logs
echo -e "${Font_color_suffix}"
echo -e "\n"
rm -rf /tmp/aws/*
backfirst
}

function price(){
pricex=`aws lightsail get-bundles --no-include-inactive | grep "price"`
ram=`aws lightsail get-bundles --no-include-inactive | grep "ramSizeInGb"`
disk=`aws lightsail get-bundles --no-include-inactive | grep "diskSizeInGb"`
transfer=`aws lightsail get-bundles --no-include-inactive | grep "transferPerMonthInGb"`
cpucount=`aws lightsail get-bundles --no-include-inactive | grep "cpuCount"`
PId=`aws lightsail get-bundles --no-include-inactive | grep "bundleId"`
echo "$pricex" | tr -d " " > /tmp/aws/7.logs
echo "$ram" | tr -d " ">/tmp/aws/8.logs
echo "$disk" | tr -d " ">/tmp/aws/9.logs
echo "$transfer"| tr -d " " >/tmp/aws/10.logs
echo "$cpucount" | tr -d " ">/tmp/aws/11.logs
echo "$PId" | tr -d " ">/tmp/aws/12.logs
paste -d" " /tmp/aws/7.logs /tmp/aws/8.logs /tmp/aws/9.logs /tmp/aws/10.logs /tmp/aws/11.logs /tmp/aws/12.logs > /tmp/aws/13.logs
echo -e "\n"
echo -e "${Red_background_prefix}"
cat /tmp/aws/13.logs
echo -e "${Font_color_suffix}"
echo -e "\n"
rm -rf /tmp/aws/*
backfirst
}

function setzone(){
echo -e "${Green_background_prefix}
1)日本
2)韩国
3)新加坡
4)德国
5)英国
6)爱尔兰
7)印度
8)悉尼
9)美东1
10)美东2
11)美西2${Font_color_suffix}
"
echo && stty erase '^H' && read -p "需要创建的实例地区（确定你有配额创建）: " zonen
case "$zonen" in
	1)
	zone="ap-northeast-1a"
	;;
    2)
    zone="ap-northeast-2a"
    ;;
	3)
	zone="ap-southeast-1a"
	;;
	4)
	zone="eu-central-1a"
	;;
	5)
	zone="eu-west-2a"
	;;
	6)
	zone="eu-west-1a"
	;;
	7)
	zone="ap-south-1a"
	;;
	8)
	zone="ap-southeast-2a"
	;;
	9)
	zone="us-east-1a"
	;;
	10)
	zone="us-east-2a"
	;;
	11)
	zone="us-west-2a"
	;;
	*)
	echo -e "${Red_font_prefix} please enter the right number [1-11]${Font_color_suffix}"
	;;
esac
}

function setos(){
echo -e "${Green_background_prefix}
1)Amazon Linux
2)Ubuntu16.04LTS
3)Debian8.7
4)FreeBSD11.1
5)openSUSE42.2
6)Windows Server 2012 R2
7)Windows Server 2016
8)SQL Server 2016 Express${Font_color_suffix}
"
echo && stty erase '^H' && read -p "需要创建的系统 [1-8]: " OsIdn
case "$OsIdn" in
	1)
	OsId="amazon_linux_2017_03_1_2"
	;;
	2)
	OsId="ubuntu_16_04_1"
	;;
	3)
	OsId="debian_8_7"
	;;
	4)
	OsId="freebsd_11_1"
	;;
	5)
	OsId="opensuse_42_2"
	;;
	6)
	OsId="windows_server_2012_2017_09_13"
	;;
	7)
	OsId="windows_server_2016_2017_09_13"
	;;
	8)
	OsId="windows_server_2016_sql_2016_express_2017_09_13"
	;;
	*)
	echo -e "${Red_font_prefix} please enter the right number [1-8]${Font_color_suffix}"
	;;
esac
}

function setsize(){
echo -e "${Green_background_prefix}
(以下是 Linux 套餐 不可安装 Windows)
1)1H 512M 20G 1T 5 美元/月
2)1H 1024M 30G 2T 10 美元/月
3)1H 2048M 40G 3T 20 美元/月
4)2H 4096M 60G 4T 40 美元/月
5)2H 8192M 80G 5T 80 美元/月
(以下是 Windows 套餐 不可安装 Linux)
6)1H 512M 30G 1T 10 美元/月
7)1H 1024M 40G 2T 17 美元/月
8)1H 2048M 50G 3T 30 美元/月
9)2H 4096M 60G 4T 55 美元/月
10)2H 8192M 80G 5T 100 美元/月${Font_color_suffix}
"
echo && stty erase '^H' && read -p "需要创建的套餐（确定你有配额创建）: " sizen
case "$sizen" in
	1)
	size="nano_1_0"
	;;
	2)
	size="micro_1_0"
	;;
	3)
	size="small_1_0"
	;;
	4)
	size="medium_1_0"
	;;
	5)
	size="large_1_0"
	;;
	6)
	size="nano_win_1_0"
	;;
	7)
	size="micro_win_1_0"
	;;
	8)
	size="small_win_1_0"
	;;
	9)
	size="medium_win_1_0"
	;;
	10)
	size="large_win_1_0"
	;;
	*)
	echo -e "${Red_font_prefix} please enter the right number [1-10]${Font_color_suffix}"
	;;
esac
}

function creatinstance(){
echo && stty erase '^H' && read -p "需要创建的实例名: " instancename
setzone
setos
setsize
echo && stty erase '^H' && read -p "默认 root 密码: " rootpasswd
aws lightsail create-instances --instance-name ${instancename} --availability-zone ${zone} --blueprint-id ${OsId} --bundle-id ${size} --user-data "echo root:${rootpasswd} |sudo chpasswd root;sudo sed -i 's/^.*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;sudo sed -i 's/^.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;sudo service sshd restart"
echo && stty erase '^H' && read -p "是否开启全部端口（默认 y）[y/n]: " oport
[[ -z ${oport} ]] && oport="y"
if [[ ${oport} = "y" ]];then
Pinfo="fromPort=0,toPort=65535,protocol=all"
sleep 8
echo "等待实例创建完毕"
sleep 10
aws lightsail  open-instance-public-ports --port-info ${Pinfo} --instance-name ${instancename}
fi
getvps
backfirst
}


function delinstance(){
getvps
echo && stty erase '^H' && read -p "需要删除的实例名: " instancename
aws lightsail delete-instance --instance-name ${instancename}
backfirst
}

function backfirst(){
echo && stty erase '^H' && read -p "输入任意值返回主页: "
first
}



function first(){

if [[ ! -f /etc/aws.lock ]]; then
confregion
fi


echo -e " AWS lightsail 管理 ${Red_font_prefix}[v2.0]${Font_color_suffix}
  --- 欢迎使用 ----
  ${Green_font_prefix}1.${Font_color_suffix} 重新设置管理区域并初始化
  ${Green_font_prefix}2.${Font_color_suffix} 获取现有实例
  ${Green_font_prefix}3.${Font_color_suffix} 查看可用系统
  ${Green_font_prefix}4.${Font_color_suffix} 查看可用配置
  ${Green_font_prefix}5.${Font_color_suffix} 获取静态 IP
  ${Green_font_prefix}6.${Font_color_suffix} 释放静态 IP
  ${Green_font_prefix}7.${Font_color_suffix} 删除静态 IP
  ${Green_font_prefix}8.${Font_color_suffix} 绑定 IP
  ${Green_font_prefix}9.${Font_color_suffix} 开放端口
  ${Green_font_prefix}10.${Font_color_suffix} 创建实例
  ${Green_font_prefix}11.${Font_color_suffix} 重启实例
  ${Green_font_prefix}12.${Font_color_suffix} 启动实例
  ${Green_font_prefix}13.${Font_color_suffix} 停止实例
  ${Green_font_prefix}14.${Font_color_suffix} 删除实例
  ${Green_font_prefix}15.${Font_color_suffix} 列出所有 Zone
  ${Green_font_prefix}16.${Font_color_suffix} 退出
  "
echo && stty erase '^H' && read -p "请输入操作 [1-16]: " num
case "$num" in
	1)
	confregion
	;;
	2)
	getinstance
	;;
	3)
	getos
	;;
	4)
	price
	;;
	5)
	creatip
	;;
	6)
	attachip
	;;
	7)
	delip
	;;
	8)
	setip
	;;
	9)
	openport
	;;
	10)
	creatinstance
	;;
	11)
	rebooti
	;;
	12)
	starti
	;;
	13)
	stopi
	;;
	14)
	delinstance
	;;
	15)
	listZone
	;;
	16)
	exit
	;;
	*)
	echo -e "${Error} please enter the right number [1-16]"
	first
	;;
esac
}
first
