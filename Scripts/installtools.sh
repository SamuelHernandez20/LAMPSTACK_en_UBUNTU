#!/bin/bash

#Muestra comandos que se van ejecutando por si falla
set -x

# las variables se importan al archivo variables para no tenerlas en el mismo script
#----Importacion de variables-------

source .env

#-----------------------------------

# Actualizamos los repos

apt update

# Actualizar paquetes 

#apt upgrade -y

# Para automatizar el proceso de instalacion sin preguntas:

# Seleccionar servidor web:

echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections

# Para configurar la base de datos:

echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections

# Seleccionar la contraseña:
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections

# Instalacion phpmyadmin
apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl


# Creacion del usuario que tenga acceso a todas las bases de datos de forma automatizada:

mysql -u root <<< "DROP USER IF EXISTS '$APP_USER'@'%'"

mysql -u root <<< "CREATE USER '$APP_USER'@'%' IDENTIFIED BY '$APP_PASSWD';"

mysql -u root <<<  "GRANT ALL PRIVILEGES ON *.* TO '$APP_USER'@'%'";

#Paso 3. INSTALAMOS ADMINER

mkdir -p /var/www/html/adminer

#--Herramientas adicionales:

#Descargamos archivo de Adminer
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer

#Renombrar nombre del archivo adminer

mv /var/www/html/adminer/adminer-4.8.1-mysql.php /var/www/html/adminer/index.php

#Modificamos el propietario y grupo del direcotrio /var/www/html

chown -R www-data:www-data /var/www/html

#Paso 4. Instalamos el GoAccess 

apt install goaccess -y

#Despues se han lanzado unos comandos que vuelcan el GoAccess en archivo html en tiempo real
#Pero para ello he tenido que abrir el puerto 7890, poniendole & al final del comando para que el terminal este libre
#sudo goaccess /var/log/apache2/access.log -o /var/www/html/report.html --log-format=COMBINED --real-time-html &
#sudo goaccess /var/log/apache2/access.log -o /var/www/html/report.html --lo
#g-format=COMBINED --real-time-html --daemonize
#Asi se covierte en segundo plano

# Creamos un directorio para los informes html GoAccess

mkdir -p /var/www/html/stats

goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html --daemonize

# Paso 5. Configuramos la autenticacion de un directorio
#Crear archivo .htpasswd

htpasswd -bc /etc/apache2/.htpasswd $STATS_USER $STATS_PASWD

# Copiamos archivo de conf apache con la configuracion de acceso al directorio
cp ../conf/000-default-stats.conf /etc/apache2/sites-available/000-default.conf

# Reiniciar servicio de apache

systemctl restart apache2

