# Setup dex IDP with LDAP connector

## Pre-requisite

Create a pod for running the containers:
```shell
podman pod create --name mypod -p 1389:389 -p 1636:636 -p 5556:5556
podman pod start mypod
```

First start OpenLDAP container with example data. From the current directory, run:

```shell
podman run \
    --env LDAP_ORGANIZATION="MinIO Inc." \
    --env LDAP_DOMAIN="min.io" \
    --env LDAP_ADMIN_PASSWORD="admin" \
    --name openldap \
    --pod mypod \
    --detach \
    quay.io/minio/openldap --copy-service

# OR build locally and run with:

cd ../ldap
podman build -t ldap-test .
podman run \
    --env LDAP_ORGANIZATION="MinIO Inc." \
    --env LDAP_DOMAIN="min.io" \
    --env LDAP_ADMIN_PASSWORD="admin" \
    --volume $PWD/bootstrap.ldif:/container/service/slapd/assets/config/bootstrap/ldif/50-bootstrap.ldif \
    --name openldap \
    --pod mypod \
    --detach \
    ldap-test --copy-service


```

Next build and run the OpenID container:

```shell
podman build -t openid-test .
podman run -it \
    --name openid \
    --pod mypod \
    openid-test

```

Run MinIO locally:

```shell
export MINIO_IDENTITY_OPENID_CONFIG_URL="http://localhost:5556/dex/.well-known/openid-configuration"
export MINIO_IDENTITY_OPENID_CLIENT_ID="minio-client-app"
export MINIO_IDENTITY_OPENID_CLIENT_SECRET="minio-client-app-secret"
export MINIO_IDENTITY_OPENID_CLAIM_NAME="groups"
export MINIO_IDENTITY_OPENID_SCOPES="openid,groups"
export MINIO_IDENTITY_OPENID_REDIRECT_URI="http://127.0.0.1:10000/oauth_callback"

export MINIO_ROOT_USER=minio
export MINIO_ROOT_PASSWORD=minio123

./minio server --console-address ":10000" /tmp/disk
```
