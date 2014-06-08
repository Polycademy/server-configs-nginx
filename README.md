WebserverConfiguration
======================

Web server configuration for Apache (via .htaccess), NGINX and Mongrel 2.

Apache's .htaccess is a bit more flexible, however it is not as high performance as NGINX as Apache needs to read each .htaccess file. NGINX has the advantage of a much more elegant syntax, making it actually far easier to learn how to use. Mongrel 2 is probably the most interesting, use it for high scalability and high availability SOA that uses ZMQ as an internal communication protocol.

These configuration files are based off the H5BP project, however they have been enhanced to be a bit more opinionated for Polycademy's usage.

The NGINX and Mongrel 2 files are updated more often than Apache.

TODO:
----

1. NGINX WebSockets support http://siriux.net/2013/06/nginx-and-websockets/ (this is just a proxy form, we need to have separate file examples)
4. Opcode Cache Issue (Capistrano + Rocketeer) https://github.com/zendtech/ZendOptimizerPlus/issues/126#issuecomment-24020445
5. NGINX non-root user https://www.exratione.com/2014/03/running-nginx-as-a-non-root-user/
7. How to redirect any mention of index.php to non index.php routes. Such as http://e.com/index.php/blah to http://e.com/blah. To force an external rewrite, we have to do a redirect.
8. Add proxy and uwsgi styles to NGINX.
9. NGINX Cache Busting is not working. (rebuild NGINX from source)