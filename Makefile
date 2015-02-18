SDK = $$(xcrun --show-sdk-path --sdk macosx)

all: lookup

lookup: lookup.swift
	@xcrun swiftc -sdk $(SDK) -o lookup lookup.swift
	@touch $@

clean:
	@rm -rf lookup

.PHONY: clean
