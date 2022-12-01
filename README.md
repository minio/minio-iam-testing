# Testing MinIO with external IDPs

This setup can be used to test MinIO integration with LDAP and OpenID based IDentity Providers (IDPs). It is used for developing as well as testing in CI.

## Setup

The setup in this repo starts an OpenLDAP based LDAP directory service, and two Dex IDP based OpenID authorization services. All these services run inside containers. The containers can be launched with both Docker and Podman:

``` sh
# To use with Docker:
make docker-run

# To use with Podman:
make podman-run
```

Run MinIO with something like:

``` sh
minio server --console-address :10000 /mnt/disks{1...4}
```

(running the MinIO console on port 10000 is assumed in the all the docs here)

## LDAP IDP Testing Quickstart

Initial data populated in the LDAP server is present in the `ldap/bootstrap.ldif` file in this repo. It creates a LDAP hierachy with dummy data. In this dataset, each user's password is same as their `uid` value. For example, the password for `uid=bobfisher,ou=people,ou=hwengg,dc=min,dc=io` is just `bobfisher`.

As an example, for the user "Dillon Harper", the login username (used in MinIO) is `dillon` and the password is `dillon`.

Once the IDP container is running, and MinIO is running and configured with `mc` as `myminio`, configure LDAP IDP in MinIO with:

``` sh
mc admin idp ldap add myminio \
    server_addr=localhost:1389 \
    server_insecure=on \
    lookup_bind_dn=cd=admin,dc=min,dc=io \
    lookup_bind_password=admin \
    user_dn_search_base_dn=dc=min,dc=io \
    user_dn_search_filter="(uid=%s)" \
    group_dn_search_base_dn=ou=swengg,dc=min,dc=io \
    group_search_filter="(&(objectclass=groupOfNames)(member=%d))"
```

You should be able to now login via the MinIO Console, however, if no access policy is configured on the user an error will be returned.

Access policy may be configured on either the user's DN or on a group's DN (they must be a member of the group!) via `mc admin policy set` command.

## OpenID IDP Testing Quickstart

Since MinIO supports using multiple OpenID based IDPs simultaneously, the setup here starts two Dex IDP instances - they are considered as separate IDPs by MinIO. The Dex IDP here use the OpenLDAP service as a backend, so the same set of users (as the LDAP IDP) are authenticated by the Dex IDPs. The user ID for each Dex IDP is the `mail` field in the `ldap/bootstrap.ldif` file and the password is the same as the `uid` field.

As an example, for the user "Dillon Harper", the Dex IDP username is `dillon@example.io` and the password is `dillon`.

Once the IDP containers are running, and MinIO is running and configured with `mc` as `myminio`, configure both the Dex IDPs in MinIO with:

```sh
mc admin idp openid add myminio \
    config_url="http://localhost:5556/dex/.well-known/openid-configuration" \
    client_id="minio-client-app" \
    client_secret="minio-client-app-secret" \
    scopes="openid,groups" \
    redirect_uri="http://127.0.0.1:10000/oauth_callback" \
    display_name="Login via dex1" \
    role_policy="consoleAdmin"

# For the second one the IDP configuration must have a name (here "oidc2")
mc admin idp openid add myminio oidc2 \
    config_url="http://localhost:5557/dex/.well-known/openid-configuration" \
    client_id="minio-client-app-2" \
    client_secret="minio-client-app-secret-2" \
    scopes="openid,groups" \
    redirect_uri="http://127.0.0.1:10000/oauth_callback" \
    display_name="Login via dex2" \
    role_policy="readwrite"

```

You should now be able to login via either IDP in the MinIO Console now.


## Docker Compose file

Use docker-compose to run a setup with OpenID and MinIO, where MinIO nodes are load-balanced via Nginx. This setup may be useful for some advanced testing/debugging.

For browser to work as expected, add the following lines to `/etc/hosts`:

``` text
# Added for testing minio and iam
127.0.0.1 dex
127.0.0.1 nginx
```
