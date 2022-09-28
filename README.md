# Testing MinIO with external IDPs

## LDAP

Example LDAP setup is in `ldap/` directory.

## OpenID

Example OpenID setup is in `openid/` directory.

## Docker Compose file

Use docker-compose to run a setup with OpenID and MinIO, where MinIO nodes are load-balanced via Nginx.

For browser to work as expected, add the following lines to `/etc/hosts`:

``` text
# Added for testing minio and iam
127.0.0.1 dex
127.0.0.1 nginx
```
