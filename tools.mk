
NB_VERSION = 5.7.8
TODO_TXT_CLI_VERSION = 2.12.0
PANDOC_VERSION = 2.11.3.2
GIT_GONE_VERSION = 0.3.7

DOWNLOAD ::= $(shell xdg-user-dir DOWNLOAD)

.DEFAULT: tools

.PHONY: nb
nb:
	curl -fL "https://raw.github.com/xwmx/nb/$(NB_VERSION)/nb" -o "$(DOWNLOAD)/nb"
	install -m755 "$(DOWNLOAD)/nb" "$(HOME)/.local/bin/nb"

.PHONY: todo.sh
todo.sh:
	curl -fL "https://raw.github.com/todotxt/todo.txt-cli/v$(TODO_TXT_CLI_VERSION)/todo.sh" -o "$(DOWNLOAD)/todo.sh"
	install -m755 "$(DOWNLOAD)/todo.sh" "$(HOME)/.local/bin/todo.sh"

.PHONY: youtube-dl
youtube-dl:
	curl -fL https://yt-dl.org/downloads/latest/youtube-dl -o "$(DOWNLOAD)/youtube-dl"
	install -m755 "$(DOWNLOAD)/youtube-dl" "$(HOME)/.local/bin/youtube-dl"

.PHONY: pandoc
pandoc:
	curl -fL "https://github.com/jgm/pandoc/releases/download/$(PANDOC_VERSION)/pandoc-$(PANDOC_VERSION)-linux-amd64.tar.gz" \
		-o "$(DOWNLOAD)/pandoc-$(PANDOC_VERSION)-linux-amd64.tar.gz"
	tar xzf "$(DOWNLOAD)/pandoc-$(PANDOC_VERSION)-linux-amd64.tar.gz" -C "$(DOWNLOAD)"
	install -m755 "$(DOWNLOAD)/pandoc-$(PANDOC_VERSION)/bin/pandoc" "$(HOME)/.local/bin/pandoc"
	install -D -m644 "$(DOWNLOAD)/pandoc-$(PANDOC_VERSION)/share/man/man1/pandoc.1.gz" "$(HOME)/.local/share/man/man1/pandoc.1.gz"

.PHONY: git-gone
git-gone:
	curl -fL "https://github.com/lunaryorn/git-gone/releases/download/v$(GIT_GONE_VERSION)/git-gone-v$(GIT_GONE_VERSION)-x86_64-unknown-linux-musl.tar.gz" \
		-o "$(DOWNLOAD)/git-gone-v$(GIT_GONE_VERSION)-x86_64-unknown-linux-musl.tar.gz"
	tar xzf "$(DOWNLOAD)/git-gone-v$(GIT_GONE_VERSION)-x86_64-unknown-linux-musl.tar.gz" -C "$(DOWNLOAD)"
	install -m755 "$(DOWNLOAD)/git-gone-v$(GIT_GONE_VERSION)-x86_64-unknown-linux-musl/git-gone" "$(HOME)/.local/git-gone"
	install -D -m644 "$(DOWNLOAD)/git-gone-v$(GIT_GONE_VERSION)-x86_64-unknown-linux-musl/git-gone.1" "$(HOME)/.local/share/man/man1/git-gone.1"

tools: nb todo.sh youtube-dl pandoc git-gone
