#!/bin/bash

#Muestra comandos que se van ejecutando por si falla
set -x

# Declaramos las variables de entorno
#-----------------------------
PHPMYADMIN_APP_PASSWORD=123456
APP_USER=samuel
APP_PASSWD=123456
#---------------------------

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

mysql -u root <<< "CREATE USER '$APP_USER'@'%' IDENTIFIED BY '$APP_PASSWD';"

mysql -u root <<<  "GRANT ALL PRIVILEGES ON *.* TO '$APP_USER'@'%'";