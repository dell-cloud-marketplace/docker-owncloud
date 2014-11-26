FROM dell/lamp-base:1.0
MAINTAINER Dell Cloud Market Place <Cloud_Marketplace@dell.com>

# Set environment variable for package install
ENV DEBIAN_FRONTEND noninteractive

# Do an update of the base packages.
RUN apt-get update

# Install OwnCloud dependencies
RUN apt-get update && \
    apt-get -y install wget \
        php5 \
        php5-gd \
        php5-json \
        php5-curl \
        php5-intl \
        php5-mcrypt \
        php5-imagick

# Ensure UTF-8
RUN locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    export LC_ALL=en_US.UTF-8 && \
    export LANGUAGE=en_US.UTF-8 && \
    export LANG=en_US.UTF-8

# Remove any pre-installed applications
# and get the ownCloud files
RUN rm -fr /var/www/html/* && \
    wget https://download.owncloud.org/community/owncloud-7.0.3.tar.bz2 && \
    tar -xvf owncloud-7.0.3.tar.bz2 && \
    rm owncloud-7.0.3.tar.bz2

# Add scripts and make them executable.
ADD run.sh /run.sh
RUN chmod +x /*.sh

# Add volumes for MySQL and the application
VOLUME ["/var/lib/mysql", "/var/www/html"]

EXPOSE 80 443 3306

CMD ["/run.sh"]
