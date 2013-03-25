All: .kernel-is-3.8.4 .we-have-dev-ppp .apt-get-updated .openswan-installed .sh-is-bash

clean:
	rm -f *3.8.4*.deb
	rm -f .kernel-is-3.8.4
	rm -f .we-have-dev-ppp
	rm -f .sh-is-bash

realclean:
	make clean
	rm -f .apt-get-updated
	rm -f .openswan-installed
	

.sh-is-bash:
	[ -f /bin/bash ] &&  ls -la /bin/sh | grep dash && ln -s /bin/bash /bin/sh.new && mv /bin/sh.new /bin/sh || echo "/bin/sh is not apparently a link to /bin/dash"
	ls -la /bin/sh | grep bash && touch .sh-is-bash

.apt-get-updated:
	apt-get update && touch .apt-get-updated

.openswan-installed: .apt-get-updated
	aptitude install openswan && ls -la /usr/sbin/ipsec && touch .openswan-installed

.we-have-dev-ppp:
	ls -la /dev/ppp && touch .we-have-dev-ppp

.kernel-is-3.8.4:
	uname -a | grep -i ubuntu > /dev/null && ( uname -a | grep 3.8.4-joyent-ubuntu-12 > /dev/null && touch .kernel-is-3.8.4 || echo "run \"make updateto384\" to update your ubuntu kernel" ) || echo "YOU SHOULD ONLY BE RUNNING THIS ON AN UBUNTU VM!!!"

updateto384: linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb 
	dpkg -i linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb
	dpkg -i linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb
	echo "you need to reboot now to get kernel 3.8.4"

getkerneldebs: linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb

linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb:
	wget http://l03.ryan.net/data/linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb

linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb:
	wget http://l03.ryan.net/data/linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb
