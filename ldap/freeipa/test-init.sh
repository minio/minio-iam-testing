
MCC=$(docker-compose ps | grep _mc_1 | awk '{print $1}')
DEXEC="docker exec -ti ${MCC}"
MC="${DEXEC} mc"
ALIAS=test

# set alias && do some basics
${MC} alias set ${ALIAS} http://minio1:9000 minio minio123
${MC} admin info ${ALIAS}
${MC} mb ${ALIAS}/testbucket1
${MC} ls ${ALIAS}

# config identity_ldap to ipa.demo1.freeipa.org
# see https://www.freeipa.org/page/Demo
${MC} admin config set ${ALIAS} \
identity_ldap \
server_addr="ipa.demo1.freeipa.org:636" \
tls_skip_verify=on \
lookup_bind_dn="uid=admin,cn=users,cn=accounts,dc=demo1,dc=freeipa,dc=org" \
lookup_bind_password="Secret123" \
user_dn_search_base_dn="cn=users,cn=accounts,dc=demo1,dc=freeipa,dc=org" \
user_dn_search_filter="(&(uid=%s))" \
group_search_base_dn="cn=groups,cn=accounts,dc=demo1,dc=freeipa,dc=org" \
group_search_filter="(&(objectClass=groupofnames)(objectClass=nestedgroup)(member=%d))"

${MC} admin service restart ${ALIAS}
