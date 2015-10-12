#!/bin/bash
conffile="/root/dnssec-mysql/config.sh"
if [ ! -f $conffile ];then
 echo "please edit dnssec-create.sh and enter correct path for config.sh i conffile"
 echo "like: conffile=/root/dnssec-mysql/config.sh"
 exit
fi
source $conffile

if [ ! -d $backuppath ]; then mkdir -p $backuppath; fi
#connect to database
mysqlcheck=`mysql -u $dbuser --password=$dbpass -h $dbhost -Bse "use $dbase; show tables;" | wc -c`
if [ "$mysqlcheck" = 0 ];then
 echo "could not connect to dataase"
 exit 0
fi

#check if md5 for $namedconf exists if not creates and exits
if [ ! -s $md5namedconf ]; then
 md5sum $namedconf > $md5namedconf
 exit 0
fi

#check if md5 match file if not make it update and match
md5check=`md5sum -c $md5namedconf | awk {' print $2 '}`
if [ ! "$md5check" = "OK" ];then

 cp $namedconf $backuppath/named.conf.local.$timenow
  if [ "$changeallowtransfer" = "1" ]; then
   sed -i "s/allow-transfer {none;};/allow-transfer {$transferallow};/g" $namedconf
  fi
 mysqlcheck=`mysql -u $dbuser --password=$dbpass -h $dbhost -Bse "use $dbase; select * from domains where active='1';" | awk {' print $2":"$4 '}`
 for ACTIVE in $mysqlcheck; do
 # echo $ACTIVE
  domain=`echo $ACTIVE | sed 's/:/ /g' | awk {' print $1 '}`
  serial=`echo $ACTIVE | sed 's/:/ /g' | awk {' print $2 '}`
  cd $bindpath
  fserial=`/usr/sbin/named-checkzone $domain $bindpath/$filespre$domain | egrep -ho '[0-9]{10}'`
  cd $curpath
   if [ ! "$serial" = "$fserial" ];then
    echo "need update"
     includecheck=`cat $bindpath/$filespre$domain |grep "INCLUDE" |wc -l`
     cd $bindpath
      if [ ! $includecheck = 2 ] ;then
       for key in `ls K$domain.+*.key`; do
		echo $key key 
       echo "\$INCLUDE $key">> pri.$domain
       done
      fi

    /usr/sbin/dnssec-signzone -A -3 $(head -c 1000 /dev/random | sha1sum | cut -b 1-16) -N increment -o $domain -t $bindpath/$filespre$domain
    mysql -u $dbuser --password=$dbpass -h $dbhost -Bse "use $dbase; update domains set serial='$fserial' where domain='$domain';"
    #sed -i "s/$filespre$domain\"/$filespre$domain.signed\"/g" $namedconf
   fi
  sed -i "s/$filespre$domain\"/$filespre$domain.signed\"/g" $namedconf
done

echo "done"
#create new md5sum file
md5sum $namedconf > $md5namedconf
service bind9 reload
else
 echo "nothing to do!"
fi

exit
