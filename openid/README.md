# Setup

To try out OpenID based IDP with MinIO we need the following:

1. One or more OpenID based IDP providers - here we setup two Dex IDP services. Each of these IDPs use the same OpenLDAP based backend, and so will share the same set of users.
2. MinIO running and configured with each of these IDPs

## Run MinIO locally with a single OpenID provider

The OpenID provider may be configured as either a JWT claim based provider (by specifying `claim_name`) or as a role based provider (by specifying `role_policy`).

Only OpenID related configuration is specified here.

### Claim based provider configuration

Server env:
```shell
export MINIO_IDENTITY_OPENID_CONFIG_URL="http://localhost:5556/dex/.well-known/openid-configuration"
export MINIO_IDENTITY_OPENID_CLIENT_ID="minio-client-app"
export MINIO_IDENTITY_OPENID_CLIENT_SECRET="minio-client-app-secret"
export MINIO_IDENTITY_OPENID_CLAIM_NAME="groups"
export MINIO_IDENTITY_OPENID_SCOPES="openid,groups,email,profile"
export MINIO_IDENTITY_OPENID_REDIRECT_URI="http://127.0.0.1:10000/oauth_callback"
```

Equivalently configure with `mc`:
```shell
mc idp openid add myminio \
    config_url="http://localhost:5556/dex/.well-known/openid-configuration" \
    client_id="minio-client-app" \
    client_secret="minio-client-app-secret" \
    scopes="openid,groups,email,profile" \
    redirect_uri="http://127.0.0.1:10000/oauth_callback" \
    claim_name="groups"
```

### Role based provider configuration

Server env:
```shell
export MINIO_IDENTITY_OPENID_CONFIG_URL="http://localhost:5556/dex/.well-known/openid-configuration"
export MINIO_IDENTITY_OPENID_CLIENT_ID="minio-client-app"
export MINIO_IDENTITY_OPENID_CLIENT_SECRET="minio-client-app-secret"
export MINIO_IDENTITY_OPENID_ROLE_POLICY="consoleAdmin"
export MINIO_IDENTITY_OPENID_SCOPES="openid,groups,email,profile"
export MINIO_IDENTITY_OPENID_REDIRECT_URI="http://127.0.0.1:10000/oauth_callback"
```

Equivalently configure with `mc`:
```shell
mc idp openid add myminio \
    config_url="http://localhost:5556/dex/.well-known/openid-configuration" \
    client_id="minio-client-app" \
    client_secret="minio-client-app-secret" \
    scopes="openid,groups,email,profile" \
    redirect_uri="http://127.0.0.1:10000/oauth_callback" \
    role_policy="consoleAdmin"
```


## Run MinIO locally with a two OpenID providers

If running MinIO with multiple OpenID providers, at most one JWT claim based provider may be specified. The others must use role policy support. 

Here, both providers use role policy.

Run `make podman-run` to start multiple Dex servers as separate IDentity Providers (IDPs). Then start MinIO with:


### Setup with two role policy based OIDC providers

Server env:
```
export MINIO_IDENTITY_OPENID_CONFIG_URL="http://localhost:5556/dex/.well-known/openid-configuration"
export MINIO_IDENTITY_OPENID_CLIENT_ID="minio-client-app"
export MINIO_IDENTITY_OPENID_CLIENT_SECRET="minio-client-app-secret"
export MINIO_IDENTITY_OPENID_SCOPES="openid,groups,email,profile"
export MINIO_IDENTITY_OPENID_REDIRECT_URI="http://127.0.0.1:10000/oauth_callback"
export MINIO_IDENTITY_OPENID_ROLE_POLICY="consoleAdmin"
export MINIO_IDENTITY_OPENID_DISPLAY_NAME="Login via dex1"

export MINIO_IDENTITY_OPENID_CONFIG_URL_OIDC2="http://localhost:5557/dex/.well-known/openid-configuration"
export MINIO_IDENTITY_OPENID_CLIENT_ID_OIDC2="minio-client-app-2"
export MINIO_IDENTITY_OPENID_CLIENT_SECRET_OIDC2="minio-client-app-secret-2"
export MINIO_IDENTITY_OPENID_SCOPES_OIDC2="openid,groups,email,profile"
export MINIO_IDENTITY_OPENID_REDIRECT_URI_OIDC2="http://127.0.0.1:10000/oauth_callback"
export MINIO_IDENTITY_OPENID_ROLE_POLICY_OIDC2="readwrite"
export MINIO_IDENTITY_OPENID_DISPLAY_NAME_OIDC2="Login via dex2"
```

Equivalently configure with `mc`:
```
mc idp openid add myminio \
    config_url="http://localhost:5556/dex/.well-known/openid-configuration" \
    client_id="minio-client-app" \
    client_secret="minio-client-app-secret" \
    scopes="openid,groups,email,profile" \
    redirect_uri="http://127.0.0.1:10000/oauth_callback" \
    display_name="Login via dex1" \
    role_policy="consoleAdmin"

# For the second one the IDP configuration must have a name (here "oidc2")
mc idp openid add myminio oidc2 \
    config_url="http://localhost:5556/dex/.well-known/openid-configuration" \
    client_id="minio-client-app-2" \
    client_secret="minio-client-app-secret-2" \
    scopes="openid,groups,email,profile" \
    redirect_uri="http://127.0.0.1:10000/oauth_callback" \
    display_name="Login via dex2" \
    role_policy="readwrite"

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

