SDK = $$(xcrun --show-sdk-path --sdk macosx)

build: lookup.swift
	@mkdir -p build

	@xcrun swiftc -o build/lookup lookup.swift

	@touch $@

clean:
	@rm -rf build

.PHONY: clean
