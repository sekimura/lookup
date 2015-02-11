SDK = $$(xcrun --show-sdk-path --sdk macosx)

build: lookup.swift
	@xcrun swiftc -o lookup lookup.swift
	@touch $@

clean:
	@rm -rf lookup

.PHONY: clean build
