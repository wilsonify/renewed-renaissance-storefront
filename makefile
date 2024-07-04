
renewed-renaissance-storefront:
	docker build . --tag renewed-renaissance-storefront --file Dockerfile

reaction-cli:
	docker build . --tag reaction-cli --file Dockerfile-reaction-cli
