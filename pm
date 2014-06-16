#!/bin/sh

#what you want to do (install, remove, etc)
cmd=$1
version="1.0"

showHelp(){
	echo "\
INFO:
	pm - package manager wrapper for apt+dpkg/yum/pacman. 
	Written by Bo Warren.  Licensed under GPLv3 2014
	-I, -R, and -U are capitals because they actually
	change the package database.

USAGE:
	pm {-I|-R} {package|file}
	pm {-s|-sl|-i} {package}
	pm {-U|-r}

OPTIONS:
	-I|install)  Install a package or a file
	-R|remove)  Remove a package or a file and its dependencies
	-s|search)  Search for a specific package in your repos
	-i|info)  get info about a certain package 
	-l|list) list all local packages
		combining the 's' and 'l' flags searches installed packages   
	-U|update) Update packages to newest version 
	-r|repositories)  Update the repository information only
	-h|help)  Show this message
	-v|version)  Print script version

EXAMPLES:
	pm -I vim gtk3 zsh	#installs the vim, gtk3, and zsh packages
	pm -U 			#updates all packages on the system
	pm -R gedit gtk3	#removes the gedit and gtk3 packages 	
	pm -U --noconfirm	#use native package manager options (pacman)
	pm -U -y		#use native package manager options (yum)"
	
}


# -U|--upgrade)  upgrades entire system (this will update to the newest version of your OS.  WARNING - EXPERIMENTAL. May cause breakages and system failure)

if [ $# -eq 0  ];then
	echo "\
Please specify a command. See 
$0 -h for help, exiting..."
	exit 1
fi


#Find a supported package manager
pkgMngr=""

#Look for apt/dpkg for Ubuntu/Debian/et all
which apt-get > /dev/null 2>&1 
if [ "$?" -eq 0 ];then 
	pkgMngr="apt + dpkg"
	myinstall="apt-get install"
	myremove="apt-get remove --purge && apt-get autoremove"
	myremovefile="dpkg -r"
	myupdate="apt-get update && apt-get upgrade"
	myupgrade="apt-get update && apt-get dist-upgrade"
	myrepos="apt-get update"
	mysearch="apt-cache search"
	myinstallfile="dpkg -i"
	mylistall="dpkg --get-selections"
	myinfo="apt-cache show"
	mysearchlocal(){
		apt-cache policy "$1" | grep -i '(none)' > /dev/null 2>&1
		if [ "$?" -ne 0 ];then
			apt-cache policy "$1"
		#else
		#	echo "Package not installed."
		fi
	}
else 
	#else if find yum, set tools
	which yum >/dev/null 2>&1
	if [ "$?" -eq 0 ];then 
		pkgMngr="Yum"
		myinstall="yum install"
		myremove="yum remove"
		myupdate="yum update"
		myupgrade="yum distro-sync"
		myrepos="yum clean expire-cache && yum check-update"
		mysearch="yum search"
		myinstallfile="$myinstall"
		mylistall="yum list installed"
		myinfo="yum info"
		mysearchlocal(){ yum list installed|grep -i "$1"; }
else 
	#else if find pacman, set tools
	which pacman > /dev/null 2>&1
	if [ "$?" -eq 0 ];then 
		pkgMngr="Pacman"
		#if found the packer wrapper, include aur support
		which packer >/dev/null 2>&1
		if [ "$?" -eq 0 ];then 
			pkgMngr="Packer"
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
		myrepos="pacman -Sy"
		myremove="pacman -Rsn"
		myinstallfile="pacman -U"
		mylistall="$mysearchlocal"
		myinfo="pacman -Si"
		mysearchlocal(){ pacman -Qs "$1"; }
	
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


# Make sure only root can run this script
if [ `id -u` -ne 0 ];then #-a "$cmd" != "search" ]; then
	pre="sudo"
	myinstall="$pre $myinstall"
	myremove="$pre $myremove"
	myupdate="$pre $myupdate"
	myupgrade="$pre $myupgrade"
	myrepos="$pre $myrepos"
	myinstallfile="$pre $myinstallfile"
	mysearch="$pre $mysearch"
fi

#implement the actual actions
case "$cmd" in
	#install
	"install" | "-I")
		echo "Using $pkgMngr"

		#check number of args
		if [ $# -lt 1 ]; then 
			echo "please specify a package or file to install, exiting..."
			exit 1
		fi

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
	"update" | "-U")
		echo "Using $pkgMngr"

		echo "starting full update"
		sh -c "$myupdate $allopts"
	;;

	#upgrade your system 
	#experimental, may cause breakages
#	"upgrade" | "-U")
#		echo "Using $pkgMngr"
#
#		echo "starting full upgrade"
#		sh -c "$myupgrade $allopts"
#	;;

	#update the repositories 
	"repositories" | "-r")
		echo "Using $pkgMngr"

		echo "updating the repositories"
		sh -c "$myrepos"
	;;

	#uninstall a package
	"remove" | "-R")
		echo "Using $pkgMngr"

		#check number of args
		if [ $# -lt 1 ]; then 
			echo "please specify a package or file to remove, exiting..."
			exit 1
		fi

		echo "uninstalling "
		sh -c "$myremove $allopts"
	;;

	#search for a package in repos
	"search" | "-s")
		echo "Using $pkgMngr"

		#check number of args
		if [ $# -lt 1 ]; then 
			echo "please specify a package or file to remove, exiting..."
			exit 1
		fi

		echo "searching repos"
		echo "$mysearch"
		sh -c "$mysearch $lastarg"
	;;

	#search locally installed packages
	"-ls" | "-sl")
		echo "Using $pkgMngr"

		if [ $# -gt 0 ];then
			echo "searching locally installed packages"
			#sh -c "$mysearchlocal $lastarg"
			mysearchlocal $lastarg
		else
			echo "please specify a package to search for"
			exit
		fi
	;;
	"info" | "-i")
		echo "Using $pkgMngr"

		#check number of args
		if [ $# -lt 1 ]; then 
			echo "please specify a package to find info..."
			exit 1
		fi

		echo "getting info about package $lastarg"
		sh -c "$myinfo $lastarg"
	;;
	#list all
	"list" | "-l")
		echo "Using $pkgMngr"
		echo "listing all installed packages"
		sh -c "$mylistall"
			
	;;
	"help" | "-h")  
		showHelp
	;;
	"version" | "-v")
		echo "pm - Version $version"
	;;
	#handle all other weird flags
	*)
		echo "\
'$cmd' flag and multiple commands not supported. See 
$0 -h for help."
esac
