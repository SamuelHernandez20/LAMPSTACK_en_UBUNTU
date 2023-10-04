#!/bin/bash

#Muestra comandos que se van ejecutando por si falla
set -x

echo "Esto es una prueba"

# Actualizamos los repos

#sudo apt update

# Actualizar paquetes 

#sudo apt upgrade

#Instalar apache

sudo apt install apache2 -y

# instalar sgbd mysql

sudo apt install mysql-server -y



