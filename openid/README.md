# Setup dex IDP with LDAP connector

The container image runs Dex as the OpenID provider with user data from an OpenLDAP server.

See the Makefile to start the Dex and OpenLDAP containers.

Run MinIO locally:

```shell
export MINIO_IDENTITY_OPENID_CONFIG_URL="http://localhost:5556/dex/.well-known/openid-configuration"
export MINIO_IDENTITY_OPENID_CLIENT_ID="minio-client-app"
export MINIO_IDENTITY_OPENID_CLIENT_SECRET="minio-client-app-secret"
# export MINIO_IDENTITY_OPENID_CLAIM_NAME="groups"
export MINIO_IDENTITY_OPENID_SCOPES="openid,groups"
export MINIO_IDENTITY_OPENID_REDIRECT_URI="http://127.0.0.1:10000/oauth_callback"
# role policy if desired:
export MINIO_IDENTITY_OPENID_ROLE_POLICY="consoleAdmin"

export MINIO_ROOT_USER=minio
export MINIO_ROOT_PASSWORD=minio123

# OR
mc admin config set myminio identity_openid \
    config_url="http://localhost:5556/dex/.well-known/openid-configuration" \
    client_id="minio-client-app" \
    client_secret="minio-client-app-secret" \
    scopes="openid,groups" \
    redirect_uri="http://127.0.0.1:10000/oauth_callback" \
    role_policy="consoleAdmin"

# OR
mc admin config set myminio identity_openid:dextest \
    config_url="http://localhost:5556/dex/.well-known/openid-configuration" \
    client_id="minio-client-app" \
    client_secret="minio-client-app-secret" \
    scopes="openid,groups" \
    redirect_uri="http://127.0.0.1:10000/oauth_callback" \
    role_policy="consoleAdmin"



./minio server --console-address ":10000" /tmp/disk
```

## Running MinIO with multiple OIDC providers

Run `make podman-run` to start multiple Dex servers as separate IDentity Providers (IDPs). Then start MinIO with:

```
# With multiple OIDC IDPs only role policies are supported.

export MINIO_IDENTITY_OPENID_CONFIG_URL="http://localhost:5556/dex/.well-known/openid-configuration"
export MINIO_IDENTITY_OPENID_CLIENT_ID="minio-client-app"
export MINIO_IDENTITY_OPENID_CLIENT_SECRET="minio-client-app-secret"
export MINIO_IDENTITY_OPENID_SCOPES="openid,groups"
export MINIO_IDENTITY_OPENID_REDIRECT_URI="http://127.0.0.1:10000/oauth_callback"
export MINIO_IDENTITY_OPENID_ROLE_POLICY="consoleAdmin"

export MINIO_IDENTITY_OPENID_CONFIG_URL_OIDC2="http://localhost:5557/dex/.well-known/openid-configuration"
export MINIO_IDENTITY_OPENID_CLIENT_ID_OIDC2="minio-client-app-2"
export MINIO_IDENTITY_OPENID_CLIENT_SECRET_OIDC2="minio-client-app-secret-2"
export MINIO_IDENTITY_OPENID_SCOPES_OIDC2="openid,groups"
export MINIO_IDENTITY_OPENID_REDIRECT_URI_OIDC2="http://127.0.0.1:10000/oauth_callback"
export MINIO_IDENTITY_OPENID_ROLE_POLICY_OIDC2="readwrite"

export MINIO_ROOT_USER=minio
export MINIO_ROOT_PASSWORD=minio123

./minio server --console-address ":10000" /tmp/disk
```

The server will now print two ARNs and both may be used to generate STS credentials.

## Changing the LDAP server address

This may be needed if the LDAP server is not running at `locahost:389` for the Dex container.

Add the following environment as a command line option when starting the container:


```
--env DEX_LDAP_SERVER="localhost:SOME-PORT"
```

Replace `SOME-PORT` appropriately.

## Changing the allowed redirect URI in the Dex container

This may be needed if your MinIO server's console port is not 10000.

```
--env DEX_CLIENT_REDIRECT_URI="http://127.0.0.1:SOME-PORT/oauth_callback"
```

Replace `SOME-PORT` appropriately.

