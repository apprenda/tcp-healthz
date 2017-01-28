# Set build version
ifeq ($(origin VERSION), undefined)
	VERSION := $(shell git describe --tags --always --dirty)
endif

BUILD_DATE := $(shell date -u)
IMAGE=apprenda/tcp-healthz-amd64
HOST_GOOS = $(shell go env GOOS)

ifeq ($(origin GOOS), undefined)
	GOOS := $(HOST_GOOS)
endif

build:
	GOOS=$(GOOS) go build -o bin/tcp-healthz-$(GOOS)-amd64 -ldflags "-X main.version=$(VERSION) -X 'main.buildDate=$(BUILD_DATE)' -extldflags '-static'"

clean:
	rm -rf bin
	rm -rf container.tar

container: GOOS=linux
container: build
	docker build --pull -t $(IMAGE):$(VERSION) .

container-tar: container
	docker save $(IMAGE):$(VERSION) > container.tar

push: container
	./docker-push.sh $(IMAGE):$(VERSION)
