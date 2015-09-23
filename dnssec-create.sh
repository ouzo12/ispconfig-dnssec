#!/bin/bash
bindpath=/etc/bind
curpath=`pwd`

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

dnssechelp=`tail -n 1 dsset-$1.`
dnssecid=`echo $dnssechelp | awk {' print $4 '}`
dnssecalg=`echo $dnssechelp | awk {' print $5 '}`
dnssecdt=`echo $dnssechelp | awk {' print $6 '}`
dnssecd=`echo $dnssechelp | awk {' print $7""$8 '}`
echo ""
echo "DS Record 2:"
echo "Key Tag/ID: $dnssecid"
echo "Algorithm: $dnssecalg"
echo "Digest/HASH Type: $dnssecdt"
echo "Digest/HASH: $dnssecd"

else
 echo "usage: dnssec-create.sh <domain.tld>"
fi
cd $curpath
