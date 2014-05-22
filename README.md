pm
==

Wrapper for many package managers, with a simple interface


----- v0.8 --------
- first working version
- support simpler commands with -{char}, along with natural language, and shortented nl
- support apt/dpkg, yum, pacman/packer
- support install (repo and local), remove (loal and repo), update, search (local and repo)

----- v0.9 -------- (testing) 
- added experimental upgrade option with "-U" "upgrade" or "upgrd" (not tested)
- add update repos only option "-r" "repositories" or "repos"
- better parse commands so can combine -s & -l to search locally using getopts
- if searching local and no package specified, list all


*Ubuntu doesn't have a good command for searching local packages

To-Do:
- stop relying on which
- add opensuse/zypper support
- add gentoo/emerge support
- follow up on DNF development
