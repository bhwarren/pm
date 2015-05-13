#!/bin/sh

systems="ubuntu debian fedora opensuse centos arch gentoo"

for sys in $systems;do
	#sudo docker exec $sys wget 'http://raw.githubusercontent.com/bhwarren/pm/master/pm'
	#sudo docker exec $sys chmod +x pm
	printf "system: $sys\n"
	sudo docker exec -i $sys /pm -I perl
	printf "\n\n"
	#sudo docker exec $sys
done
