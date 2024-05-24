DEX_IMAGE ?= quay.io/minio/dex:latest
LDAP_IMAGE ?= quay.io/minio/openldap:latest

all: docker-images

docker-images:
	(cd ldap && docker build -t $(LDAP_IMAGE) .)
	(cd openid && docker build -t $(DEX_IMAGE) .)

ldap-service:
	docker run \
        -p 1389:389 -p 1636:636 --name openldap \
        --env LDAP_ORGANIZATION="MinIO Inc." \
        --env LDAP_DOMAIN="min.io" \
        --env LDAP_ADMIN_PASSWORD="admin" \
        --hostname openldap \
        --detach \
        $(LDAP_IMAGE) --copy-service

openid-service:
	docker run \
        -p 5556:5556 \
        --name dex \
        --detach \
        $(DEX_IMAGE)
	docker run \
        -p 5557:5557 \
        --env DEX_ISSUER="http://127.0.0.1:5557/dex" \
        --env DEX_WEB_HTTP="0.0.0.0:5557" \
        --name dex-2 \
        --detach \
        $(DEX_IMAGE)

docker-run: ldap-service openid-service

podman-images:
	(cd ldap && podman build -t $(LDAP_IMAGE) .)
	(cd openid && podman build -t $(DEX_IMAGE) .)

# Run OpenLDAP (exposed on localhost:1389,1636) and two Dex instances (exposed
# at localhost:5556 and localhost:5557).
podman-run:
	podman pod create --name iam-testing -p 1389:389 -p 1636:636 -p 5556:5556 -p 5557:5557
	podman pod start iam-testing
	podman run \
        --env LDAP_ORGANIZATION="MinIO Inc." \
        --env LDAP_DOMAIN="min.io" \
        --env LDAP_ADMIN_PASSWORD="admin" \
        --name openldap \
        --pod iam-testing \
        --detach \
        $(LDAP_IMAGE) --copy-service
	podman run \
        --name dex \
        --pod iam-testing \
        --detach \
        $(DEX_IMAGE)
	podman run \
        --env DEX_ISSUER="http://127.0.0.1:5557/dex" \
        --env DEX_WEB_HTTP="0.0.0.0:5557" \
        --name dex-2 \
        --pod iam-testing \
        --detach \
        $(DEX_IMAGE)

clean:
	@podman pod rm -f iam-testing || echo "[Podman] Pod iam-testing does not exist"
	@docker rm -f openldap dex dex-2 || echo "[Docker] Clean!"
