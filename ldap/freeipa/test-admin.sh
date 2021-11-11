MCC=$(docker-compose ps | grep _mc_1 | awk '{print $1}')
DEXEC="docker exec -ti ${MCC}"
MC="${DEXEC} mc"
ALIAS=test

# set policy for user admin to consoleAdmin
${MC} admin policy set ${ALIAS} consoleAdmin user='uid=admin,cn=users,cn=accounts,dc=demo1,dc=freeipa,dc=org'
${MC} admin user list ${ALIAS}

[ -f cookie.txt ]  && rm cookie.txt

curl -s 'http://localhost:9001/api/v1/login' \
  --cookie-jar cookie.txt \
  -H 'Content-Type: application/json' \
  --data-raw '{"accessKey":"admin","secretKey":"Secret123"}' \
  --output session-admin.json

cat session-admin.json | grep 'invalid Login' &&  exit 1

curl -s 'http://localhost:9001/api/v1/buckets' \
  --cookie cookie.txt \
  --output buckets-admin.json

cat buckets-admin.json | grep testbucket1 || exit 1

rm cookie.txt
rm session-admin.json
rm buckets-admin.json
echo "TEST admin OK"
