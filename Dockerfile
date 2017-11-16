FROM bitnami/php-fpm:5.6
MAINTAINER Zetanova <office@zetanova.eu>


ENV REDIS_VERSION=3.1.1 \
	EXTENSION_DIR="/opt/bitnami/php/lib/php/extensions" \
	DEBIAN_FRONTEND=noninteractive
	
#change source 
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo "deb http://mirrors.163.com/debian/ jessie main non-free contrib" >/etc/apt/sources.list && \
    echo "deb http://mirrors.163.com/debian/ jessie-proposed-updates main non-free contrib" >>/etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/debian/ jessie main non-free contrib" >>/etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/debian/ jessie-proposed-updates main non-free contrib" >>/etc/apt/sources.list
	
#INIT
RUN pecl channel-update pecl.php.net \
	&& pecl config-set ext_dir $EXTENSION_DIR \
	&& pear config-set ext_dir $EXTENSION_DIR
#todo fix set extension_dir of pho-config

#Install redis pecl
#until fix extension_dir of pho-config 
#RUN apt-get install -yqq autoconf build-essential
#RUN pecl install -f redis-3.1.1 

#Install redis source
RUN apt-get update \
	&& apt-get -yqq install autoconf wget build-essential \
	&& mkdir -p /tmp/php-redis \
	&& cd /tmp/php-redis \
	&& wget https://pecl.php.net/get/redis-$REDIS_VERSION.tgz \
	&& tar -xzf redis-$REDIS_VERSION.tgz --strip=1 \
	&& phpize \
	&& ./configure \
	&& make \
	&& mv modules/* $EXTENSION_DIR \
	&& cd / \
	&& rm -dR /tmp/php-redis \
	&& apt-get remove -yqq autoconf wget build-essential \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


echo "extension=redis.so" >> /bitnami/php/conf/php.ini
    
#cleanup
#RUN apt-get remove -yqq autoconf wget python-setuptools build-essential \
#	&& apt-get autoremove -y \
#	&& apt-get clean \
#	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
	
ENV DEBIAN_FRONTEND teletype

WORKDIR /app/
