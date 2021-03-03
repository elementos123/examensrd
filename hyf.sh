#!/bin/bash

echo "1. Instalación y configuración de Apache2"
echo ""
echo "2. Instalación y configuración de Nginx"
echo ""
echo "3. Instalación y configuración de vsftp"
read numero

if [ $numero = 1 ]; then
	
	systemctl stop nginx
	sudo apt install apache2 -y
	clear
	echo ""
	echo "Dominio:"
	echo ""
	read dominio

	dominiotemporal=`echo $dominio | cut -d "." -f1`
	cp -r /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/$dominiotemporal.conf

	mkdir -p /var/www/$dominio

	echo $dominio > /var/www/$dominio/index.html

	echo '<VirtualHost *:80>
        # Dominio del sitio web
        ServerName '$dominio'
        ServerAdmin webmaster@localhost
        ServerAlias www.'$dominio'
        DocumentRoot /var/www/'$dominio'  
        DirectoryIndex index.html
        ErrorDocument 404 /404.html
        #Redirect 301 / http://pepito.test/
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
</VirtualHost>' > /etc/apache2/sites-available/$dominiotemporal.conf


	a2dissite 000-default > /dev/null
	systemctl reload apache2 > /dev/null

	a2ensite $dominiotemporal > /dev/null
	systemctl reload apache2 > /dev/null


	echo "\n\n\Quieres habilitar el modulo ssl al apache2?\n"

	read habilitar

	if [ "$habilitar" = "s" ]; 
		then

		a2enmod ssl > /dev/null
		echo '<VirtualHost *:443>
	        # Dominio del sitio web
	        ServerName '$dominio'
	        ServerAdmin webmaster@localhost
	        ServerAlias '$dominio'
	        DocumentRoot /var/www/'$dominio'  
	        DirectoryIndex index.html
	        ErrorDocument 404 /404.html
        	#Redirect 301 / http://pepito.test/
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
' > /etc/apache2/sites-available/$dominiotemporal.conf
	

	fi

	systemctl restart apache2.service
fi


if [ $numero = 2 ]; then
	
	systemctl stop apache2.service
	clear
	echo ""
	echo " Dominio para configurar el sitio web"
	echo ""
	read dominio

	cp -r /etc/nginx/sites-available/default  /etc/nginx/sites-available/$dominio
		
	echo "Recuerda crear al usuario $dominio con adduser $dominio"

	mkdir -p /home/$dominio/public_html
	echo $dominio "NGINX" > /home/$dominio/public_html/index.html
	echo "Error 404 encontrado" > /home/$dominio/public_html/404.html

	echo 'server {
# Para conexiones https, se debe poner listen 443;
listen 80;
# Habilitamos https
#ssl    on; 
#ssl_certificate    /etc/ssl/su_dominio_com.crt; (o su_dominio_com.crt.pem)
#ssl_certificate_key    /etc/ssl/su_dominio_com.key;
root /home/'$dominio'/public_html;
index index.html index.htm index.nginx-debian.html;
server_name '$dominio' www.'$dominio';
access_log /var/log/nginx/nginx.vhost.access.log;
error_log /var/log/nginx/nginx.vhost.error.log;
# Devolver un error
error_page 404 /404.html;
}' > /etc/nginx/sites-available/$dominio

	ln -s /etc/nginx/sites-available/$dominio /etc/nginx/sites-enabled/$dominio

	service nginx restart

fi


if [ $numero = 3 ]; then
	
	apt install vsftpd -y

	echo '
	listen=NO
	listen_ipv6=YES
	anonymous_enable=NO # Permite acceder a los usuarios anonimos
	local_enable=YES # Permite acceder a los usuarios locales
	write_enable=YES # Permite modificar a los usuarios los archivos de su ruta
	chown_uploads=YES # Permite subir archivos a los usuarios anonimos
	chroot_root_user=YES # Enjaula a los usuarios
	local_umask=022 #777 - 022 = 755' >> /etc/vsftpd.conf

	#<>
	#<>

fi
