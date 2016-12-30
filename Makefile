PANDOC_VERSION=$(shell pandoc --version | sed -ne 's/^pandoc \([0-9.]*\)/\1/p')

test: dist
	@echo "Using Pandoc" $(PANDOC_VERSION)
	@echo "Testing plain JSON conversion..."
	@PANDOC_VERSION=$(PANDOC_VERSION) \
	  pandoc --from=native --to=tests/identity.lua tests/testsuite.native |\
		pandoc --from=json --to=native --standalone -o dist/identity.native
	@test -z "$(diff tests/testsuite.native dist/identity.native)"
	@echo "Success"
	@echo "Testing table JSON conversion..."
	@PANDOC_VERSION=$(PANDOC_VERSION) \
	  pandoc --from=native --to=tests/identity.lua tests/tables.native |\
		pandoc --from=json --to=native --standalone -o dist/tables.native
	@test -z "$(diff tests/tables.native dist/tables.native)"
	@echo "Success"

dist:
	mkdir dist

clean:
	rm -r dist

.PHONY: test clean
