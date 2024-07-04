
up:
	docker-compose down || true
	docker-compose up -d

renewed-renaissance-storefront:
	docker build . --progress=plain --tag renewed-renaissance-storefront --file Dockerfile

