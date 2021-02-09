#!/bin/bash

echo "
	  1 - Instalar apache2
	  2 - Instalar nginx
	  3 - Instalar bind9
	  4 - Instalar vsftpd
	  5 - Leer la configuracion del vsftpd
	  6 - Creacion de el dominio (Zona directa e inversa)
	  7 - Configurar web apache2
	  8 - Configurar web nginx"


echo "\n\nIntroduce un numero\n\n"

read numero

if [ $numero -eq "1" ]; 
then

	apt install apache2 -y

elif [ $numero -eq "2" ]; 
	then

	apt install nginx -y

elif [ $numero -eq "3" ]; 
	then

	apt install bind9 -y

elif [ $numero -eq "4" ]; 
	then
	
	apt install vsftpd -y

elif [ $numero -eq "5" ]; 
	then
	
	man /etc/vsftpd.conf

elif [ $numero -eq "6" ]; 
	then

	echo "\n\nIntroduce el dominio a crear, ejemplo: example.com\n\n"

	read dominio

	echo "Creando zona directa...\n\n"

	echo 'zone "'$dominio'"
	{
		type master;
		file "/etc/bind/db.'$dominio'";
	};' > /etc/bind/named.conf.local

	cp /etc/bind/db.local /etc/bind/db.$dominio

	echo '$TTL	604800
@	IN	SOA	'`cat /etc/hostname`'.'$dominio'. root.'$dominio'. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	programar
@	IN	A	'`hostname -i`'
programar	IN	A	'`hostname -i`'
@	IN	MX	10	mail
mail	IN	A	'`hostname -i`' 
' > /etc/bind/db.$dominio

	echo "\n\nEscribe ip de la zona inversa, ejemplo 1.168.192"

	read ip

	echo 'zone "'$ip'.in-addr.arpa"
	{
		type master;
		file "/etc/bind/db.192";
	};' >> /etc/bind/named.conf.local


	echo '$TTL	604800
@	IN	SOA	'`cat /etc/hostname`'.'$dominio'. root.'$dominio'. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	programar
'`hostname -i | cut -d "." -f 4`'	IN	PTR	'`cat /etc/hostname`' 
' > /etc/bind/db.192

echo "nameserver `hostname -i`" > /etc/resolv.conf

systemctl restart bind9

nslookup $dominio

elif [ $numero -eq 7 ]; 
	then

	systemctl stop nginx

	echo "\n\nDominio para configurar el sitio web\n\n"

	read haber.test
	
	echo $dominio > dominio.txt
	
	cp -r /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/`cut -d "." -f1 dominio.txt`.conf

	mkdir /var/www/$dominio

	echo '<VirtualHost *:80>

        # Dominio del sitio web
        ServerName '$dominio'

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/'$dominio'  
        DirectoryIndex index.html index.php

        #<Directory /var/www/'$dominio'/>	 	 
 		#	Options -Indexes	 	 
 		#	AllowOverride All	 	 
 		#	Order allow,deny	 	 
 		#	allow from all	 	
		#</Directory>	

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        #ErrorLog /var/www/'$dominio'/error.log
        #CustomLog /var/www/'$dominio'/access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf
</VirtualHost>
' > /etc/apache2/sites-available/`cut -d "." -f1 $dominio`.conf


	a2dissite 000-default > /dev/null
	systemctl reload apache2 > /dev/null

	a2ensite $dominio > /dev/null
	systemctl reload apache2 > /dev/null

	echo "\n\n\Quieres habilitar el modulo ssl al apache2?\n"

	read habilitar

	if [ "$habilitar" = "s" ]; 
		then

		a2enmod ssl > /dev/null
		a2ensite default-ssl > /dev/null
		echo '<VirtualHost *:443>

	        # Dominio del sitio web
	        ServerName '$dominio'

	        ServerAdmin webmaster@localhost
	        DocumentRoot /var/www/'$dominio'  
	        DirectoryIndex index.html index.php

	        #SSL
	        #SSLEngine on
			#SSLCertificateFile /etc/ssl/private/web.pem
			#SSLCertificateKeyFile /etc/ssl/private/web.key

	        #<Directory /var/www/'$dominio'/>
	 		#	Options -Indexes
	 		#	AllowOverride All
	 		#	Order allow,deny
	 		#	allow from all
			#</Directory>

	        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
	        # error, crit, alert, emerg.
	        # It is also possible to configure the loglevel for particular
	        # modules, e.g.
	        #LogLevel info ssl:warn

	        #ErrorLog ${APACHE_LOG_DIR}/error.log
	        #CustomLog ${APACHE_LOG_DIR}/access.log combined

	        # For most configuration files from conf-available/, which are
	        # enabled or disabled at a global level, it is possible to
	        # include a line for only one particular virtual host. For example the
	        # following line enables the CGI configuration for this host only
	        # after it has been globally disabled with "a2disconf".
	        #Include conf-available/serve-cgi-bin.conf
</VirtualHost>
' > /etc/apache2/sites-available/`cut -d "." -f1 $dominio`.conf
		systemctl restart apache2.service

	fi

elif [ $numero -eq 8 ]; 
	then

	systemctl stop apache2

	echo "\n\nDominio para configurar el sitio web\n\n"

	read dominio

	cp -r /etc/nginx/sites-available/default  /etc/nginx/sites-available/$dominio

	`adduser $dominio`

	echo 'server {

# Para conexiones https, se debe poner listen 443;
listen 80;

# Habilitamos https
#ssl    on; 
#ssl_certificate    /etc/ssl/su_dominio_com.crt; (o su_dominio_com.crt.pem)
#ssl_certificate_key    /etc/ssl/su_dominio_com.key;

root /home/'$dominio'/public_html;

index index.html index.htm;

server_name www.'$dominio' '$dominio';

access_log /var/log/nginx/nginx.vhost.access.log;
error_log /var/log/nginx/nginx.vhost.error.log;

# Devolver un error
#return 404 /home/'$dominio'/public_html/404.html

}' > /etc/nginx/sites-available/$dominio

	ln -s /etc/nginx/sites-available/$dominio /etc/nginx/sites-enabled/$dominio

	service nginx restart

fi
