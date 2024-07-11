#!/bin/bash
############################################################
#  This script will automate the process of                #
#  Installing and Configuring The DMRGateway-Bridge2       #
#							   #
#  VE3RD                                      2023/06/27   #
############################################################
set -o errexit
set -o pipefail
sudo mount -o remount,rw /

HS="$1"

ver="20230627"
export NCURSES_NO_UTF8_ACS=1

if [ -f ~/.dialog ]; then
 j=1
else
 sudo dialog --create-rc ~/.dialogrc
fi
#use_colors = ON
#screen_color = (WHITE,BLUE,ON)
#title_color = (YELLOW,RED,ON)
sed -i '/use_colors = /c\use_colors = ON' ~/.dialogrc
sed -i '/screen_color = /c\screen_color = (WHITE,BLUE,ON)' ~/.dialogrc
sed -i '/title_color = /c\title_color = (YELLOW,RED,ON)' ~/.dialogrc

echo -e '\e[1;44m'
clear

Net4TG=0
Net5TG=0



sudo mount -o remount,rw /
homedir=/home/pi-star/DMRGateway-Bridge2/
curdir=$(pwd)
clear
echo " "
echo " BASIC INSTRUCTIONS"
echo " "
echo " Item 1:"
echo "	This will create and/or edit a password file. (Required for a new Install)"
echo " "
echo " Item 2 Will Setup Bridge 1 = Net1<->Net2"
echo " "
echo " Item 3 will Setup Bridge 2 - Net4<->Net5"
echo " "
echo " Item 4:"
echo "	will Ignore the existing Configuration File and"
echo "	will Compile a new Binary if Required and "
echo "	will Install the New Binary File for DMRGateway-Bridge2"
echo " "
echo " Note: This is a DUAL Bridge"
echo "     Bridge 1 - Net1 <-> Net2"
echo "     Bridge 2 - Net4 <-> Net5"
echo "     If only using one Bridge - Use Bridge 2"
echo " "

#sleep 3
read -n 1 -s -r -p "Press any key to Continue"

function TurnOnGW()
{
 sudo sed -i '/^\[/h;G;/DMR Network/s/\(Address=\).*/\1'"127.0.0.1"'/m;P;d' /etc/mmdvmhost
}

function GetSetInfo()
{
echo "Running GetSetInfo"
CALL=$(sed -nr "/^\[General\]/ { :l /^Callsign[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
ID=$(sed -nr "/^\[General\]/ { :l /^Id[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
LAT=$(sed -nr "/^\[Info\]/ { :l /^Latitude[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
LON=$(sed -nr "/^\[Info\]/ { :l /^Longitude[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
RXF=$(sed -nr "/^\[Info\]/ { :l /^RXFrequency[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
TXF=$(sed -nr "/^\[Info\]/ { :l /^TXFrequency[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
LOC=$(sed -nr "/^\[Info\]/ { :l /^Location[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
DES=$(sed -nr "/^\[Info\]/ { :l /^Description[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)


#URL=$(sed -nr "/^\[Info\]/ { :l /^URL[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
sudo mount -o remount,rw /

 sudo sed -i '/^\[/h;G;/Info/s/\(Latitude=\).*/\1'"$LAT"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/Info/s/\(Longitude=\).*/\1'"$LON"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/Info/s/\(Id=\).*/\1'"$ID"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/Info/s/\(RXFrequency=\).*/\1'"$RXF"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/Info/s/\(TXFrequency=\).*/\1'"$TXF"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/Info/s/\(Location=\).*/\1'"$LOC"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/Info/s/\(Description=\).*/\1'"$DES"'/m;P;d' /etc/dmrgateway

SN=$(sed -nr "/^\[General\]/ { :l /^StartNet[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/dmrgateway)
if [ ! "$SN" ]; then 
sed -i 's/\[General\]/\[General\]\nStartNet=4/g' /etc/dmrgateway 
fi

URL1="HTTP:\/\/www.qrz.com\/db\/$CALL"
echo "URL $URL1"

 sudo sed -i '/^\[/h;G;/Info/s/\(URL=\).*/\1'"$URL1"'/m;P;d' /etc/dmrgateway

sed -i 's/CallSign/'"$CALL"'/g' /etc/dmrgateway

}

function SetupBridge1()
{
echo "Setting up Network1"

#[DMR Network 1]
Id1="$ID""01"
 PWD=$(sed -nr "/^\[DMR Network 1\]/ { :l /^PWD[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
 ENAB=$(sed -nr "/^\[DMR Network 1\]/ { :l /^Enabled[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
SVRN=$(sed -nr "/^\[DMR Network 1\]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
SVRA=$(sed -nr "/^\[DMR Network 1\]/ { :l /^Address[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
ID=$(sed -nr "/^\[DMR Network 1\]/ { :l /^ID[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
CALL=$(sed -nr "/^\[DMR Network 1\]/ { :l /^Callsign[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
TG=$(sed -nr "/^\[DMR Network 1\]/ { :l /^TG[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)

ID="$ID""31"
test=$(echo $SVRN | sed -n '/DMR+/p')

sudo mount -o remount,rw / 
sudo sed -i '/^\[/h;G;/DMR Network 1/s/\(URL=\).*/\1'"$Id"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 1/s/\(Password=\).*/\1'"$PWD"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 1/s/\(Id=\).*/\1'"$ID"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 1/s/\(Enabled=\).*/\1'"$ENAB"'/m;P;d' /etc/dmrgateway

 sudo sed -i '/^\[/h;G;/DMR Network 1/s/\(TGRewrite0=\).*/\1'"2,$Net1TG,2,$Net1TG,1"'/m;P;d' /etc/dmrgateway

 sudo sed -i '/^\[/h;G;/DMR Network 1/s/\(Callsign=\).*/\1'"$CALL"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 1/s/\(Name=\).*/\1'"$SVRN"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 1/s/\(Address=\).*/\1'"$SVRA"'/m;P;d' /etc/dmrgateway


if [ "$test" ]; then 
 Options="StartRef=$TG;RelinkTime=60;UserLink=1;TS2_1=$TG"
 sudo sed -i '/^\[/h;G;/DMR Network 1/s/\(Options=\).*/\1'"$Options"'/m;P;d' /etc/dmrgateway
# sudo sed -i '/^\[/h;G;/DMR Network 1/s/\(Password=\).*/\1Password/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 1/s/\(Port=\).*/\155555/m;P;d' /etc/dmrgateway
 echo "Set Options Net1"
sleep 3
fi


#[DMR Network 2]
 PWD=$(sed -nr "/^\[DMR Network 2\]/ { :l /^PWD[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
 ENAB=$(sed -nr "/^\[DMR Network 2\]/ { :l /^Enabled[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
SVRN=$(sed -nr "/^\[DMR Network 2\]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
SVRA=$(sed -nr "/^\[DMR Network 2\]/ { :l /^Address[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
Id1=$(sed -nr "/^\[DMR Network 2\]/ { :l /^ID[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
CALL=$(sed -nr "/^\[DMR Network 2\]/ { :l /^Callsign[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
TG=$(sed -nr "/^\[DMR Network 2\]/ { :l /^TG[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
ID="$ID""34"
test=$(echo $SVRN | sed -n '/DMR+/p')

echo "End of Net2 Reads"

sudo mount -o remount,rw / 
 sudo sed -i '/^\[/h;G;/DMR Network 2/s/\(URL=\).*/\1'"$Id"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 2/s/\(Password=\).*/\1'"$PWD"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 2/s/\(Id=\).*/\1'"$ID"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 2/s/\(Enabled=\).*/\1'"$ENAB"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 2/s/\(TGRewrite0=\).*/\1'"2,$Net2TG,2,$Net2TG,1"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 2/s/\(Callsign=\).*/\1'"$CALL"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 2/s/\(Name=\).*/\1'"$SVRN"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 2/s/\(Address=\).*/\1'"$SVRA"'/m;P;d' /etc/dmrgateway

echo "End of Net2 Writes"

if [ "$test" ]; then 
 Options="StartRef=$TG;RelinkTime=60;UserLink=1;TS2_1=$TG"
 sudo sed -i '/^\[/h;G;/DMR Network 2/s/\(Options=\).*/\1'"$Options"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 2/s/\(Password=\).*/\1Password/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 2/s/\(Port=\).*/\155555/m;P;d' /etc/dmrgateway
 echo "Set Options Net2"
echo "End of Net2 Test Loop"

sleep 3
fi
Menu
}

function SetupBridge2()
{
echo "Running SetNetwork4"

#[DMR Network 4]
 PWD=$(sed -nr "/^\[DMR Network 4\]/ { :l /^PWD[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
 ENAB=$(sed -nr "/^\[DMR Network 4\]/ { :l /^Enabled[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
SVRN=$(sed -nr "/^\[DMR Network 4\]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
SVRA=$(sed -nr "/^\[DMR Network 4\]/ { :l /^Address[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
Id1=$(sed -nr "/^\[DMR Network 4\]/ { :l /^ID[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
CALL=$(sed -nr "/^\[DMR Network 4\]/ { :l /^Callsign[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
TG=$(sed -nr "/^\[DMR Network 4\]/ { :l /^TG[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
ID="$ID""34"
test=$(echo $SVRN | sed -n '/DMR+/p')


sudo mount -o remount,rw / 
sudo sed -i '/^\[/h;G;/DMR Network 4/s/\(URL=\).*/\1'"$Id"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 4/s/\(Password=\).*/\1'"$PWD"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 4/s/\(Id=\).*/\1'"$ID"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 4/s/\(Enabled=\).*/\1'"$ENAB"'/m;P;d' /etc/dmrgateway

 sudo sed -i '/^\[/h;G;/DMR Network 4/s/\(TGRewrite0=\).*/\1'"2,$Net4TG,2,$Net4TG,1"'/m;P;d' /etc/dmrgateway

 sudo sed -i '/^\[/h;G;/DMR Network 4/s/\(Callsign=\).*/\1'"$CALL"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 4/s/\(Name=\).*/\1'"$SVRN"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 4/s/\(Address=\).*/\1'"$SVRA"'/m;P;d' /etc/dmrgateway

if [ "$test" ]; then 
 Options="StartRef=$TG;RelinkTime=60;UserLink=1;TS2_1=$TG"
 sudo sed -i '/^\[/h;G;/DMR Network 4/s/\(Options=\).*/\1'"$Options"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 4/s/\(Password=\).*/\1Password/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 4/s/\(Port=\).*/\155555/m;P;d' /etc/dmrgateway
 echo "Set Options Net4"
sleep 3
fi


echo "Running SetNetwork5"


#[DMR Network 5]
 PWD=$(sed -nr "/^\[DMR Network 5\]/ { :l /^PWD[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
 ENAB=$(sed -nr "/^\[DMR Network 5\]/ { :l /^Enabled[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
SVRN=$(sed -nr "/^\[DMR Network 5\]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
SVRA=$(sed -nr "/^\[DMR Network 5\]/ { :l /^Address[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
Id1=$(sed -nr "/^\[DMR Network 5\]/ { :l /^ID[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
CALL=$(sed -nr "/^\[DMR Network 5\]/ { :l /^Callsign[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
TG=$(sed -nr "/^\[DMR Network 5\]/ { :l /^TG[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" $pwf)
ID="$ID""34"
test=$(echo $SVRN | sed -n '/DMR+/p')


sudo mount -o remount,rw / 
sudo sed -i '/^\[/h;G;/DMR Network 5/s/\(URL=\).*/\1'"$Id"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 5/s/\(Password=\).*/\1'"$PWD"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 5/s/\(Id=\).*/\1'"$ID"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 5/s/\(Enabled=\).*/\1'"$ENAB"'/m;P;d' /etc/dmrgateway

 sudo sed -i '/^\[/h;G;/DMR Network 5/s/\(TGRewrite0=\).*/\1'"2,$Net5TG,2,$Net5TG,1"'/m;P;d' /etc/dmrgateway

 sudo sed -i '/^\[/h;G;/DMR Network 5/s/\(Callsign=\).*/\1'"$CALL"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 5/s/\(Name=\).*/\1'"$SVRN"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 5/s/\(Address=\).*/\1'"$SVRA"'/m;P;d' /etc/dmrgateway

if [ "$test" ]; then 
 Options="StartRef=$TG;RelinkTime=60;UserLink=1;TS2_1=$TG"
 sudo sed -i '/^\[/h;G;/DMR Network 5/s/\(Options=\).*/\1'"$Options"'/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 5/s/\(Password=\).*/\1Password/m;P;d' /etc/dmrgateway
 sudo sed -i '/^\[/h;G;/DMR Network 5/s/\(Port=\).*/\155555/m;P;d' /etc/dmrgateway
 echo "Set Options Net5"
 sleep 3
fi
Menu
}


function CopyBin()
{
echo "Running CopyBin"

if [ ! -f /home/pi-star/DMRGateway-Bridge2/DMRGateway ]; then
	sudo mount -o remount,rw /
	make clean
	echo "Compiling DMRGateway Files"
	make
fi
	sudo mount -o remount,rw /
	echo "Stopping DMRGateway and MMDVMHost"
	sudo /home/pi-star/DMRGateway-Bridge2/binupdate.sh
}

function Menu
{

TurnOnGW

HEIGHT=15
WIDTH=90
CHOICE_HEIGHT=7
BACKTITLE="This SCRIPT will Install the DMRGateway-Bridge2 by VE3RD"
TITLE="Main Menu - DMRGateway Options"
MENU="Select your Installation Options"

OPTIONS=(1 "Create/Edit the DMRGateway Password File" 
	 2 "Setup Bridge 1 - Net 1 <-> Net 2"
	 3 "Setup Bridge 2 - Net 4 <-> Net 5"
         4 "Install DMRGateway NO Config File Update"
	 5  "Restart DMRGateway-Bridge2"
	 6  "Quit")


CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
echo -e '\e[1;44m'


case $CHOICE in
        1)
            echo "Editing The DMRGateway Password File"		
	    if [ !  -f /etc/dmrgwpass ]; then
		cp /home/pi-star/DMRGateway-Bridge2/DMRGateway.pw /etc/dmrgwpass
	   fi
		nano /etc/dmrgwpass
		Menu
            ;;
         2)       GetSetInfo

  #		Net4TG=$(\
  #		dialog --title "Bridge 1 - Net 1 <-> Net 2" \
  #     	--inputbox "Enter the TG for Network 1:" 8 60 \
  #		3>&1 1>&2 2>&3 3>&- \
#		)
#
#  		Net5TG=$(\
#  		dialog --title "Bridge 1 - Net 1 <-> Net 2" \
#         	--inputbox "Enter the TG for Network 5:" 8 60 \
#  		3>&1 1>&2 2>&3 3>&- \
#		)
#
                SetupBridge1
            ;;

         3)       GetSetInfo
                SetupBridge2
		;;
         4)
            echo "You Chose to Install DMRGateway - No Config File Update"		
		CopyBin
		dmrgateway.service restart
            ;;
         5)       echo "ReStarting Bridge2"
                dmrgateway.service restart
		tail -f -n 1000 `ls -t /var/log/pi-star/DMRGateway* | head -1`
		;;
	6)   echo " You Chose to Quit"
		exit
	;;
	esac

}
sudo mount -o remount,rw /
pwf=/etc/dmrgwpass
if [ ! /etc/dmrgwpass ]; then
 sudo cp /home/pi-star/DMRGateway-Bridge2/DMRGateway.pw /etc/dmrgwpass
fi
Menu
echo -e '\e[1;40m'
clear
#dmrgateway.service restart ; mmdvmhost.service restart

sleep 3
#	sudo reboot


        
