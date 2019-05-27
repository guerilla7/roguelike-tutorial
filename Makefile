all: clean docs diff-rust

docs:
	@mkdir -p target/tutorial
	asciidoctor --destination-dir target/tutorial doc/output-templates/*.adoc
	@# Remove the asciidoc callout comments (e.g. `// <1>`) from the Rust outputs:
	@sed -i -e 's|\s*//\s*<[0-9]*>||g' target/tutorial/*.rs
	@# Add trailing newline to the Rust outputs:
	@for rust in target/tutorial/*.rs; do echo >> $$rust; done

diff-rust: docs
	cd target/tutorial/ && for rust in *.rs; do diff -u ../../src/bin/$$rust $$rust; done

publish:
	@git diff-index --quiet HEAD || { echo "Error: the repository is dirty."; exit 1; }
	rm -rf .deploy
	cp -r target/tutorial .deploy
	git checkout gh-pages
	git pull
	rm -rf *
	mv .deploy/* .
	rm -d .deploy
	git add -A
	git commit -m "Updated"
	git push --force
	git checkout -

preview: docs
	firefox --private-window file://$(shell readlink -f target/tutorial/index.html) 2>/dev/null

clean:
	rm -rf target/tutorial

list-contributor-names:
	git shortlog --summary | awk '{$$1=""}1' | sort

list-contributor-links:
	git log --merges | grep 'Merge pull request' | awk '{print $$6}' | cut -d/ -f1 | sort | uniq | sed -e 's|^|https://github.com/|'

.PHONY: all docs docs-docker preview clean publish list-contributor-names list-contributor-links diff-rust
