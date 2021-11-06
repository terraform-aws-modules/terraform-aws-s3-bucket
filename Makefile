.PHONY: changelog release

scope ?= "minor"

changelog-unrelease:
	git-chglog --no-case -o CHANGELOG.md

changelog:
	git-chglog --no-case -o CHANGELOG.md --next-tag `semtag final -s $(scope) -o -f`

release:
	semtag final -s $(scope)
