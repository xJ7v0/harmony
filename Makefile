
-include config.mak

ifeq ($(prefix),)

all:
	@echo "Please set prefix in config.mak by running configure before running make."
	@exit 1

else

install:
	install -vd "$(prefix)/share"
	install -vd "$(prefix)/sbin"
	install -vD -m 755 harmony "$(prefix)/sbin"

	cp -r share/harmony/  "$(prefix)/share/"


uninstall:
	rm -vfr "$(prefix)/share/harmony"
	rm -vf "$(prefix)/sbin/harmony"

endif

.PHONY: install uninstall
