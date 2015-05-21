#!/bin/sh

systems="ubuntu debian fedora centos opensuse arch gentoo"

for sys in $systems;do
	#sudo docker exec /pm -I wget
	#sudo docker exec $sys rm pm*
	#sudo docker exec $sys wget --no-check-certificate 'https://raw.githubusercontent.com/bhwarren/pm/testing/pm'
	#sudo docker exec $sys chmod +x pm
	printf "system: $sys\n"
	sudo docker exec -it $sys /pm -s screen
	printf "\n\n"
	#sudo docker exec $sys
done
