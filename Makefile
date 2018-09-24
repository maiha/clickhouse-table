SHELL=/bin/bash
CRYSTAL ?= crystal
STATIC_LINK_FLAGS = --link-flags "-static"
BINARY=bin/clickhouse-table
OK="\033[1;32mOK\033[0m\n"

VERSION=
CURRENT_VERSION=$(shell git tag -l | sort -V | tail -1)
GUESSED_VERSION=$(shell git tag -l | sort -V | tail -1 | awk 'BEGIN { FS="." } { $$3++; } { printf "%d.%d.%d", $$1, $$2, $$3 }')

.SHELLFLAGS = -o pipefail -c

.PHONY : build
build:
	shards build

.PHONY : static
static: src/bin/main.cr
	rm -f ${BINARY}
	$(CRYSTAL) build ${BUILD_FLAGS} $^ -o ${BINARY} ${STATIC_LINK_FLAGS}
	LC_ALL=C file ${BINARY} > /dev/null
	@printf $(OK)

.PHONY : test
test: build spec

.PHONY : spec
spec:
	crystal spec -v --fail-fast

.PHONY : version
version:
	@if [ "$(VERSION)" = "" ]; then \
	  echo "ERROR: specify VERSION as bellow. (current: $(CURRENT_VERSION))";\
	  echo "  make version VERSION=$(GUESSED_VERSION)";\
	else \
	  sed -i -e 's/^version: .*/version: $(VERSION)/' shard.yml ;\
	  sed -i -e 's/^    version: [0-9]\+\.[0-9]\+\.[0-9]\+/    version: $(VERSION)/' README.md ;\
	  echo git commit -a -m "'$(COMMIT_MESSAGE)'" ;\
	  git commit -a -m 'version: $(VERSION)' ;\
	  git tag "v$(VERSION)" ;\
	fi

.PHONY : bump
bump:
	make version VERSION=$(GUESSED_VERSION) -s
