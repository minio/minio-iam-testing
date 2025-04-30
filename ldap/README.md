### Testing MinIO LDAP feature with OpenLDAP container

The image provided by https://github.com/osixia/docker-openldap is being used here.

Initial data for populating the LDAP server is present in the `bootstrap.ldif` file in this repo. It creates a LDAP hierarchy with dummy data. In this dataset, each user's password is same as their `uid` value. For example, the password for `uid=bobfisher,ou=people,ou=hwengg,dc=min,dc=io` is just `bobfisher`.

See the Makefile to run the containers with either docker or podman.

In another terminal start the MinIO server locally configured with the above LDAP server:

```
export MINIO_IDENTITY_LDAP_SERVER_ADDR=localhost:389
export MINIO_IDENTITY_LDAP_SERVER_INSECURE=on
export MINIO_IDENTITY_LDAP_LOOKUP_BIND_DN=cn=admin,dc=min,dc=io
export MINIO_IDENTITY_LDAP_LOOKUP_BIND_PASSWORD=admin
export MINIO_IDENTITY_LDAP_USER_DN_SEARCH_BASE_DN=dc=min,dc=io
export MINIO_IDENTITY_LDAP_USER_DN_SEARCH_FILTER="(uid=%s)"
export MINIO_IDENTITY_LDAP_GROUP_SEARCH_BASE_DN=ou=swengg,dc=min,dc=io
export MINIO_IDENTITY_LDAP_GROUP_SEARCH_FILTER="(&(objectclass=groupOfNames)(member=%d))"

MINIO_CI_CD=1 MINIO_ROOT_USER=minio MINIO_ROOT_PASSWORD=minio123 ${PATH_TO_MINIO_BIN_DIR}/minio server /tmp/disk{1...4}
```

Setup a user or group policy as in https://github.com/minio/minio/blob/master/docs/sts/ldap.md#managing-usergroup-access-policy

Run the `ldap.go` testing binary available in the MinIO repo - see: https://github.com/minio/minio/blob/master/docs/sts/ldap.md#using-ldap-sts-api

For example:

```
$ go run ldap.go -u dillon -p dillon
{KRHD6J5237M2Y2MUZT7N ELKeLxO321DAeoJcX6LmPuoAgx9LgKZE8U3PkGW8 eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3NLZXkiOiJLUkhENko1MjM3TTJZMk1VWlQ3TiIsImV4cCI6MTYxMTE4NTM1NSwibGRhcFVzZXIiOiJ1aWQ9ZGlsbG9uLG91PXBlb3BsZSxvdT1zd2VuZ2csZGM9bWluLGRjPWlvIn0.y99K8tA8av4vTVEjFGfOFz-hbcTsnaF_D3B1ftX0tIc_bmbxxMcQOPZ8RI4Nn8rjr4nK-06eBBHmI4N8V06L4A S3v4} <nil>
Calling list objects with temp creds: 
{  0001-01-01 00:00:00 +0000 UTC 0  0001-01-01 00:00:00 +0000 UTC map[] map[] map[] 0 { } []  false false   0001-01-01 00:00:00 +0000 UTC  Access Denied.}
```

### Testing login in with ldapsearch

   ```
   $ ldapsearch -D 'uid=dillon,ou=people,ou=swengg,dc=min,dc=io' -w dillon -b 'uid=dillon,ou=people,ou=swengg,dc=min,dc=io' -s sub -LLL '(objectclass=*)'
   ```

### Creating password values for LDIF files

Use the slappasswd tool in the container:
```
$ slappasswd -h {SSHA}
New password: 
Re-enter new password: 
{SSHA}XQSZqLPvYgm30wR7pk67a1GW+q+DDvSj
```

### Querying or Deleting users in the directory (for testing)

```
# Delete a user
$ ldapdelete  -D 'cn=admin,dc=min,dc=io' -w admin uid=liza,ou=people,ou=swengg,dc=min,dc=io

# Find a user
$ ldapsearch  -D 'cn=admin,dc=min,dc=io' -w admin  -b 'uid=dillon,ou=people,ou=swengg,dc=min,dc=io' -s sub -LLL '(objectclass=*)'

# Delete a group
$ ldapdelete  -D 'cn=admin,dc=min,dc=io' -w admin cn=projecta,ou=groups,ou=swengg,dc=min,dc=io

# Delete a member from a group (create a file like below)
$ cat del-member.ldif
dn: cn=projectb,ou=groups,ou=swengg,dc=min,dc=io
changetype: modify
delete: member
member: uid=dillon,ou=people,ou=swengg,dc=min,dc=io

$ ldapmodify  -D 'cn=admin,dc=min,dc=io' -w admin -f del-member.ldif

```
