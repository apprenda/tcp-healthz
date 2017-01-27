# Set build version
ifeq ($(origin VERSION), undefined)
	VERSION := $(shell git describe --tags --always --dirty)
endif

BUILD_DATE := $(shell date -u)
IMAGE=kismatic/tcp-healthz-amd64
HOST_GOOS = $(shell go env GOOS)

# Vars used to determine if we are pushing a new version to docker hub
LATEST_TAG = $(shell git describe --abbrev=0 --tags)
LATEST_TAG_COMMIT = $(shell git rev-list -n 1 $LATEST_TAG)
CURRENT_BRANCH = $(shell git rev-parse --abbrev-ref HEAD)

ifeq ($(origin GOOS), undefined)
	GOOS := $(HOST_GOOS)
endif

build:
	go build -o bin/tcp-healthz-$(GOOS)-amd64 -ldflags "-X main.version=$(VERSION) -X 'main.buildDate=$(BUILD_DATE)'"

clean:
	rm -rf bin
	rm -rf container.tar

container: GOOS=linux
container: build
	docker build --pull -t $(IMAGE):$(VERSION) .

container-tar: container
	docker save $(IMAGE):$(VERSION) > container.tar

push: container
	# Only push tagged versions from master
	ifeq($(CURRENT_BRANCH), master)
	ifeq($(LATEST_TAG), $(LATEST_TAG_COMMIT))
		docker push $(IMAGE):$(VERSION)
	endif
	endif
