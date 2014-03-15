# Convert www to non-www redirect 
server {

  listen 80;
  listen [::]:80;
  listen 443 ssl;
  listen [::]:443 ssl;

  # listen on the www host
  server_name www.phpexample.com;

  # SSL Settings
  #keepalive_timeout 70;
  #ssl_certificate      phpexample.com.crt;
  #ssl_certificate_key  phpexample.com.key;

  # and redirect to the non-www host (declared below)
  return 301 $scheme://phpexample.com$request_uri;

}

# Production environment
server {

  # for linux (http://www.techrepublic.com/article/take-advantage-of-tcp-ip-options-to-optimize-data-transmission/)
  #listen 80 deferred;
  #listen [::]:80 deferred;
  #listen 443 deferred ssl;
  #listen [::]:443 deferred ssl;
  # for FreeBSD (http://www.freebsd.org/cgi/man.cgi?accf_http)
  #listen 80 accept_filter=httpready;
  #listen [::]:80 accept_filter=httpready;
  #listen 443 accept_filter=httpready ssl;
  #listen [::]:443 accept_filter=httpready ssl;
  # for standard
  listen 80;
  listen [::]:80;
  listen 443 ssl;
  listen [::]:443 ssl;

  # The host name to respond to, map only the dev hostname to ip address on dev server
  server_name phpexample.com;

  # Path for static files
  root /www/phpexample;

  # Force SSL, if you need to support tunnelled ports, switch to $http_host (but HTTP 1.0 may not have the HOST header)
  #if ($ssl_protocol = "") {
  #  return 301 https://$server_name$request_uri;
  #}

  # SSL settings
  #keepalive_timeout 70;
  #ssl_certificate      phpexample.com.crt;
  #ssl_certificate_key  phpexample.com.key;

  # Index search file to serve if in a directory
  index index.php index.html index.htm;

  #Specify a charset
  charset utf-8;

  # Include the recommended base config
  include conf.d/expires.conf;
  include conf.d/cache-busting.conf;
  include conf.d/x-ua-compatible.conf;
  include conf.d/protect-system-files.conf;
  include conf.d/cache-file-descriptors.conf;
  include conf.d/cross-domain-fonts.conf;
  include conf.d/cross-domain-ajax.conf;
  include conf.d/buffers.conf;
  # Uncomment this to prevent mobile network providers from modifying your site 
  # include conf.d/no-transform.conf;

  # Removes the initial index or index.php
  # Changes example.com/index.php to example.com/
  # Changes example.com/index to example.com/
  if ($request_uri ~* ^(/index(.php)?)/?$) {
    rewrite ^(.*)$ / permanent;
  }

  # Removes the index method of every controller
  # Changes example.com/controller/index to example.com/lol
  # Changes example.com/controller/index/ to example.com/lol
  if ($request_uri ~* index/?$) {
    rewrite ^/(.*)/index/?$ /$1 permanent;
  }

  # Removes any trailing slashes from uris that are not directories
  # Changes example.com/controller/ to example.com/controller
  # Thus normalising the uris
  if (!-d $request_filename) {
    rewrite ^/(.+)/$ /$1 permanent;
  }

  # Send all requests that are not going to a file, directory or symlink to front controllers
  if (!-e $request_filename) {
    rewrite ^/(.*)$ /index.php?/$1 last;
  }
  
  # Fallback on front controller pattern if it cannot find files or directories matching the uri
  location / {
    try_files $uri $uri/ /index.php;
  }

  # Fast cgi to the PHP run time
  location ~* \.php$ {
    try_files $uri =404;
    include fastcgi_params;
    fastcgi_pass unix:/var/run/php5-fpm.sock;
    fastcgi_index index.php;
    fastcgi_intercept_errors on;
    fastcgi_hide_header x-powered-by;
  }

}

# Development environment
# If you're using SSL, the certificate will need to support "dev" or wildcard subdomains. Otherwise the dev server will be inaccessible.
# Another way would be to create your own development specific certificates.
server {

  # Listen parameters are unique to each directive, so the development environment will not have listen parameters
  listen 80;
  listen [::]:80;
  listen 443 ssl;
  listen [::]:443 ssl;

  # The host name to respond to, map only the dev hostname to ip address on dev server
  server_name dev.phpexample.com;

  # Path for static files
  root /www/phpexample;

  # Force SSL, we use $http_host as it can potentially contain the client's tunnelled port, which is often used in VMs for development
  #if ($ssl_protocol = "") {
  #  return 301 https://$http_host$request_uri;
  #}

  # SSL settings
  #keepalive_timeout 70;
  #ssl_certificate      phpexample.com.crt;
  #ssl_certificate_key  phpexample.com.key;

  # Index search file to serve if in a directory
  index index.php index.html index.htm;

  #Specify a charset
  charset utf-8;

  # Include the recommended base config
  include conf.d/expires.conf;
  include conf.d/cache-busting.conf;
  include conf.d/x-ua-compatible.conf;
  include conf.d/protect-system-files.conf;
  # Cache file descriptors has to be disabled in development to allow for immediate changes
  # include conf.d/cache-file-descriptors.conf;
  include conf.d/cross-domain-fonts.conf;
  include conf.d/cross-domain-ajax.conf;
  include conf.d/buffers.conf;
  # Uncomment this to prevent mobile network providers from modifying your site 
  # include conf.d/no-transform.conf;

  # Removes the initial index or index.php
  # Changes example.com/index.php to example.com/
  # Changes example.com/index to example.com/
  if ($request_uri ~* ^(/index(.php)?)/?$) {
    rewrite ^(.*)$ / permanent;
  }

  # Removes the index method of every controller
  # Changes example.com/controller/index to example.com/lol
  # Changes example.com/controller/index/ to example.com/lol
  if ($request_uri ~* index/?$) {
    rewrite ^/(.*)/index/?$ /$1 permanent;
  }

  # Removes any trailing slashes from uris that are not directories
  # Changes example.com/controller/ to example.com/controller
  # Thus normalising the uris
  if (!-d $request_filename) {
    rewrite ^/(.+)/$ /$1 permanent;
  }

  # Send all requests that are not going to a file, directory or symlink to front controllers
  if (!-e $request_filename) {
    rewrite ^/(.*)$ /index.php?/$1 last;
  }
  
  # Fallback on front controller pattern if it cannot find files or directories matching the uri
  location / {
    try_files $uri $uri/ /index.php;
  }

  # Fast cgi to the PHP run time
  location ~* \.php$ {
    try_files $uri =404;
    include fastcgi_params;
    fastcgi_pass unix:/var/run/php5-fpm.sock;
    fastcgi_index index.php;
    fastcgi_intercept_errors on;
    fastcgi_hide_header x-powered-by;
  }

}