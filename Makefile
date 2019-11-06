DOCKER := docker
DOCKER_REGISTRY := index.docker.io/kochava
DOCKER_IMAGE := riak
DOCKER_TAG := latest

.PHONY: all docker

all: docker

docker:
	$(DOCKER) build -t "$(DOCKER_REGISTRY)/$(DOCKER_IMAGE):$(DOCKER_TAG)" .
