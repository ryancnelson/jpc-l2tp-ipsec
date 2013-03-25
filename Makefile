All: .kernel-is-3.8.4
	

clean:
	rm *.deb
	rm .kernel-is-3.8.4

.kernel-is-3.8.4
	uname -a | grep 3.8.4-joyent-ubuntu-12 && touch .kernel-is-3.8.4 || echo "run \"make updateto384\" to update your ubuntu kernel"

updateto384: linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb 
	echo fakerunning dpkg -i linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb
	echo fakerunning dpkg -i linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb
	echo "you need to reboot now to get kernel 3.8.4"

getkerneldebs: linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb

linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb:
	wget http://l03.ryan.net/data/linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb


linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb:
	wget http://l03.ryan.net/data/linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb