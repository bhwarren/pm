pm
==

Wrapper for many package managers, with a simple interface


v1
- support simpler commands with -{char}, along with natural language, and shortented nl
- support apt/dpkg, yum, pacman/packer
- support install (repo and local), remove (loal and repo), update, search (local and repo)


To-Do:
- better parse commands so can combine -s & -l to search locally
- add update repos only option "-R" "repositories" or "repos"
- add upgrade option with "-U" "upgrade" or "upgrd"
- add opensuse/zypper support
- add gentoo/emerge support
- follow up on DNF development
