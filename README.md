# docker-owncloud

This image installs [ownCloud](https://owncloud.org), an enterprise file sharing solution for online collaboration.

## Components

The stack comprises the following components (some are obtained through [docker-lamp-base](https://github.com/dell-cloud-marketplace/docker-lamp-base)):

Name       | Version                   | Description
-----------|---------------------------|------------------------------
ownCloud   | 8.0.2                     | File sharing platform
Ubuntu     | see [docker-lamp-base](https://github.com/dell-cloud-marketplace/docker-lamp-base) | Operating system
MySQL      | see [docker-lamp-base](https://github.com/dell-cloud-marketplace/docker-lamp-base) | Database
Apache     | see [docker-lamp-base](https://github.com/dell-cloud-marketplace/docker-lamp-base) | Web server
PHP        | see [docker-lamp-base](https://github.com/dell-cloud-marketplace/docker-lamp-base) | Scripting language

## Usage

### 1. Start the Container

#### A. Basic Usage

Start your container with:

* Ports 80, 443 (Apache Web Server) and 3306 (MySQL) exposed
* A named container (**owncloud**)
* A predefined hostname for the ownCloud container. Make sure to pass the -h option to Docker run with your FQDN if you want webdav to work.

As follows: 

```no-highlight
sudo docker run -d --name="owncloud" \
                -p 80:80 -p 443:443 \
                -p 3306:3306 \
                -h "my.domain.com" dell/owncloud
```

#### B. Advanced Usage

Start your container with:

* Ports 80, 443 (Apache Web Server) and 3306 (MySQL) exposed
* A named container (**owncloud**)
* A predefined password for the MySQL **admin** user
* A predefined hostname for the ownCloud container. Make sure to pass the -h option to Docker run with your FQDN if you want webdav to work.
* Two data volumes (which will survive a restart or recreation of the container). The MySQL data is available in **/data/mysql** on the host. The PHP application files are available in **/app** on the host

```no-highlight
sudo docker run -d \
    -p 80:80 \
    -p 443:443 \
    -p 3306:3306 \
    -v /app:/var/www/html \
    -v /data/mysql:/var/lib/mysql \
    -e MYSQL_PASS="password"  \
    -h "my.domain.com" \
    --name owncloud \
    dell/owncloud
```


### 2. Check the Log Files

If you haven't defined a MySQL password, the container will generate a random one. Check the logs for the password by running: 

     sudo docker logs owncloud
     
You will see output like the following:     

```no-highlight
========================================================================
You can now connect to this MySQL Server using:

    mysql -uadmin -pMYHU4RejDh0q -h<host> -P<port>

Please remember to change the above password as soon as possible!
MySQL user 'root' has no password but only allows local connections
========================================================================
=> Waiting for confirmation of MySQL service startup
========================================================================

MySQL owncloud user password: ooVoh7aedael

========================================================================
```

Make a secure note of:

* The admin user password (in this case **MYHU4RejDh0q**)
* The owncloud user password (in this case **ooVoh7aedael**)

Next, test the **admin** user connection to MySQL:

```no-highlight
mysql -uadmin -pMYHU4RejDh0q -h127.0.0.1 -P3306
```     

### 3. Configure Owncloud
Access the container from your browser:

```no-highlight
http://<container hostname> 
```

OR
```no-highlight
https://<container hostname>
```
 **NOTE:** Make sure you use the final hostname/FQDN you passed in your docker run command when connecting and doing the initial configuration. ownCloud will take the URL used to access the Installation Wizard and insert it into the config.php file in the 'trusted_domains' setting. After the configuration, users will only be able to log into ownCloud when they point their browsers to a domain name listed in the 'trusted_domains' setting. An IPv4 address can be specified instead of a domain name.

**We strongly recommend that you connect via HTTPS**, for this step, and all subsequent administrative tasks, if the container is running outside your local machine (e.g. in the Cloud). Your browser will warn you that the certificate is not trusted. If you are unclear about how to proceed, please consult your browser's documentation on how to accept the certificate.
     


#### Welcome to ownCloud's configuration wizard!
- First, create a new administrator user. Fill in a user login and password.
- Below, click on **Storage & database**.
- Keep the default data folder (**/var/www/html/data**).
- Select MariaDB/MySQL as database.
- Fill in MySQL database information:
    - Database user: **owncloud**
    - Database password: *The ownCloud password read from the logs*
    - Database name: **owncloud**
    - Host: **localhost**

Then press **Finish setup**.


## Reference

### How to use ownCloud Web console

Refer to the ownCloud documentation to access your files using the web interface:
[Accessing files with web console](http://doc.owncloud.org/server/7.0/user_manual/files/filesweb.html)

### Accessing ownCloud files with WebDav

You can also access your files with WebDav by mounting your file system as described below:
#### 1. Install the WebDAV support using the davfs package
  
    sudo apt-get install davfs2
     
#### 2. Reconfigure davfs2 to allow access to normal users (select Yes when prompted):

    sudo dpkg-reconfigure davfs2

#### 3. Specify any users that you want to have mount and share privileges in the davfs2 group:

    sudo usermod -aG davfs2 <user>

#### 4. Edit the /etc/fstab file and add the following line for each user for whom you want to give mount privileges for the folder:
     
     my.domain.com/remote.php/webdav /home/<user>/owncloud davfs user,rw,noauto 0 0

For each user for whom you want to give mount privileges:
- Create the folders ```owncloud/``` and ```.davfs2/``` in the **user** directory as follows:

```no-highlight     
     sudo mkdir /home/<user>/owncloud
     sudo mkdir /home/<user>/.davfs2
```

- Create the file ```secrets``` inside the ```.davfs2/``` folder and populate it with your ownCloud login credentials:
  
```no-highlight    
     my.domain.com/remote.php/webdav <username> <password>
```

#### 5. Ensure that the file is writable by only you by using the file manager or by issuing the following command:

    chmod 600 ~/.davfs2/secrets
    
#### 6. Run the following command:    

    mount ~/owncloud
    
You should be able to access your files through the ```~/owncloud``` mounting point  

For more information on how to access your ownCloud files using WebDav:
[Accessing files using WebDav](http://doc.owncloud.org/server/7.0/user_manual/files/files.html)

### Image Details

Inspired by [yankcrime/dockerfiles](https://github.com/yankcrime/dockerfiles.git)

Pre-built Image | [https://registry.hub.docker.com/u/dell/owncloud](https://registry.hub.docker.com/u/dell/owncloud) 
     
