#!/bin/bash
#mysql
dbase=dnssec
dbhost=localhost
dbuser=dnssecuser
dbpass=dnssecpass

bindpath=/etc/bind
backuppath=$bindpath/backup
curpath=`pwd`
filespre="pri."
timenow=`/bin/date +"%Y%m%d-%H%M%S"`

#changeallowtransfer set to 1 will rewrite all zone not allowd (none) into transferallow ips
changeallowtransfer="1"
#insert ns2 and any else you want. seperate with ; and end line with ;
transferallow="1.2.3.4;5.6.7.8;"

namedconf="$bindpath/named.conf.local"
md5namedconf="$bindpath/named.conf.local.md5"
