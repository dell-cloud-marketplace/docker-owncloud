FROM dell/lamp-base:1.0
MAINTAINER Dell Cloud Market Place <Cloud_Marketplace@dell.com>

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Do an update of the base packages.
RUN apt-get update

# Install Owncloud dependencies 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install wget 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-gd 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-json 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-curl 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-intl 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-mcrypt 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-imagick

# Remove any pre-installed applications
RUN rm -fr /var/www/html/*

# Get the Owncloud files
RUN wget https://download.owncloud.org/community/owncloud-7.0.3.tar.bz2
RUN tar -xvf owncloud-7.0.3.tar.bz2
RUN rm owncloud-7.0.3.tar.bz2

# Add scripts and make them executable.
ADD run.sh /run.sh
RUN chmod +x /*.sh

# Add volumes for MySQL and the application
VOLUME ["/var/lib/mysql", "/var/www/html"]

EXPOSE 80 443 3306

CMD ["/run.sh"]
