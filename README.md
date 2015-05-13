pm
==

Wrapper for many package managers, with a simple syntax 

see pm -h for more information


v1.0
=======


----- v1.1 (testing) --------
- remove packer support (causing too many bugs)
- added preliminary dnf support
- added preliminary emerge support
- added preliminary zypper support


----- v1.0 ----------
- release as stable (master branch)

----- v0.94 -------- (testing) 
- added option to get info about a package
- changed option for installing,removing,update to capital (more importance) 

----- v0.9 -------- (testing) 
- added experimental upgrade option with "-U" "upgrade" or "upgrd" (not tested)
- add update repos only option "-r" "repositories" or "repos"
- better parse commands so can combine -s & -l to search locally using getopts
- if searching local and no package specified, list all
- workaround for: Apt & Yum don't have a good command for searching local packages

----- v0.8 --------
- first working version
- support simpler commands with -{char}, along with natural language, and shortented nl
- support apt/dpkg, yum, pacman/packer
- support install (repo and local), remove (loal and repo), update, search (local and repo)


To-Do:
- add opensuse/zypper support
- add gentoo/emerge support
- follow up on DNF development
- add option for 'provides'
- make search local faster for yum

testing on latest: ubuntu, debian, fedora, opensuse, centos, arch, and gentoo

References: The pacman rosetta at https://wiki.archlinux.org/index.php/Pacman_Rosetta
