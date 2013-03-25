All: .kernel-is-3.8.4 .we-have-dev-ppp .apt-get-updated .openswan-installed .sh-is-bash .setup.ipsec /etc/ipsec.conf /etc/ipsec.secrets

clean:
	rm -f *3.8.4*.deb
	rm -f .kernel-is-3.8.4
	rm -f .we-have-dev-ppp
	rm -f .sh-is-bash
	rm -f ipsec.conf.l2tp.example.txt ipsec.secrets.l2tp.example.txt
	rm -f .setup.ipsec

realclean:
	make clean
	rm -f .apt-get-updated
	rm -f .openswan-installed
	
.setup.ipsec: /etc/ipsec.secrets /etc/ipsec.conf ipsec.conf.l2tp.example.txt ipsec.secrets.l2tp.example.txt
	touch .setup.ipsec

PUBIP = $(shell ifconfig eth0 | grep 'inet addr' | perl -pe 's/.*inet addr:(.*)  Bca.*/\1/' )
PRIVIP = $(shell ifconfig eth1 | grep 'inet addr' | perl -pe 's/.*inet addr:(.*)  Bca.*/\1/' )

/etc/ipsec.conf: ipsec.conf.l2tp.example.txt
	echo public IP address is $(PUBIP).
	echo private IP address is $(PRIVIP).
	cat ipsec.conf.l2tp.example.txt | sed -e s/198.55.55.183/$(PUBIP)/ | sed -e s/192.168.99.99/$(PRIVIP)/ > /etc/ipsec.conf

/etc/ipsec.secrets: ipsec.secrets.l2tp.example.txt
	echo public IP address is $(PUBIP).
	echo private IP address is $(PRIVIP).
	cat ipsec.secrets.l2tp.example.txt | sed s/198.55.55.183/$(PUBIP)/ | sed s/192.168.99.99/$(PRIVIP)/ > /etc/ipsec.secrets

ipsec.conf.l2tp.example.txt:
	wget http://l03.ryan.net/data/ipsec.conf.l2tp.example.txt

ipsec.secrets.l2tp.example.txt:
	wget http://l03.ryan.net/data/ipsec.secrets.l2tp.example.txt





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
