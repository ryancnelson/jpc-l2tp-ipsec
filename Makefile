All: .we-have-dev-ppp .apt-get-updated .openswan-installed .setup.ipsec .xl2tpd-installed .bounce-things .explain-things

PUBIP = $(shell ifconfig eth0 | grep 'inet addr' | perl -pe 's/.*inet addr:(.*)  Bca.*/\1/' )
PRIVIP = $(shell ifconfig eth1 | grep 'inet addr' | perl -pe 's/.*inet addr:(.*)  Bca.*/\1/' )

.bounce-things:
	/etc/init.d/xl2tpd stop && sleep 3 ;  /etc/init.d/xl2tpd start
	/etc/init.d/ipsec stop && sleep 3 ;  /etc/init.d/ipsec start

.explain-things:
	@echo ; echo ; echo
	@echo "Your Public IP address is $(PUBIP). Use that as your Server Address."
	@echo -n "your shared secret is: "
	@cat /etc/ipsec.secrets | perl -pe 's/.*PSK //'
	@echo ; echo "Your username/password for the VPN are in /etc/ppp/chap-secrets"
	@echo "that file looks like this, currently:"
	@cat /etc/ppp/chap-secrets
	@echo 
	

clean:
	rm -f *3.8.6*.deb
	rm -f .kernel-is-3.8.6
	rm -f .we-have-dev-ppp
	rm -f .sh-is-bash
	rm -f ipsec.conf.l2tp.example.txt ipsec.secrets.l2tp.example.txt
	rm -f .setup.ipsec
	rm -f .redirects-off
	rm -f .ipv4-forwarding-on:
	rm -f .outbound-SNAT-on
	rm -f xl2tpd.conf.l2tp.example.txt chap-secrets.l2tp.example.txt
	rm -f options.xl2tpd.example.txt

realclean:
	make clean
	rm -f .apt-get-updated
	rm -f .openswan-installed

.xl2tpd-installed:
	apt-get install ppp
	apt-get install xl2tpd
	wget http://l03.ryan.net/data/xl2tpd.conf.l2tp.example.txt
	cat xl2tpd.conf.l2tp.example.txt > /etc/xl2tpd/xl2tpd.conf
	wget http://l03.ryan.net/data/options.xl2tpd.example.txt
	cat options.xl2tpd.example.txt > /etc/ppp/options.xl2tpd
	[ -e /etc/xl2tpd/l2tp-secrets ] && mv /etc/xl2tpd/l2tp-secrets /etc/xl2tpd/l2tp-secrets.example || :
	wget http://l03.ryan.net/data/chap-secrets.l2tp.example.txt
	@cat chap-secrets.l2tp.example.txt > /etc/ppp/chap-secrets
	@echo "**** here is your /etc/ppp/chap-secrets file ****"
	@echo "YOU PROBABLY WANT TO EDIT THIS ::::::: "
	@cat /etc/ppp/chap-secrets
	@/etc/init.d/xl2tpd stop
	@/etc/init.d/xl2tpd start
	

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
	for redirect in $(shell ls /proc/sys/net/ipv4/conf/*/send_redirects ) ; do echo 0 > $$redirect ; done
	touch .redirects-off


.we-have-dev-ppp: .kernel-is-3.8.6
	@ [ -e /dev/ppp ] && touch .we-have-dev-ppp || echo "no /dev/ppp found"

.kernel-is-3.8.6:
	@uname -a | grep -i ubuntu > /dev/null || echo "YOU SHOULD ONLY BE RUNNING THIS ON AN UBUNTU VM!!!"
	@### here, we omit the dev/null stuff, so it displays at least once
	@uname -a | grep -i ubuntu || exit 10
	@uname -a | grep 3.8.6-joyent-ubuntu-12 || echo ; echo "run \"make updateto386\" to update your ubuntu kernel" ; echo 
	@uname -a | grep 3.8.6-joyent-ubuntu-12 > /dev/null && touch .kernel-is-3.8.6 || exit 9 

updateto386: linux-image-3.8.6-joyent-ubuntu-12-opt_1.0.0_amd64.deb linux-headers-3.8.6-joyent-ubuntu-12-opt_1.0.0_amd64.deb 
	dpkg -i linux-image-3.8.6-joyent-ubuntu-12-opt_1.0.0_amd64.deb
	dpkg -i linux-headers-3.8.6-joyent-ubuntu-12-opt_1.0.0_amd64.deb
	@echo "*** you need to reboot now to get kernel 3.8.6 ***"

getkerneldebs: linux-image-3.8.6-joyent-ubuntu-12-opt_1.0.0_amd64.deb linux-headers-3.8.6-joyent-ubuntu-12-opt_1.0.0_amd64.deb

linux-image-3.8.6-joyent-ubuntu-12-opt_1.0.0_amd64.deb:
	wget http://linux.joyent.com/joyent_optimized_kernels/ubuntu/12/linux-image-3.8.6-joyent-ubuntu-12-opt_1.0.0_amd64.deb

linux-headers-3.8.6-joyent-ubuntu-12-opt_1.0.0_amd64.deb:
	wget http://linux.joyent.com/joyent_optimized_kernels/ubuntu/12/linux-headers-3.8.6-joyent-ubuntu-12-opt_1.0.0_amd64.deb
