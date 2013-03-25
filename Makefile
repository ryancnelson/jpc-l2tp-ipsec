All:

clean:
	rm *.deb

testkernel: .kernel-is-3.8.4
	uname -a | grep 3.8.4-joyent-ubuntu-12 && touch .kernel-is-3.8.4 || make installkernel

installkernel: linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb
	dpkg -i linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb
	dpkg -i linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb
	echo "you need to reboot now to get kernel 3.8.4"

getkernelstuff: linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb

linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb:
	wget http://l03.ryan.net/data/linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb


linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb:
	wget http://l03.ryan.net/data/linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb
