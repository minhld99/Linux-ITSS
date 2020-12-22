#! /bin/bash
# unset any variable which system may be using

unset normal os architecture kernelrelease internalip externalip nameserver loadaverage
# clear the screen
# clear

while getopts ivhde name
do
        case $name in
          i)iopt=1;; # install
          v)vopt=1;; # version
          h)hopt=1;; # help
          d)dopt=1;; # view calendar
          e)eopt=1;; # execute every 1 hour
          *)echo "Invalid arg";;
        esac
done

if [[ ! -z $iopt ]]
then
{
wd=$(pwd)
basename "$(test -L "$0" && readlink "$0" || echo "$0")" > /tmp/scriptname
scriptname=$(echo -e -n $wd/ && cat /tmp/scriptname)
echo "Note: Use your root account password!!"
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

if [[ ! -z $eopt ]]
then
{
wd=$(pwd)
basename "$(test -L "$0" && readlink "$0" || echo "$0")" > /tmp/scriptname
scriptname=$(echo -e -n $wd/ && cat /tmp/scriptname)
sudo mv $scriptname /etc/cron.hourly/monitor && 
echo "Success! This script will be executed every 1 hour." || echo "Error!"
}
fi

if [[ $# -eq 0 ]]
then
{

function work-list () {
sleep 1;
} 
work-list | zenity --progress --title "Running..." --auto-close

adddate() {
while IFS= read -r line; do
printf '\n%s' "$line";
done
printf '\n\n['"$(date)"']\n=========================\n\n';
}

# Define Variables
normal=$(tput sgr0)
green=$(tput setaf 2) 	# = '\E[32m'

# Check if connected to Internet or not
ping -c 1 google.com &> /dev/null && echo -e $green"Internet: $normal Connected" || echo -e $green"Internet: $normal Disconnected"

# Check OS Type
os=$(uname -o)
echo -e $green"Operating System Type :" $normal $os

# Check OS Release Version and Name
cat /etc/os-release | grep 'NAME="\|VERSION="' | grep -v 'VERSION_ID' | grep -v 'PRETTY_NAME' > /tmp/osrelease
echo -n -e $green"OS Name :" $normal  && cat /tmp/osrelease | grep -v "VERSION" | cut -f2 -d\"
echo -n -e $green"OS Version :" $normal && cat /tmp/osrelease | grep -v "NAME" | cut -f2 -d\"

# Check Architecture
architecture=$(uname -m)
echo -e $green"Architecture :" $normal $architecture

# Check Kernel Release
kernelrelease=$(uname -r)
echo -e $green"Kernel Release :" $normal $kernelrelease

# Check hostname
echo -e $green"Hostname :" $normal $HOSTNAME

# Check Internal IP
internalip=$(hostname -I)
echo -e $green"Internal IP :" $normal $internalip

# Check External IP
externalip=$(curl -s ipecho.net/plain;echo)
echo -e $green"External IP : $normal "$externalip

# Check DNS
nameservers=$(cat /etc/resolv.conf | grep -i '^nameserver' | head -n1 | cut -d ' ' -f2)
echo -e $green"Name Servers :" $normal $nameservers 

# Check Logged In Users
who>/tmp/who
echo -e $green"Logged In users :" $normal && cat /tmp/who 

# Check RAM and SWAP Usages
free -h | grep -v + > /tmp/ramcache
echo -e $green"Ram Usages :" $normal
cat /tmp/ramcache | grep -v "Swap" | tee -a "usages_log.txt"
echo -e $green"Swap Usages :" $normal
cat /tmp/ramcache | grep -v "Mem" | tee -a "usages_log.txt"

# Check Disk Usages
df -h| grep 'Filesystem\|/dev/sda*' > /tmp/diskusage
echo -e $green"Disk Usages :" $normal
cat /tmp/diskusage
cat /tmp/diskusage | adddate >> usages_log.txt

# Check Load Average
loadaverage=$(top -n 1 -b | grep "load average:" | awk '{print $10 $11 $12}')
echo -e $green"Load Average :" $normal $loadaverage

# Check System Uptime
tecuptime=$(uptime | awk '{print $3,$4}' | cut -f1 -d,)
echo -e $green"System Uptime Days/(HH:MM) :" $normal $tecuptime

# Unset Variables
unset normal os architecture kernelrelease internalip externalip nameserver loadaverage

# Remove Temporary Files
rm /tmp/osrelease /tmp/who /tmp/ramcache /tmp/diskusage

}
fi
shift $(($OPTIND -1))
