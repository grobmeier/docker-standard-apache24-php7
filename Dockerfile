FROM debian:9

RUN apt-get update
RUN apt-get install -y wget curl apache2 unzip vim gnupg

# Adding dotdeb for Jessie:
# See: https://www.dotdeb.org/instructions/

RUN echo 'deb http://packages.dotdeb.org stretch all' > /etc/apt/sources.list.d/dotdeb.list

## add dotdeb key for apt
RUN curl http://www.dotdeb.org/dotdeb.gpg | apt-key add -

RUN apt-get update

RUN apt-get install -y php7.0 php7.0-curl php7.0-gd php7.0-mbstring php7.0-imagick php7.0-mysql php7.0-xdebug php7.0-simplexml php7.0-zip

#configure apache
RUN ["bin/bash", "-c", "sed -i 's/AllowOverride None/AllowOverride All\\nSetEnvIf X-Forwarded-Proto https HTTPS=on/g' /etc/apache2/apache2.conf"]

RUN service apache2 restart

# Configure php
RUN ["bin/bash", "-c", "sed -i 's/max_execution_time\\s*=.*/max_execution_time=180/g' /etc/php/7*/apache2/php.ini"]
RUN ["bin/bash", "-c", "sed -i 's/upload_max_filesize\\s*=.*/upload_max_filesize=16M/g' /etc/php/7*/apache2/php.ini"]
RUN ["bin/bash", "-c", "sed -i 's/memory_limit\\s*=.*/memory_limit=256M/g' /etc/php/7*/apache2/php.ini"]
RUN ["bin/bash", "-c", "sed -i 's/post_max_size\\s*=.*/post_max_size=20M/g' /etc/php/7*/apache2/php.ini"]

# Configure XDebug
RUN ["bin/bash", "-c", "echo [XDebug] >> /etc/php/7*/apache2/php.ini"]
RUN ["bin/bash", "-c", "echo xdebug.remote_enable=1 >> /etc/php/7*/apache2/php.ini"]
RUN ["bin/bash", "-c", "echo xdebug.remote_connect_back=1 >> /etc/php/7*/apache2/php.ini"]
RUN ["bin/bash", "-c", "echo xdebug.idekey=netbeans-xdebug >> /etc/php/7*/apache2/php.ini"]

# Configure apache
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod proxy
RUN a2enmod headers

# enable ssl on apache
RUN a2ensite default-ssl
RUN chown -R www-data:www-data /var/www
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
RUN service apache2 restart

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]