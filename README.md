# easy_cryptostorm_manager
#This short script is to make easier to manage the vpns after you unzip the ovpn files inside 
#After you follow instructions with the terminal on https://cryptostorm.is/nix it might not work at all
#You need to move all the .ovpn files that you got from configs.zip you need to copy or move all of them 
#To this path: /etc/openvpn/client
#After that you should be able to load the vpn: sudo openvpn --config /etc/openvpn/client/thecountrygoeshere_UDP.ovpn
#You can also try our script called vpn.sh 



#The OpenVPN in older Ubuntu apt repos is outdated, so first we'll need to add OpenVPN's repository.
#If you're on Debian 9 or Ubuntu 18.x (bionic), you can skip this step since they do include a later OpenVPN
#In Terminal, start a root shell with the command:

  sudo -s

#Enter your password when it asks. Next, add the OpenVPN repository:

  wget -O- https://swupdate.openvpn.net/repos/repo-public.gpg|apt-key add -

#Then add the OpenVPN repo to the local sources list:

   . /etc/lsb-release;echo "deb https://build.openvpn.net/debian/openvpn/stable $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/openvpn-aptrepo.list


#After that, install the latest OpenVPN with:

  apt-get update && apt-get install openvpn

#When that's done, verify that you now have the latest OpenVPN with the command:

   openvpn --version|head -n1

# To see what the latest OpenVPN version is, visit: https://openvpn.net/index.php/open-source/downloads.html

 
#Next, download and unzip the cryptostorm OpenVPN configs.

    The RSA ones are at https://cryptostorm.is/configs/rsa/configs.zip
    The ECC ones are at https://cryptostorm.is/configs/ecc/configs.zip
    The Ed25519 ones are at https://cryptostorm.is/configs/ecc/ed25519/configs.zip
    The Ed448 ones are at https://cryptostorm.is/configs/ecc/ed448/configs.zip
    See https://cryptostorm.is/config/ for details on the differences between these.

  #At least OpenVPN 2.4.x is required for the ECC configs.
# At least OpenVPN 2.4.x AND OpenSSL 1.1.1 is required for the Ed25519 and Ed448 configs.
# So for ECC, the commands would be:

  wget https://cryptostorm.is/configs/ecc/configs.zip
  unzip configs.zip


#So you don't have to enter your token every time you connect, store your token in a random file.
#(Replace CsTok-enGvX-F4b4a-j7CED with your token or your token's hash using the token hasher at https://cryptostorm.is/#section6, under the teddy bear
#And replace /home/test/cstoken with the location you want to save the token to. My username is "test", so I'm storing the file in /home/test/cstoken)

  echo CsTok-enGvX-F4b4a-j7CED > /home/test/cstoken;echo anythingcangohere >> /home/test/cstoken;chmod 600 /home/test/cstoken

#Then edit all the configs to use /home/test/cstoken:

  sed -e's_^auth-user-pass.*_auth-user-pass /home/test/cstoken_' -i *.ovpn


#HERE is where you should move all the .ovpn files to /etc/openvpn/client
  cd /home/youruser/whereveryouuzipyourconfig.zip
  sudo mv * /etc/openvpn/client

#The default Ubuntu/Debian includes a dnsmasq server that will overwrite /etc/resolv.conf, which will cause DNS leaks with OpenVPN.
#There is an update-resolv-conf script that should fix this leak, but it seems that there are different versions of this script out there, and some of them don't work.
#Instead of dealing with that or updating /etc/resolv.conf, we recommend using iptables to plug DNS leaks.
#After you connect to the VPN, run these two commands:

   iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination 10.31.33.8
   iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination 10.31.33.8

# That will redirect all DNS queries to the VPN server's DNS.
#    If you want to use our TrackerSmacker ad/tracker blocking service, replace 10.31.33.8 in the above two commands with 10.31.33.7

 #   Note: If your /etc/resolv.conf points to a localhost IP such as 127.0.0.1 or 127.0.0.53, the above rules will cause this error when you try to resolve something:
  #  ../../../../lib/isc/unix/socket.c:2135: internal_send: 127.0.0.1#53: Invalid argument
   # and DNS will fail. To get past that, run

  echo 'nameserver 1.1.1.1' > /etc/resolv.conf

#  It doesn't matter what IP you use, so long as it's not something in 127.0.0.x
#   After you run the commands above, your DNS will go to whatever IP you specify in the above command.

#  Whenever you decide to disconnect from the VPN, you can remove the DNS leak protection with the commands:

   iptables -t nat -D OUTPUT -p udp --dport 53 -j DNAT --to-destination 10.31.33.8
   iptables -t nat -D OUTPUT -p tcp --dport 53 -j DNAT --to-destination 10.31.33.8


# Finally, connect with:

   sudo openvpn --config Paris_UDP.ovpn
#    (Replace "Paris_UDP.ovpn" with whatever node you want to connect to)

#Once you see "Initialization Sequence Completed", you're connected!
# Check with https://cryptostorm.is/test to verify that your IP has changed.


