All: .we-have-dev-ppp .apt-get-updated .openswan-installed .setup.ipsec .xl2tpd-installed

PUBIP = $(shell ifconfig eth0 | grep 'inet addr' | perl -pe 's/.*inet addr:(.*)  Bca.*/\1/' )
PRIVIP = $(shell ifconfig eth1 | grep 'inet addr' | perl -pe 's/.*inet addr:(.*)  Bca.*/\1/' )

clean:
	rm -f *3.8.4*.deb
	rm -f .kernel-is-3.8.4
	rm -f .we-have-dev-ppp
	rm -f .sh-is-bash
	rm -f ipsec.conf.l2tp.example.txt ipsec.secrets.l2tp.example.txt
	rm -f .setup.ipsec
	rm -f .redirects-off
	rm -f .ipv4-forwarding-on:
	rm -f .outbound-SNAT-on
	rm -f xl2tpd.conf.l2tp.example.txt chap-secrets.l2tp.example.txt

realclean:
	make clean
	rm -f .apt-get-updated
	rm -f .openswan-installed

.xl2tpd-installed:
	apt-get install ppp
	apt-get install xl2tpd
	wget http://l03.ryan.net/data/xl2tpd.conf.l2tp.example.txt
	cat xl2tpd.conf.l2tp.example.txt > /etc/xl2tpd/xl2tpd.conf
	wget http://l03.ryan.net/data/chap-secrets.l2tp.example.txt
	@cat chap-secrets.l2tp.example.txt > /etc/ppp/chap-secrets
	@echo "**** here is your /etc/ppp/chap-secrets file ****"
	@echo "YOU PROBABLY WANT TO EDIT THIS ::::::: "
	@cat /etc/ppp/chap-secrets


.ipv4-forwarding-on:
	echo 1 > /proc/sys/net/ipv4/ip_forward
	touch .ipv4-forwarding-on:

.outbound-SNAT-on:
	@iptables -L -t nat | grep SNAT || iptables -t nat -I POSTROUTING -o eth0 -j SNAT --to $(PUBIP) 
	touch .outbound-SNAT-on
	
.setup.ipsec: /etc/ipsec.secrets /etc/ipsec.conf ipsec.conf.l2tp.example.txt ipsec.secrets.l2tp.example.txt .outbound-SNAT-on .ipv4-forwarding-on .sh-is-bash .redirects-off
	touch .setup.ipsec


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

.redirects-off:
	echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
	echo 0 > /proc/sys/net/ipv4/conf/bond0/send_redirects
	echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects
	echo 0 > /proc/sys/net/ipv4/conf/dummy0/send_redirects
	echo 0 > /proc/sys/net/ipv4/conf/eql/send_redirects
	echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects
	echo 0 > /proc/sys/net/ipv4/conf/eth1/send_redirects
	echo 0 > /proc/sys/net/ipv4/conf/ip6tnl0/send_redirects
	echo 0 > /proc/sys/net/ipv4/conf/lo/send_redirects
	echo 0 > /proc/sys/net/ipv4/conf/sit0/send_redirects
	echo 0 > /proc/sys/net/ipv4/conf/tunl0/send_redirects
	echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
	echo 0 > /proc/sys/net/ipv4/conf/bond0/accept_redirects
	echo 0 > /proc/sys/net/ipv4/conf/default/accept_redirects
	echo 0 > /proc/sys/net/ipv4/conf/dummy0/accept_redirects
	echo 0 > /proc/sys/net/ipv4/conf/eql/accept_redirects
	echo 0 > /proc/sys/net/ipv4/conf/eth0/accept_redirects
	echo 0 > /proc/sys/net/ipv4/conf/eth1/accept_redirects
	echo 0 > /proc/sys/net/ipv4/conf/ip6tnl0/accept_redirects
	echo 0 > /proc/sys/net/ipv4/conf/lo/accept_redirects
	echo 0 > /proc/sys/net/ipv4/conf/sit0/accept_redirects
	echo 0 > /proc/sys/net/ipv4/conf/tunl0/accept_redirects
	touch .redirects-off


.we-have-dev-ppp: .kernel-is-3.8.4
	@ [ -e /dev/ppp ] && touch .we-have-dev-ppp || echo "no /dev/ppp found"

.kernel-is-3.8.4:
	@uname -a | grep -i ubuntu && || echo "YOU SHOULD ONLY BE RUNNING THIS ON AN UBUNTU VM!!!" && exit 10
	@uname -a | grep 3.8.4-joyent-ubuntu-12 && touch .kernel-is-3.8.4 || echo "run \"make updateto384\" to update your ubuntu kernel" && exit 9 

updateto384: linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb 
	dpkg -i linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb
	dpkg -i linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb
	@echo "*** you need to reboot now to get kernel 3.8.4 ***"

getkerneldebs: linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb

linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb:
	wget http://l03.ryan.net/data/linux-image-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb

linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb:
	wget http://l03.ryan.net/data/linux-headers-3.8.4-joyent-ubuntu-12-opt_1.0.0_amd64.deb
