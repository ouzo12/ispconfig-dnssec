#!/bin/bash
conffile="/root/dnssec-mysql/config.sh"
if [ ! -f $conffile ];then
 echo "please edit dnssec-create.sh and enter correct path for config.sh i conffile"
 echo "like: conffile=/root/dnssec-mysql/config.sh"
 exit
fi
source $conffile

mysqlcheck=`mysql -u $dbuser --password=$dbpass -h $dbhost -Bse "use $dbase; show tables;" | wc -c`
if [ "$mysqlcheck" = 0 ];then
 echo "could not connect to dataase"
 exit 0
fi
mysqlcheck=`mysql -u $dbuser --password=$dbpass -h $dbhost -Bse "use $dbase; select * from domains where domain='$1';" | wc -c`
if [ "$mysqlcheck" -gt 1 ];then
 echo "$1 does already exists"
 echo "update or delete key from sql"
fi
cd $bindpath

if [ ! $1 = "" ];then
 if [ ! -f pri.$1 ]; then
  echo "$1 zone does not exist"
  exit 0
 else
 if [ -f dsset-$1. ];then
  echo "dnssec keys for $1 already exists!"
  exit 0
 else
  echo "Creating keys for $1"
  dnssec-keygen -a NSEC3RSASHA1 -b 2048 -n ZONE $1
  dnssec-keygen -f KSK -a NSEC3RSASHA1 -b 4096 -n ZONE $1
  for key in `ls K$1*.key`; do
   echo "\$INCLUDE $key">> pri.$1
  done
  dnssec-signzone -A -3 $(head -c 1000 /dev/random | sha1sum | cut -b 1-16) -N INCREMENT -o $1 -t pri.$1
 fi
fi
serial=`cat pri.tja-data.dk |grep "serial," |awk {' print $1 '}`
echo ""
dnssechelp=`head -1 dsset-$1.`
dnssecid=`echo $dnssechelp | awk {' print $4 '}`
dnssecalg=`echo $dnssechelp | awk {' print $5 '}`
dnssecdt=`echo $dnssechelp | awk {' print $6 '}`
dnssecd=`echo $dnssechelp | awk {' print $7 '}`
echo "DNSSEC info for : $1"
echo "Copy/paste into Domain provider, dnssec setup"
echo ""
echo "DS Record 1:"
echo "Key Tag/ID: $dnssecid"
echo "Algorithm: $dnssecalg"
echo "Digest/HASH Type: $dnssecdt"
echo "Digest/HASH: $dnssecd"

dns2sechelp=`tail -n 1 dsset-$1.`
dns2secid=`echo $dns2sechelp | awk {' print $4 '}`
dns2secalg=`echo $dns2sechelp | awk {' print $5 '}`
dns2secdt=`echo $dns2sechelp | awk {' print $6 '}`
dns2secd=`echo $dns2sechelp | awk {' print $7""$8 '}`
echo ""
echo "DS Record 2:"
echo "Key Tag/ID: $dns2secid"
echo "Algorithm: $dns2secalg"
echo "Digest/HASH Type: $dns2secdt"
echo "Digest/HASH: $dns2secd"

mysql -h $dbhost -Bse "use $dbase; insert into domains set domain='$1', active='1', serial='$serial', ds1id='$dnssecid', ds1alg='$dnssecalg', ds1htype='$dnssecdt', ds1hash='$dnssecd', ds2id='$dns2secid', ds2alg='$dns2secalg', ds2htype='$dns2secdt', ds2hash='$dns2secd', created=now() ;"

else
 echo "usage: dnssec-create.sh <domain.tld>"
fi
cd $curpath
