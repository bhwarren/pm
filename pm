#!/bin/sh

#what you want to do (install, remove, etc)
cmd=$1



showHelp(){
	echo "Usage:
	pm {inst|rm|search} {package|file}
	inst|install|-i) installs a package or a file
	rm|remove|-r) removes a package or a file and its dependencies
	search|-s) look for a specific package in your repos
		optional: -l|local) search for installed packages on your OS"
}

if [ "$cmd" = "-h" ]; then showHelp; exit;fi


#Check for a package name to work with if not updating
if [ "$cmd" != "updt" -a "$cmd" != "update" -a "$cmd" != "-u" -a "$cmd" != "upgrd" -a "$cmd" != "upgrade" -a "$cmd" != "-U" ];then
	needMoreOpts=1
fi

if [ $needMoreOpts -eq 1 -a $# -lt 2 ];then
	echo "Please specify a command. See pm -h for more information, exiting..."
	exit 1
fi


#support install, remove, search(local+dbs), install bin file

#Find a supported package manager

#Look for apt/dpkg for Ubuntu/Debian/et all
which apt-get > /dev/null 2>&1 
if [ "$?" -eq 0 ];then 
	echo "Using apt + dpkg"
	myinstall="apt-get install"
	myremove="apt-get remove --purge && apt-get autoremove"
	myremovefile="dpkg -r"
	myupdate="apt-get update && apt-get upgrade"
	myupgrade="apt-get update && apt-get dist-upgrade"
	mysearch="apt-cache search"
	mysearchlocal="apt-cache policy"
	myinstallfile="dpkg -i"
else 
	#else if find yum, set tools
	which yum >/dev/null 2>&1
	if [ "$?" -eq 0 ];then 
		echo "yum"
		myinstall="yum install"
		myremove="yum remove"
		myupdate="yum update"
		myupgrade="yum distro-sync"
		mysearch="yum search"
		mysearchlocal="yum list installed|grep "
		myinstallfile="$myinstall"
else 
	#else if find pacman, set tools
	which pacman > /dev/null 2>&1
	if [ "$?" -eq 0 ];then 
		echo "pacman"
		#if found the packer wrapper, include aur support
		which packer >/dev/null 2>&1
		if [ "$?" -eq 0 ];then 
			myinstall="packer -S"
			myupdate="packer -Syyu"
			myupgrade="packer -Syyu"
			mysearch="packer -Ss"
		else
			myinstall="pacman -S"
			myupdate="pacman -Syyu"
			myupgrade="pacman -Syyu"
			mysearch="pacman -Ss"
		fi
		myremove="pacman -Rsn"
		mysearchlocal="pacman -Qs"
		myinstallfile="pacman -U"
	
else
	echo "Unable to find a supported package manager, exiting..."
	exit 2
fi
fi
fi

#Generate list of arguments
shift
for i;do 
	allopts="$allopts $i"
done 


#get last argument (used for package file name)
lastarg=$i


# Make sure only root can run our script
if [ "$(id -u)" != "0" -a "$cmd" != "search" ]; then
	pre="sudo"
	myinstall="$pre $myinstall"
	myremove="$pre $myremove"
	myupdate="$pre $myupdate"
	myupgrade="$pre $myupgrade"
	myinstallfile="$pre $myinstallfile"
fi


#implement the actual actions
case "$cmd" in
	#install
	"inst" | "install" | "-i")
		#check to see if the arg is a local file
		if [ -f $lastarg ];then
			echo "installing file $lastarg"
			sh -c "$myinstallfile $lastarg"
		else
			echo "installing from repos"
			sh -c "$myinstall $allopts"
		fi
	;;
	#update your packages
	"updt" | "update" | "-u")
		echo "starting full update"
		sh -c "$myupdate $allopts"
	;;
	#upgrade your system 
	"upgrd" | "upgrade" | "-U")
		echo "starting full upgrade"
		sh -c "$myupgrade $allopts"
	;;
	#uninstall a package
	"rm" | "remove" | "-R")
		echo "uninstalling "
		sh -c "$myremove $allopts"
	;;
	#search for a package, specify flags to search locally
	"search" | "-s")
		if [ "$1" = "local" -o "$1" = "-l" ]; then
			echo "searching locally installed packages for $lastarg"
			sh -c "$mysearchlocal $lastarg"
		else
			echo "searching repos for packages"
			sh -c "$mysearch $lastarg"
		fi
esac
	

