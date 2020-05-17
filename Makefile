.PHONY: build
build:
	docker build . -t karlvr/sensu-client

.PHONY: push
push:
	docker push karlvr/sensu-client
