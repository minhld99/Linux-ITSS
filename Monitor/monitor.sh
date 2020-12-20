#! /bin/bash
# unset any variable which system may be using

unset main os architecture kernelrelease internalip externalip nameserver loadaverage
# clear the screen
# clear

while getopts ivhd name
do
        case $name in
          i)iopt=1;; # install
          v)vopt=1;; # version
          h)hopt=1;; # help
          d)dopt=1;; # view calendar
          *)echo "Invalid arg";;
        esac
done

if [[ ! -z $iopt ]]
then
{
wd=$(pwd)
basename "$(test -L "$0" && readlink "$0" || echo "$0")" > /tmp/scriptname
scriptname=$(echo -e -n $wd/ && cat /tmp/scriptname)
su -c "cp $scriptname /usr/bin/monitor" root && echo "Congratulations! Script Installed" || echo "Installation failed"
}
fi

if [[ ! -z $vopt ]]
then
{
echo -e "Monitor v1 | Linux ITSS Project | Minh & Ha"
}
fi

if [[ ! -z $hopt ]]
then
{
echo -e "
$(basename "$0") [-h] [-v] [-i]
A simple program that displays the basic parameters of the system

Usage:
    -h  show this help text
    -i  install this script & run from anywhere in your system
    -v  show this script's version & author details
"
}
fi

if [[ ! -z $dopt ]]
then
{
date=$(zenity --calendar)
echo $date
}
fi

if [[ $# -eq 0 ]]
then
{

function work-list () {

adddate() {
while IFS= read -r line; do
printf '%s\n\n[%s]
=========================\n\n' "$line" "$(date)";
done
}

# Define Variable main
main=$(tput sgr0)

# Check if connected to Internet or not
ping -c 1 google.com &> /dev/null && echo -e '\E[32m'"Internet: $main Connected" || echo -e '\E[32m'"Internet: $main Disconnected"

# Check OS Type
os=$(uname -o)
echo -e '\E[32m'"Operating System Type :" $main $os

# Check OS Release Version and Name
cat /etc/os-release | grep 'NAME\|VERSION' | grep -v 'VERSION_ID' | grep -v 'PRETTY_NAME' > /tmp/osrelease
echo -n -e '\E[32m'"OS Name :" $main  && cat /tmp/osrelease | grep -v "VERSION" | cut -f2 -d\"
echo -n -e '\E[32m'"OS Version :" $main && cat /tmp/osrelease | grep -v "NAME" | cut -f2 -d\"

# Check Architecture
architecture=$(uname -m)
echo -e '\E[32m'"Architecture :" $main $architecture

# Check Kernel Release
kernelrelease=$(uname -r)
echo -e '\E[32m'"Kernel Release :" $main $kernelrelease

# Check hostname
echo -e '\E[32m'"Hostname :" $main $HOSTNAME

# Check Internal IP
internalip=$(hostname -I)
echo -e '\E[32m'"Internal IP :" $main $internalip

# Check External IP
externalip=$(curl -s ipecho.net/plain;echo)
echo -e '\E[32m'"External IP : $main "$externalip

# Check DNS
nameservers=$(cat /etc/resolv.conf | sed '1 d' | awk '{print $2}')
echo -e '\E[32m'"Name Servers :" $main $nameservers 

# Check Logged In Users
who>/tmp/who
echo -e '\E[32m'"Logged In users :" $main && cat /tmp/who 

# Check RAM and SWAP Usages
free -h | grep -v + > /tmp/ramcache
echo -e '\E[32m'"Ram Usages :" $main | tee -a "usages_log.txt"
cat /tmp/ramcache | grep -v "Swap"
echo -e '\E[32m'"Swap Usages :" $main | tee -a "usages_log.txt"
cat /tmp/ramcache | grep -v "Mem"

# Check Disk Usages
df -h| grep 'Filesystem\|/dev/sda*' > /tmp/diskusage
echo -e '\E[32m'"Disk Usages :" $main | adddate >> usages_log.txt
cat /tmp/diskusage

# Check Load Average
loadaverage=$(top -n 1 -b | grep "load average:" | awk '{print $10 $11 $12}')
echo -e '\E[32m'"Load Average :" $main $loadaverage

# Check System Uptime
tecuptime=$(uptime | awk '{print $3,$4}' | cut -f1 -d,)
echo -e '\E[32m'"System Uptime Days/(HH:MM) :" $main $tecuptime

# Unset Variables
unset main os architecture kernelrelease internalip externalip nameserver loadaverage

# Remove Temporary Files
rm /tmp/osrelease /tmp/who /tmp/ramcache /tmp/diskusage

}
work-list | zenity --progress --title "Running..." --auto-close

}
fi
shift $(($OPTIND -1))
