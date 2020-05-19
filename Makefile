SHELL=/bin/bash

.SHELLFLAGS = -o pipefail -c

all: clickhouse-table-dev

######################################################################
### compiling

# for mounting permissions in docker-compose
export UID = $(shell id -u)
export GID = $(shell id -g)

COMPILE_FLAGS=-Dstatic
BUILD_TARGET=

DOCKER=docker run -t -u $(UID):$(GID) -v $(PWD):/v -w /v --rm crystallang/crystal:0.33.0

.PHONY: build
build:
	@$(DOCKER) shards build $(COMPILE_FLAGS) --link-flags "-static" $(BUILD_TARGET) $(O)

.PHONY: clickhouse-table-dev
clickhouse-table-dev: BUILD_TARGET=clickhouse-table-dev
clickhouse-table-dev: build

.PHONY: clickhouse-table
clickhouse-table: BUILD_TARGET=--release clickhouse-table
clickhouse-table: build

.PHONY: console
console:
	@$(DOCKER) sh

######################################################################
### testing

.PHONY: ci
ci: clickhouse-table spec

.PHONY: spec
spec:
	@$(DOCKER) crystal spec $(COMPILE_FLAGS) -v --fail-fast

######################################################################
### versioning

VERSION=
CURRENT_VERSION=$(shell git tag -l | sort -V | tail -1)
GUESSED_VERSION=$(shell git tag -l | sort -V | tail -1 | awk 'BEGIN { FS="." } { $$3++; } { printf "%d.%d.%d", $$1, $$2, $$3 }')

.PHONY : version
version:
	@if [ "$(VERSION)" = "" ]; then \
	  echo "ERROR: specify VERSION as bellow. (current: $(CURRENT_VERSION))";\
	  echo "  make version VERSION=$(GUESSED_VERSION)";\
	else \
	  sed -i -e 's/^version: .*/version: $(VERSION)/' shard.yml ;\
	  sed -i -e 's/^    version: [0-9]\+\.[0-9]\+\.[0-9]\+/    version: $(VERSION)/' README.cr.md ;\
	  echo git commit -a -m "'$(COMMIT_MESSAGE)'" ;\
	  git commit -a -m 'version: $(VERSION)' ;\
	  git tag "v$(VERSION)" ;\
	fi

.PHONY : bump
bump:
	make version VERSION=$(GUESSED_VERSION) -s
