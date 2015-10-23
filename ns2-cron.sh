#!/bin/bash
bindpath=/etc/bind

#changeallowtransfer set to 1 will rewrite all zone not allowd (none) into transferallow ips
changeallowtransfer="1"
#insert ns2 and any else you want. seperate with ; and end line with ;
transferallow="1.2.3.4;5.6.7.8;"
namedconf="$bindpath/named.conf.local"

if [ "$changeallowtransfer" = "1" ]; then
  sed -i "s/allow-transfer {none;};/allow-transfer {$transferallow};/g" $namedconf
fi

chown bind:bind $bindpath/pri.*
