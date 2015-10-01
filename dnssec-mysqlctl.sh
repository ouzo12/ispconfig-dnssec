#!/bin/bash
conffile="/root/dnssec-mysql/config.sh"
if [ ! -f $conffile ];then
 echo "please edit dnssec-create.sh and enter correct path for config.sh i conffile"
 echo "like: conffile=/root/dnssec-mysql/config.sh"
 exit
fi
source $conffile

cd $bindpath
if [ "$1" = "" ] || [ "$2" = "" ];then
 echo "delete domain from mysql: dnssec-mysqlctl.sh delete <domain>"
 echo "info about domain from mysql: dnssec-mysqlctl.sh info <domain>"
 echo "update ds info in mysql: dnssec-mysqlctl.sh update <domain>"
 echo "list domains from mysql: dnssec-mysqlctl.sh list all"
 cd $curparh
 exit 0
fi

if [ "$1" = "delete" ];then
echo "delete $2 from dnssec db"
mysql -u $dbuser --password=$dbpass -h $dbhost -Bse "use $dbase; delete from domains where domain='$2';"
fi

if [ "$1" = "info" ];then
 mysqlinfo=`mysql -u $dbuser --password=$dbpass -h $dbhost -Bse "use $dbase; select * from domains where domain='$2';"`
 if [ `echo $mysqlinfo | wc -c` -gt 1 ]; then
  active=`echo $mysqlinfo | awk {' print $3 '}`
  serial=`echo $mysqlinfo | awk {' print $4 '}`
  ds1id=`echo $mysqlinfo | awk {' print $5 '}`
  ds1alg=`echo $mysqlinfo | awk {' print $6 '}`
  ds1htype=`echo $mysqlinfo | awk {' print $7 '}`
  ds1hash=`echo $mysqlinfo | awk {' print $8 '}`
  ds2id=`echo $mysqlinfo | awk {' print $9 '}`
  ds2alg=`echo $mysqlinfo | awk {' print $10 '}`
  ds2htype=`echo $mysqlinfo | awk {' print $11 '}`
  ds2hash=`echo $mysqlinfo | awk {' print $12 '}`
  last_updated=`echo $mysqlinfo | awk {' print $13" "$14 '}`
  created=`echo $mysqlinfo | awk {' print $15" "$16 '}`
  echo "domain: $2"
  echo "active (0=off/1=on): $active"
  echo "current serial: $serial"
  echo "DS1 info : ID $ds1id Algorithm $ds1alg Type $ds1htype Hash $ds1hash"
  echo "DS2 info : ID $ds2id Algorithm $ds2alg Type $ds2htype Hash $ds2hash"
  echo "zone last updatet at $last_updated"
  echo "zone created at $created"
  else
  echo "$2 does not exists"
 fi
fi

if [ "$1" = "update" ];then
 if [ -f dsset-$2. ];then
  serial=`cat $filespre$2 |grep "serial," |awk {' print $1 '}`
  echo "read and insert from dsset-$2. file"
  dnssechelp=`head -1 dsset-$2.`
  dnssecid=`echo $dnssechelp | awk {' print $4 '}`
  dnssecalg=`echo $dnssechelp | awk {' print $5 '}`
  dnssecdt=`echo $dnssechelp | awk {' print $6 '}`
  dnssecd=`echo $dnssechelp | awk {' print $7 '}`
  dns2sechelp=`tail -n 1 dsset-$2.`
  dns2secid=`echo $dns2sechelp | awk {' print $4 '}`
  dns2secalg=`echo $dns2sechelp | awk {' print $5 '}`
  dns2secdt=`echo $dns2sechelp | awk {' print $6 '}`
  dns2secd=`echo $dns2sechelp | awk {' print $7""$8 '}`
  mysql -h $dbhost -Bse "use $dbase; update domains set active='1', serial='$serial', ds1id='$dnssecid', ds1alg='$dnssecalg', ds1htype='$dnssecdt', ds1hash='$dnssecd', ds2id='$dns2secid',
 ds2alg='$dns2secalg', ds2htype='$dns2secdt', ds2hash='$dns2secd' where domain='$2';"
 else
 echo "dsset-$2. file not found"
fi
fi

if [ "$1" = "list" ] && [ "$2" = "all" ] ;then
 echo "Domain:         Active: Serial:         Last Updated:           Created:"
 mysql -h $dbhost -Bse "use $dbase; select domain,active,serial,last_updated,created from domains;"
fi

cd $curpath
