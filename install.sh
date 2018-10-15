#!/bin/bash
 
#************************************************#
#         System Initialization Script           #
#            written by Xing Fei                 #
#                March 22, 2013                  #
#                                                #
#        Initialize System Configurations        #
#************************************************#
 
export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin";
 
black='\E[30;40m'
red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
blue='\E[34;47m'
magenta='\E[35;40m'
cyan='\E[36;40m'
white='\E[37;40m'
 
alias Reset="tput sgr0"      #  Reset text attributes to normal
                             #+ without clearing screen.
 
# ------------------------------------------------------- #
#                                                         #
#    Check network IP address and DNS settings before.    #
#                                                         #
# ------------------------------------------------------- #
 
#echo -e "$yellow"
#echo -n 'Before we begin to deploy, you must make sure the network connection is completely functional including our internal network. ';
#echo 'Are you sure about these?';
#echo 'Please input "Yes" to continue, others to exit.';
#read INPUT;
 
#if [ "${INPUT}" != 'Yes' ]; then
#        echo -e "$green"
#        echo 'Quit.'
#        exit 0;
#fi
 
#echo;
 
 
# ------------------------------------------------------- #
#                                                         #
#     Follow this steps to deploy MTA proxy services:     #
#     1.  Check locale language charset.                  #
#     2.  Use NTP service to set time.                    #
#     3.  Disable SELinux feature.                        #
#     4.  Disable iptables.                               #
#     5.  Install software.                               #
#     6.  Shut down system unnecessary services           #
#     7.  Create initial directory.                       #
#     8.  Initialize dajie-inc.com Winbind configuration. #
#     9.  Create initial /etc/rc.local.                   #
#    10.  Some of the necessary parameter setting         #
# ------------------------------------------------------- #
 
# Step 1.--------------------------------------------设定系统字符集为en_US.UTF-8
# Check locale language charset.
LANG_CHARSET=`/bin/fgrep 'LANG=' /etc/sysconfig/i18n | /bin/awk -F'"' '{print $2}'`;
if [ "${LANG_CHARSET}" != 'en_US.UTF-8' ]; then
        /bin/sed -ri '/^LANG=\".*\"/ s//LANG="en_US.UTF-8"/' /etc/sysconfig/i18n;
fi;
 
# Step 2.-------------设定时间同步
# Use NTP service to set time.
echo "1 * * * * /usr/bin/rdate -s  rdate.darkorb.net  && /usr/sbin/hwclock -w" >> /var/spool/cron/root;
/sbin/hwclock -w;
 
# Step 3.------关闭SElinux
# Disable SELinux feature.
if /usr/sbin/sestatus | /bin/fgrep 'enable'; then
        /usr/sbin/setenforce 0;
        /bin/sed -ri '/^SELINUX=\w+$/ s//SELINUX=disabled/' /etc/selinux/config;
fi;
 
# Step 4.----------关闭防火墙以及Postfix
# Disable iptables.
 
# Step 5.-----------升级最新补丁以及基本包安装以及替换过的bash以及Epel安装以及安装zabbix anentd
# Install software.
/usr/bin/yum -y update && /usr/bin/yum install git wireshark cmake compat-libstdc++-33 libjpeg libpng libpng-devel freetype freetype-devel gcc gcc-c++ gdb apr apr-devel apr-util-devel apr-util db4 db4-devel expat expat-devel boost boost-devel libevent libevent-devel openssl openssl-devel bzip2 bzip2-devel flex byacc  readline readline-devel pcre pcre-devel python python-devel vim wget curl libcurl-devel m4 bison emacs libxml2 libxml2-devel  libstdc++ libstdc++-devel ncurses ncurses-devel lrzsz openssh-clients lzo make sysstat rdate rsync lzma dmidecode pciutils ftp telnet libtool glib2-devel libtool-ltdl libtool-ltdl-devel uuid file uuid-devel e2fsprogs-devel libuuid-devel libxslt-devel man subversion subversion-devel zip unzip patch lzo-devel lsof man-pages fprintd-pam screen nc python-crypto m2crypto crypto-utils lynx enca libjpeg-devel expect scons zip unzip strace mailx lsof tcpdump nmap tmux mtr ntpdate net-snmp net-snmp-devel gd-devel jpeg-devel ntsysv setuptool netconfig psacct bind-utils iotop tmpwatch libaio perl-DBD-MySQL perl-DBI perl-devel -y
 

 
# Step 6.----------关闭不必要的服务
# Shut down system unnecessary services
for p in $(chkconfig --list |awk '$1!~/crond|network|syslog|sshd|sysstat|psacct/ && $5~/on/ {print $1}')
do
chkconfig $p off
done

# Step 7.----------创建环境目录
mkdir -p /ROOT/backups /ROOT/data /ROOT/install /ROOT/jobs /ROOT/logs /ROOT/scripts /ROOT/server /ROOT/tmps /ROOT/www 

# Step 8------内核参数以及系统最大文件数以及用户进程数调优
#Some of the necessary parameter setting 
touch /data/scripts/start_service_after_system_boot.sh
echo 'net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_max_tw_buckets = 40000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 262144
net.core.optmem_max = 81920
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_rmem = 4096 87380 8388608
net.ipv4.tcp_wmem = 4096 87380 8388608
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_fin_timeout = 30
vm.swappiness = 0
net.ipv4.ip_local_port_range = 1024    65535' >> /etc/sysctl.conf
sysctl -p
sed -i '/# End of file/ i\*       soft    nofile          65535' /etc/security/limits.conf
sed -i '/# End of file/ i\*       hard    nofile          65535' /etc/security/limits.conf
sed -i 's/tty\[1-6\]/tty\[1-2\]/g' /etc/sysconfig/init
sed -i 's/*          soft    nproc     1024/*          soft    nproc     65535/g' /etc/security/limits.d/90-nproc.conf


# ------------------------------------------------------- #
#                                                         #
#    Print other steps we should do to make this Linux    #
#    system completely ready.                             #
#                                                         #
# ------------------------------------------------------- #
 
echo
echo -e "$cyan"
echo 'After this, you still have several things to do. Luckly we have a list here, you can follow these steps one by one.'
echo -e "\t"'1. Change root password if you did not.'
echo -e "\t"'2. Add user webmaster and set its password.'
echo -e "\t"'3. Check hosts file and set right hostname of this server.'
echo -e "\t"'4. Join dajie-inc.com domain using the NET command.'
echo -e "\t"'5. Restart this server and make all services running good.'

echo
echo -e "$magenta"
echo 'Have a nice day! ^_^'
 
 
exit 0;

