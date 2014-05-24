#!/bin/sh

#what you want to do (install, remove, etc)
cmd=$1
version="0.9"

showHelp(){
	echo "\
INFO:
	pm - package manager wrapper for apt+dpkg/yum/pacman. 
	Written by Bo Warren.  Licensed under GPLv3 2014

USAGE:
	pm {-i|-R} {package|file}
	pm {-s|-sl} {package}
	pm {-u|-r}

OPTIONS:
	-i|install)  Install a package or a file
	-R|remove)  Remove a package or a file and its dependencies
	-s|search)  Search for a specific package in your repos
	-sl|search-local)  Search installed packages on the OS.  
		If no package is specified, it lists all installed packages.
	-u|update) Update packages to newest version 
	-r|repositories)  Update the repository information only
	-h|help)  Show this message
	-v|version)  Print script version

EXAMPLES:
	pm -i vim gtk3 zsh 
	pm -u 
	pm -R gedit"
	
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
if [ "$(id -u)" != "0" -a "$cmd" != "search" ]; then
	pre="sudo"
	myinstall="$pre $myinstall"
	myremove="$pre $myremove"
	myupdate="$pre $myupdate"
	myupgrade="$pre $myupgrade"
	myrepos="$pre $myrepos"
	myinstallfile="$pre $myinstallfile"
fi

#implement the actual actions
case "$cmd" in
	#install
	"install" | "-i")
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
	"update" | "-u")
		echo "Using $pkgMngr"

		echo "starting full update"
		sh -c "$myupdate $allopts"
	;;

	#upgrade your system 
	#experimental, may cause breakages
	"upgrade" | "-U")
		echo "Using $pkgMngr"

		echo "starting full upgrade"
		sh -c "$myupgrade $allopts"
	;;

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
		sh -c "$mysearch $lastarg"
	;;

	#search locally installed packages
	"search-local" | "-sl")
		echo "Using $pkgMngr"

		if [ $# -gt 0 ];then
			echo "searching locally installed packages"
			#sh -c "$mysearchlocal $lastarg"
			mysearchlocal $lastarg
		else
			echo "listing all installed packages"
			sh -c "$mylistall"
		fi
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
