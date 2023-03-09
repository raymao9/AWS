#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

function logo(){
echo "


                                             ,;r7i;;7rSXi
                                           :X;         :XZr
                                          r2.ir  aari     28
                                         ,Z  ZX .2ZBr      ;W
                                         2.  i              8X,i
                                     .XSMM   , S0r.         ;W .MB
                                     ;XMMa.   BB8Wi         aMS2Mr
                                      WM  2.  :7XZ.      ;WMM   Z
                                     S2 2; i,  .i       MMW2   X2
                                    :M   SX:           M0 ,   ,@
                                    07     aX         MX     ;W
            Xiia2r                  Bi     ar        MS    .X0
            B@80MM                  X8     B.       ZM     a2     .....
             @ZaWMWZZZZaX7;:         M,    W        Mi     ;7 ,Xa8@WWWWWWZrXr:
    XB88Z2aa0882iraSSS22ZZ880Zar,    ,M   iZ       MW       M8WW080aZaZZ88Z2MMMW0S;
    @M   7ZZaXrX;i;XXXXSXSXXX2a0BB2.  SB  7S     2MZ        M@aZaaZ8XS7r.   .rXZ0W@WZX
    a8 iZZX:    ,,:7Z2X7XXSXSS2SriZW8i @  rr  .702          BZ0aaa288Sa2ZaZZB8080800W@0X
    ,Z.:         r7rSZ8Z22XXSXr7XXiXZ0Z0@ ,Z:XaX. ., :      MiS0aaaa80aZZZZZB008Z880BSX08
     M@ZX         Z2XXa8WSXXirX:.2Zr2XXXMM@M@X7ZX:777W2     WZX202SSSZ8aZ2aS08ZZ88802;0SZW
      MM2          Z2Srr7SZBXZaX,;S772S;8MXBW2.r8. .  BZ      ;a8ZaSX;rX7SX7Sa2ZZ8Z8r720rZ0
      ,M;           ,rXX7SZZ,i8Zi,;;:Xr:MarBBZ:,Z2  .  287:     rZSZSrri:;rirSaZZaWXr77aaX0@
       M:              .;SX,   r;,X7 ;,WM:XB8Wi:;@i  . ..;XW0i   2a2::iii,;;7Z2ZZ08ZS7a882Z80
       Zr                .X8Z2X7X;,aX:B@::a08W2.i;BS. .     M807 SXX7;i.; i:72aSZBSS@MaXZZ77WS
       XM                   i80Sr,SMMMZ;r;0B2ZZi::,MWX  .iXr08S8BX,aSXXXr:r8770Z;8aa7BMS;aZSXM;
        8                     .8a70i a002SMWWWMB7X88XWZ8880S:X2aaZ88MZa@@0W8ZiS0Z;2i7.70Za0a8;2
                           ,XZiai   .SWS  iWMa..SWBWXXWXZZZZaX2XXXX2r   ..     .:.;7 .  :2Zii:
                         .ZZ;      S@a,   2ZX   X8;.82@: iX2000                    ..      : ;,
                         ;.    iSBa;     :i    ,ar    ;8                             ;..    X2,
                                                                        
							by:ppxwo.com"

}


function setconfig(){
if [[ -f /etc/awsip.conf ]]; then
	ipname=`grep "ipname" /etc/awsip.conf | grep -oP '(?<==).*'`
	instancename=`grep "instancename" /etc/awsip.conf | grep -oP '(?<==).*'`
else
	echo && stty erase '^H' && read -p "需要创建的 IP 名: " ipname
	echo && stty erase '^H' && read -p "需要创建的实例名: " instancename
	echo -e "ipname=${ipname}\ninstancename=${instancename}" > /etc/awsip.conf
fi
}

function ddns(){
echo  "等待 5 秒生效"
sleep 5
/root/AliDDNS-v2.0.sh run >/dev/null 2>&1 &
}

function changeip(){
echo "删除现有 IP。"
aws lightsail release-static-ip --static-ip-name ${ipname} >/dev/null 2>&1
echo "创建新 IP"
aws lightsail allocate-static-ip --static-ip-name ${ipname} >/dev/null 2>&1
echo "绑定 IP"
aws lightsail attach-static-ip --static-ip-name ${ipname} --instance-name ${instancename} >/dev/null 2>&1
echo "更新 DDNS"
sleep 1
ddns
}
logo
setconfig
changeip
