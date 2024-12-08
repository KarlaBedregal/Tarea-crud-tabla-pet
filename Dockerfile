# Usa una imagen base de Debian
FROM debian:bullseye

# Actualiza los paquetes e instala Apache, Perl, MySQL y módulos necesarios
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-perl2 \
    perl \
    mysql-server \
    libdbi-perl \
    libdbd-mysql-perl \
    libjson-perl \
    curl \
    wget \
    && apt-get clean

# Habilita el módulo CGI de Apache
RUN a2enmod cgi

# Configura el directorio de scripts CGI
RUN mkdir -p /usr/lib/cgi-bin/karla1
COPY cgi-bin/ /usr/lib/cgi-bin/karla1/
RUN chmod -R 755 /usr/lib/cgi-bin/karla1/

# Configura Apache para usar el directorio CGI
RUN echo "<VirtualHost *:80>
    DocumentRoot /var/www/html
    ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
    <Directory /usr/lib/cgi-bin/>
        Options +ExecCGI
        AddHandler cgi-script .cgi .pl
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/000-default.conf

# Expone el puerto 80
EXPOSE 80

# Inicia Apache
CMD ["apachectl", "-D", "FOREGROUND"]

