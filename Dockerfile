FROM ubuntu:trusty
MAINTAINER Wayne Humphrey <wayne@humphrey.za.net>

# Install packages
ENV DEBIAN_FRONTEND noninteractive
ENV NOTVISIBLE "in users profile"

# Set the locale
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

RUN apt-get update && \
  apt-get -y install supervisor git apache2 libapache2-mod-php5 mysql-server php5-mysql pwgen php-apc php5-mcrypt php5-curl openssh-server && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
ADD start-apache.sh /etc/supervisor/start-apache.sh
ADD start-mysql.sh /etc/supervisor/start-mysql.sh
ADD init /init
ADD config-mysql.cnf /etc/mysql/conf.d/my.cnf
ADD config-apache.cnf /etc/apache2/sites-available/000-default.conf
ADD sv-apache.conf /etc/supervisor/conf.d/apache.conf
ADD sv-mysqld.conf /etc/supervisor/conf.d/mysqld.conf
RUN chmod 755 /init
RUN chmod 755 /etc/supervisor/*.sh

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD mysql_init.sh /mysql_init.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN rm -fr /var/www/html/* && git clone https://github.com/nitr8/hello-world-lamp.git /var/www/html/

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 25M
ENV PHP_POST_MAX_SIZE 25M

# SSH login fix
RUN mkdir /var/run/sshd
RUN echo 'root:toor' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo "export VISIBLE=now" >> /etc/profile

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql", "/var/www/html/" ]

EXPOSE 22 80 3306
CMD ["/init"]