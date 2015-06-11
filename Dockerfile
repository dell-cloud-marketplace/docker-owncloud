FROM dell/lamp-base:1.1
MAINTAINER Dell Cloud Market Place <Cloud_Marketplace@dell.com>

# Set environment variable for package install
ENV DEBIAN_FRONTEND noninteractive

# Install OwnCloud dependencies
RUN apt-get update && apt-get install -yq \
	php5 \
        php5-curl \
        php5-gd \
        php5-json \
        php5-imagick \
        php5-intl \
        php5-mcrypt \
	php-xml-parser \
        wget

# Clean package cache
RUN apt-get -y clean && rm -rf /var/lib/apt/lists/*

# Remove any pre-installed applications
# and get the ownCloud files
RUN rm -fr /var/www/html/* && \
    wget https://download.owncloud.org/community/owncloud-8.0.2.tar.bz2 && \
    tar -xvf owncloud-8.0.2.tar.bz2 && \
    rm owncloud-8.0.2.tar.bz2

# Add scripts and make them executable.
COPY run.sh /run.sh
RUN chmod +x /*.sh

# Add volumes for MySQL and the application
VOLUME ["/var/lib/mysql", "/var/www/html"]

EXPOSE 80 443 3306

CMD ["/run.sh"]
