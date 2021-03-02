#!/bin/bash
clear
echo ""
echo "1. Instalar isc-dhcp-server"
echo ""
echo "2. Instalar bind9 (DNS)"
echo ""
echo "3. Comprobar concesiones de dhcp"
echo ""
echo "4. Formula para subnetear"
echo ""
echo "5. Formula calcular minutos a segundos"
echo ""
echo ""
echo "6. Formula calcular segundos a minutos"
echo ""
echo ""
echo "7. Instalar postfix y dovecot"
echo ""
read numero

if [ $numero = 1 ]; then
	apt install isc-dhcp-server -y
	echo '# yubal Alberto Cruz
	subnet 192.168.1.0 netmask 255.255.255.0 {
	range 192.168.1.10 192.168.1.20;
	option domain-name-servers 192.168.1.7, 192.168.1.8;
	option static-routes 10.0.0.0 192.168.1.1;
	option subnet-mask 255.255.255.0;
	option routers 192.168.1.1;
	option broadcast-address 192.168.1.255;
	default-lease-time 600;
	max-lease-time 7200;
	}

	host pc1 {
		hardware ethernet aa:bb:cc:dd:00:11;
		fixed-address 192.168.1.9;
	}' > /etc/dhcp/dhcpd.conf

fi



if [ $numero = 2 ]; then
	apt install bind9 -y

	echo 'zone "dominio.com"
	{
		type master;
		file "/etc/bind/db.dominio.com;"
	};

	zone 1.168.192.in-addr-arpa
	{
		type master;
		file "/etc/bind/db.192;"
	};

	#zone "otrodominio.dominio.com"
	#{
	#	type slave;
	#	masters {192.168.1.1;};
	#};' > /etc/bind/named.conf.local



	echo ';
; BIND data file for local loopback interface
;
$TTL	604800
@	IN	SOA	host.dominio.com. root.dominio.com. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	host
@	IN	A	192.168.1.2
host	IN	A	192.168.1.2
; NS para servidores
; A para ip
; CNAME para aplicaciones como ftp, www. Ejemplo: www	IN 	CNAME	host
; MX para servidores de correo	correo	IN 	MX 	10	servidorcorreo (Asignarle la IP con el registro A)
; Para hacer un intercambio de zona se debe hacer ejemplo, lo siguiente: host02	IN 	NS 	mejor.dominio2.com (Asignarle la IP con el registro A)' > /etc/bind/db.dominio.com

echo '$TTL	604800
@	IN	SOA	host.dominio.com. root.dominio.com. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	host
2	IN	PTR	host.dominio.com ' > /etc/bind/db.192

fi



if [ $numero = 3 ]; then
	
	dhcp-lease-list
fi



if [ $numero = 4 ]; then
	
	echo "2^numero de hosts tomados - 2, ejemplo: 2^7 = 128 - 2 = 126	128 - 1 = 127 -> Red de broadcast de la subred"
fi



if [ $numero = 5 ]; then
	
	echo "¿Cuántos minutos?"
	echo ""
	read numero1
	echo ""
	suma=$(expr $numero1 \* 60)

	echo $suma
fi



if [ $numero = 6 ]; then
	
	echo "¿Cuántos segundos?"
	echo ""
	read numero1
	echo ""
	suma=$(expr $numero1 / 60)

	echo $suma
fi



if [ $numero = 7 ]; then
	
	apt install postfix dovecot-core dovecot-imapd -y

	echo "home_mailbox = Maildir/" >> /etc/postfix/main.cf

	echo ""

	echo ""

	echo "Modifica los ficheros /etc/postfix/main.cf, /etc/dovecot/conf.d/10-ssl.conf y /etc/dovecot/conf.d/10-mail.conf"

	echo ""

	echo ""
fi
