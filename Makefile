# Set build version
ifeq ($(origin VERSION), undefined)
	VERSION := $(shell git describe --tags --always --dirty)
endif

BUILD_DATE := $(shell date -u)
IMAGE=apprenda/tcp-healthz-amd64
HOST_GOOS = $(shell go env GOOS)
BUILD_IMAGE := golang:1.7.5-alpine
PKG := github.com/apprenda/tcp-healthz

ifeq ($(origin GOOS), undefined)
	GOOS := $(HOST_GOOS)
endif

build:
	@docker run                                                                     \
	  -v $$(pwd):/go/src/$(PKG)                                                     \
	  -w /go/src/$(PKG)                                                             \
	  $(BUILD_IMAGE)                                                                \
	  /bin/sh -c "                                                                  \
	    GOOS=$(GOOS)                                                                \
	    CGO_ENABLED=0                                                               \
	    go build                                                                    \
	    -o bin/tcp-healthz-$(GOOS)-amd64                                            \
	    -ldflags \"-X 'main.version=$(VERSION)' -X 'main.buildDate=$(BUILD_DATE)'\" \
	  "

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
