TARGET = x86_64-apple-macosx10.10
SDK = $$(xcrun --show-sdk-path --sdk macosx)

all: lookup

lookup: lookup.swift
	@xcrun swiftc -sdk ${SDK} -target ${TARGET} -o lookup lookup.swift
	@touch $@

clean:
	@rm -rf lookup

.PHONY: clean
