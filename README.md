### L A M P S T A C K en UBUNTU 
Para esta práctica hay que realizar principalmente la instalación de la pila **LAMP** (Linux, Apache, MySQL, PHP.)    
El proceso se hará de forma automatizada mediante 2 scripts: uno de ellos será utilizado para la instalación de la pila **LAMP** y el otro para la implantación de ciertas herramientas webs como phpmyadmin y adicionales.

## 1. Inicial:

Primeramente empezaré configurando dentro de la una carpeta llamada *Scripts*, 2 archivos **.sh** el primero será donde se realizará lo que concierne a la instalación de la pila **LAMP** (install_lamp.sh) y el segundo para el agregado de ciertas *tools* (installtools.sh).

![](images/scripts.png)

### 1.1 Configuraciones iniciales:

#### Mostrar comandos:
Este comando incialmente se ejecutará para mostrar los comandos por si surgiera algún error con alguno:
```
set -x
```

#### Actualización de paquetes y repositorios:

Con el siguiente comando podemos realizar la actualización de la lista de paquetes:
```
apt update
```
Por el contrario este otro trae nuevas versiones a los paquetes ya instalados:
```
apt upgrade
```
## 2. Implantación de la pila:

### 2.1 Instalación de APACHE:

Empleando este comando pasaré con la instalación de apache, y el parámetro **-y** es para que no salga la pregunta de confirmación:

```
apt install apache2 -y
```
### 2.2 Instalación de MySQL:

Empleando este comando pasaré con la instalación de MySQL, y el parámetro **-y** es para que no salga la pregunta de confirmación:
```
apt install mysql-server -y
```
### 2.3 Instalación de PHP:

Empleando este comando pasaré con la instalación de PHP, junto a 2 módulos **libapache2-mod-php** para el servidor web de apache y **php-mysql** que enlaza php junto a mysql,  y el parámetro **-y** es para que no salga la pregunta de confirmación:

```
apt install php libapache2-mod-php php-mysql -y
```
### 2.4 Archivo de configuración de apache:

En esta parte de aquí bajo la carpeta *conf*, podemos tener creado un archivo **000-default.conf** donde tengamos implementada la configuración del VirtualHost del servidor web:

![](images/conf.png)

y en nuestro script de automatización podemos emplear el comando **cp** para copiar hacia la ruta donde apache tiene los servidores webs **no activos**, automatizando de este modo la tarea:

```
cp ../conf/000-default.conf /etc/apache2/sites-available 
```

tras ello podemos realizar un reinicio del servicio:

```
systemctl restart apache2
```

### 2.5 Modificación de grupo y propietario:

Como incialemente puede estar perteneciendo a **root**, de la ruta **/var/www/html**, (que es la carpeta predeterminada raíz para el servidor web donde se alojan las páginas) cambiamos al **propietario** y **grupo** al de apache con el siguiente comando:

```
chown -R www-data:www-data /var/www/html
```
## 3. Configuración de las tools:

### 3.1 ¿Cómo podríamos automatizar la instalación de phpmyadmin desde un script de Bash?

Para no tener que estar seleccionando de forma manual las opciones al  podemos emplear ciertos comandos dentro del script **installtools.sh** para ello se emplea lo siguiente:

El siguiente comando le dice que seleccione **apache** en la elección del servidor web, para ello se hace uso de  **debconf-set-selections** para automatizar nuestra respuesta.
```
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
```

El siguiente comando automatiza el valor booleano de elección, en este caso true para utilizar **dbconfig-common** para configurar la base de datos de phpmyadmin:

```
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
```
### 3.2 Configuración automatizada de las credenciales de phpmyadmin
 
 Para no tener que estar introduciendo nuestro usuario y contraseña durante la propia instalación, podemos meter dentro de nuestra carpeta de *Scripts* un archivo **.env** (que permanece oculto), donde asignemos las variables para el **usuario** y **contraseña**, y las **credenciales** para acceder **via web** al phpmyadmin:

![](images/.env.png)

![](images/credenciales.png)

y desde el propio script llamaremos a las variables usando la herramienta **debconf-set-selections** para automatizar la respuesta de introducción y confirmación de la contraseña:

```
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
```
```
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
```
### 3.3 Instalación de phpmyadmin

Una vez hecha la configuración previa se puede pasar con la instalación ya automatizada de phpmyadmin junto a ciertos componentes:

```
apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl
```



### 3.4 Configuración de acceso automatizado de usuario a las bases de datos

En estaa parte de aquí llamaremos a la **variable** perteneciente al **usuario** del archivo **.env**
para crear de forma automatizada uno que tenga acceso a todas las tablas de todas las bases de datos.

Este primer comando redirige la orden de borrar el usuario de nuestra variable en caso de que exista para que no de conflicto cada vez que se ejecuta el script:

```
mysql -u root <<< "DROP USER IF EXISTS '$APP_USER'@'%'"
```
Luego se realiza la creación del usuario, pudiendo conectarse de forma remota, identificandolo con su contraseña:
```
mysql -u root <<< "CREATE USER '$APP_USER'@'%' IDENTIFIED BY '$APP_PASSWD';"
```
Luego se le otorga al usuario todos los permisos a todas las tablas de todas las bases de datos:
```
mysql -u root <<<  "GRANT ALL PRIVILEGES ON *.* TO '$APP_USER'@'%'";
```

### 3.4 Instalación de ADMINER

En esta parte se implementa Adminer como alternativa al phpmyadmin para acceder al mysql, lo que se hará primeramente es crear su directorio en la ruta **/var/www/html**

Con el parámetro **-p**  indica que cree el directorio en caso de que no existe, pero si existe no ocurre ningún error:
```
mkdir -p /var/www/html/adminer
```
Luego podemos descargar el archivo de Adminer sobre la ruta indicada:

```
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer
```

Podemos pasar renombrar el archivo **.php** que arroja:
```
mv /var/www/html/adminer/adminer-4.8.1-mysql.php /var/www/html/adminer/index.php
```

Seguidamente se pasa a cambiar el **propietario** y **grupo** para el **usuario de apache**:

```
chown -R www-data:www-data /var/www/html
```
### 3.5 Instalación y configuración de GoAcess

Con el siguiente comando se procede con la instalación:

```
apt install goaccess -y
```

Creamos un directorio para los informes html GoAccess:

```
mkdir -p /var/www/html/stats
```
Para generar un archivo index.html en la ruta **/var/www/html/stats/** con la **información de log** en **tiempo real** podemos usar el siguiente comando, agregando **--real-time-html** ya que de lo contrario solo genera archivos html estáticos de un momento determinado, la opción **--daemonize** lo crea en segundo plano para liberar a la terminal:

```
goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html --daemonize
```

***NOTA***:
``Para que genere los archivos html en tiempo real hay que abrir el puerto 7890.``

### 3.6 Autenticación de GoAcess

Mediante el siguiente comando se realiza la creación del archivo **.htpasswd** donde se guarda la **contraseña cifrada del usuario** para el **usuario** que se le indica mediante la llamada de la variable, asi como la llamada a la variable de la **contraseña** para autenticarte en el directorio.

Podemos meter dichas variables en el archivo **.env** del directorio de *Scripts*

![](images/statsvar.png)

el parámetro **-b** permite utilizar el comando en un script de bash

```
htpasswd -bc /etc/apache2/.htpasswd $STATS_USERNAME $STATS_PASSWORD`
```
Seguidamente, el directorio *.conf* podemos  crear un segundo archivo de configuración para el stats

![](images/confstats.png)

Y mediante este comando de forma automatizada podemos estar copiando con un nombre distinto nuestro archivo de configuración con el nombre **000-default.conf** para que lo detecte apache con el nombre por defecto que tiene ese archivo:

Internamente el archivo está puesto de esta forma:

![](images/vhost_stast.png)



```
cp ../conf/000-default-stats.conf /etc/apache2/sites-available/000-default.conf
```

Después sería conveniente reinciar:

```
systemctl restart apache2
```

