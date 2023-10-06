#!/bin/bash

#Muestra comandos que se van ejecutando por si falla
set -x

#echo "Esto es una prueba"

# Actualizamos los repos

apt update

# Actualizar paquetes 

#apt upgrade

#Instalar apache

apt install apache2 -y

# instalar sgbd mysql

apt install mysql-server -y

#Instalacion del php

apt install php libapache2-mod-php php-mysql -y


#Copiar el archivo de conf de apache

cp ../conf/000-default.conf /etc/apache2/sites-available 

#Reiniciar servicio

systemctl restart apache2