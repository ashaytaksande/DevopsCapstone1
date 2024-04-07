From hshar/webapp
Run apt update && apt install apache2 -y
Copy ./ /var/www/html/
ENTRYPOINT [ "apachectl", "-D", "FOREGROUND" ]
