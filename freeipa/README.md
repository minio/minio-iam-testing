# Configure MinIO for Authentication using **FreeIPA**

tldr;

```
# mc admin config set ${ALIAS} \
identity_ldap \
server_addr="ipa.demo1.freeipa.org:636" \
lookup_bind_dn="uid=admin,cn=users,cn=accounts,dc=demo1,dc=freeipa,dc=org" \
lookup_bind_password="Secret123" \
user_dn_search_base_dn="cn=users,cn=accounts,dc=demo1,dc=freeipa,dc=org" \
user_dn_search_filter="(&(uid=%s))" \
group_search_base_dn="cn=groups,cn=accounts,dc=demo1,dc=freeipa,dc=org" \
group_search_filter="(&(objectClass=groupofnames)(objectClass=nestedgroup)(member=%d))"

# mc admin service restart ${ALIAS}

# mc admin policy set ${ALIAS} consoleAdmin \
group='cn=managers,cn=groups,cn=accounts,dc=demo1,dc=freeipa,dc=org'

# mc admin policy set ${ALIAS} readonly \
group='cn=employees,cn=groups,cn=accounts,dc=demo1,dc=freeipa,dc=org'


```


### test with ipa.demo1.freeipa.org

* https://www.freeipa.org/page/Demo#Infrastructure
* https://docs.min.io/minio/baremetal/security/ad-ldap-external-identity-management/configure-ad-ldap-external-identity-management.html#procedure

```

# curl -s https://ipa.demo1.freeipa.org/ > /dev/null && \
docker-compose up -d && \
./test-init.sh && ./test-admin.sh && ./test-group-policy.sh && \
docker-compose down


13136_minio2_1 is up-to-date
13136_minio4_1 is up-to-date
13136_minio3_1 is up-to-date
13136_minio1_1 is up-to-date
13136_mc_1 is up-to-date
Added `test` successfully.
●  minio2:9000
   Uptime: 10 minutes
   Version: 2021-08-31T05:46:54Z
   Network: 4/4 OK
   Drives: 2/2 OK

●  minio3:9000
   Uptime: 10 minutes
   Version: 2021-08-31T05:46:54Z
   Network: 4/4 OK
   Drives: 2/2 OK

●  minio4:9000
   Uptime: 10 minutes
   Version: 2021-08-31T05:46:54Z
   Network: 4/4 OK
   Drives: 2/2 OK

●  minio1:9000
   Uptime: 10 minutes
   Version: 2021-08-31T05:46:54Z
   Network: 4/4 OK
   Drives: 2/2 OK

0 B Used, 1 Bucket, 0 Objects
8 drives online, 0 drives offline
mc: <ERROR> Unable to make bucket `test/testbucket1`. Your previous request to create the named bucket succeeded and you already own it.
[2021-09-03 06:55:51 UTC]     0B testbucket1/
Successfully applied new settings.
Please restart your server 'mc admin service restart test'.
Restart command successfully sent to `test`. Type Ctrl-C to quit or wait to follow the status of the restart process.
....
Restarted `test` successfully.
Policy `consoleAdmin` is set on user `uid=admin,cn=users,cn=accounts,dc=demo1,dc=freeipa,dc=org`
enabled    uid=admin,cn=user...  consoleAdmin        
{"buckets":[{"creation_date":"2021-09-03T06:55:51Z","name":"testbucket1"}],"total":1}
TEST admin OK
Policy `consoleAdmin` is set on group `cn=managers,cn=groups,cn=accounts,dc=demo1,dc=freeipa,dc=org`
{"buckets":[{"creation_date":"2021-09-03T06:55:51Z","name":"testbucket1"}],"total":1}
{"name":"readonly","policy":"{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"s3:GetBucketLocation\",\"s3:GetObject\",\"s3:ListBucket\"],\"Resource\":[\"arn:aws:s3:::*\"]}]}"}
TEST manager OK
Policy `readonly` is set on group `cn=employees,cn=groups,cn=accounts,dc=demo1,dc=freeipa,dc=org`
Test employee OK, can close https://github.com/minio/minio/issues/13136
Stopping 13136_mc_1     ... done
Stopping 13136_minio3_1 ... done
Stopping 13136_minio4_1 ... done
Stopping 13136_minio2_1 ... done
Stopping 13136_minio1_1 ... done
Removing 13136_mc_1     ... done
Removing 13136_minio3_1 ... done
Removing 13136_minio4_1 ... done
Removing 13136_minio2_1 ... done
Removing 13136_minio1_1 ... done
Removing network _13136_default

```

----

### why !?

because assumed that `readonly` policy can also *list* ;/

see https://github.com/minio/minio/issues/13136

and https://github.com/minio/minio/issues/5279#issuecomment-350496101

RTFM **ListBucket** ||&& **ListAllMyBuckets** 
