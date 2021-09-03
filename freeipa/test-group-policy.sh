MCC=$(docker-compose ps | grep _mc_1 | awk '{print $1}')
DEXEC="docker exec -ti ${MCC}"
MC="${DEXEC} mc"
ALIAS=test

# 13136_minio1_1 | Error: expecting a policy to be set for user `uid=manager,cn=users,cn=accounts,dc=demo1,dc=freeipa,dc=org`
# or one of their groups:
# `cn=ipausers,cn=groups,cn=accounts,dc=demo1,dc=freeipa,dc=org`,
# `cn=employees,cn=groups,cn=accounts,dc=demo1,dc=freeipa,dc=org`,
# `cn=managers,cn=groups,cn=accounts,dc=demo1,dc=freeipa,dc=org`
# - rejecting this request (*errors.errorString)

# set policy for managers group
${MC} admin policy set ${ALIAS} consoleAdmin group='cn=managers,cn=groups,cn=accounts,dc=demo1,dc=freeipa,dc=org'


[ -f cookie.txt ]  && rm cookie.txt

curl -s 'http://localhost:9001/api/v1/login' \
  --cookie-jar cookie.txt \
  -H 'Content-Type: application/json' \
  --data-raw '{"accessKey":"manager","secretKey":"Secret123"}' \
  --output session-manager.json

cat session-manager.json | grep 'invalid Login' &&  exit 1

curl -s 'http://localhost:9001/api/v1/buckets' \
  --cookie cookie.txt \
  --output buckets-manager.json

cat buckets-manager.json | grep testbucket1 || exit 1


# update readnly policy with "ListAllMyBuckets"

curl -s 'http://localhost:9001/api/v1/policies' \
  --cookie cookie.txt \
  -H 'Content-Type: application/json' \
  --data-raw '{"name":"readonly","policy":"{\n    \"Version\": \"2012-10-17\",\n    \"Statement\": [\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": [\n                \"s3:GetBucketLocation\",\n                \"s3:GetObject\",\n                \"s3:ListBucket\"\n            ],\n            \"Resource\": [\n                \"arn:aws:s3:::*\"\n            ]\n        }\n    ]\n}"}' \
  --output policies-update-manager.json



cat policies-update-manager.json | grep ListBucket || exit 1

rm cookie.txt
rm policies-update-manager.json
rm session-manager.json
rm buckets-manager.json
echo "TEST manager OK"


# 13136_minio1_1 | Error: expecting a policy to be set for user `uid=employee,cn=users,cn=accounts,dc=demo1,dc=freeipa,dc=org`
# or one of their groups:
# `cn=ipausers,cn=groups,cn=accounts,dc=demo1,dc=freeipa,dc=org`,
# `cn=employees,cn=groups,cn=accounts,dc=demo1,dc=freeipa,dc=org`
# - rejecting this request (*errors.errorString)

# set policy for managers group
${MC} admin policy set ${ALIAS} readonly group='cn=employees,cn=groups,cn=accounts,dc=demo1,dc=freeipa,dc=org'

[ -f cookie.txt ]  && rm cookie.txt

curl -s 'http://localhost:9001/api/v1/login' \
  --cookie-jar cookie.txt \
  -H 'Content-Type: application/json' \
  --data-raw '{"accessKey":"employee","secretKey":"Secret123"}' \
  --output session-employee.json

cat session-employee.json | grep 'invalid Login' &&  exit 1

curl -s 'http://localhost:9001/api/v1/buckets' \
  --cookie cookie.txt \
  --output buckets-employee.json

cat buckets-employee.json | grep null && exit 1

rm cookie.txt
rm session-employee.json
rm buckets-employee.json
echo "Test employee OK, can close https://github.com/minio/minio/issues/13136"
