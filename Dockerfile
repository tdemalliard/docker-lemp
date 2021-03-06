#####################
### init
FROM tdemalliard/baseimage:0.9.16.0
MAINTAINER Thibault de Malliard <tdemalliard+docker@gmail.com>

##############################
### install the servers nginx, mariadb, php-fpm
# install php5-fpm and nginx
RUN DEBIAN_FRONTEND='noninteractive' \
    apt-get install -qy \
    php5 php5-cli \
    php5-mysql \
    php5-gd \
    php5-fpm \
    nginx

# install mariad
# touch file: workaround install bug
RUN mkdir -p /var/lib/mysql && \
    touch /var/lib/mysql/debian-5.5.flag && \
    DEBIAN_FRONTEND='noninteractive' \
    apt-get install -qy \
    mariadb-server

# workaround to run mysql: missing socket folder
RUN mkdir /run/mysqld && \
    chown mysql:root /run/mysqld

# install sendmail
RUN apt-get install -qy \
    sendmail && \
    sendmailconfig


################################
### Set config files and services for autorun
# install custom config files
ADD nginx.conf /etc/nginx/nginx.conf
ADD php-fpm.conf /etc/php5/fpm/php-fpm.conf
ADD www.conf /etc/php5/fpm/pool.d/www.conf

# install service files for runit
ADD mysqld.service /etc/service/mysqld/run
ADD php-fpm.service /etc/service/php-fpm/run
ADD nginx.service /etc/service/nginx/run
ADD sendmail.service /etc/service/sendmail/run

# sendmail allow www-data user to send mails
RUN sed -i 's/#Ft\/etc\/mail\/trusted-users/Ft\/etc\/mail\/trusted-users/' /etc/mail/submit.cf && \
    echo 'www-data' >> /etc/mail/trusted-users

#################################
### cleaning
RUN rm -rf /tmp/* && \
    apt-get clean -y

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
