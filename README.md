# ispconfig-dnssec

This project is written in bash and requires a mysql db.

Project ONLY testet on debian with latest ispconfig installed.

Setup is that NS2 mirros dns from NS1.

	https://www.howtoforge.com/how-to-run-your-own-dns-servers-primary-and-secondary-with-ispconfig-3-debian-squeeze

This should be done on NS1

install haveged

	apt-get install haveged

create a database

	CREATE DATABASE dnssec;
	GRANT SELECT ON dnssec.* TO 'dnssecuser'@'localhost' IDENTIFIED BY 'topsecretpassword';
	GRANT ALL ON  dnssec.* TO 'dnssecuser'@'localhost'; 
	FLUSH PRIVILEGES;

import dnssec.sql into database

	mysql -d dnssec -u dnssec -p < dnssec.sql

edit the config.sh file

remember to edit all dnssec-* files as well so it knows where you put config.sh

insert the updater to your crontab ( nano /etc/crontab )

	*/2     *       *       *       *       root   /root/dnssec-mysql/dnssec-update.sh > /dev/null 2>&1


use dnssec-create.sh to create dnssec keys for a domain

use dnssec-mysqlctl.sh to get info from mysql

use dnssec-update.sh to update bind files and update zones that uses dnssec.


This should be done on NS2

	chown bind:bind /etc/bind
	chown bind:bind /etc/bind/pri.*

Copy bind template to custom folder (YES slave to master)

	cp /usr/local/ispconfig/server/conf/bind_named.conf.local.slave /usr/local/ispconfig/server/conf-custom/bind_named.conf.local.master

Edit the file

	nano /usr/local/ispconfig/server/conf-custom/bind_named.conf.local.master

after "type slave;" insert following line (change ip to your ns1 ip)

	masters {1.2.3.4;};

insert the ns2-cron.sh to crontab ( nano /etc/crontab )

	*/2	* * * *     root    /root/ns2-cron.sh >/dev/null 2>&1
