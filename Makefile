
-include config.mak

ifeq ($(prefix),)

all:
	@echo "Please set prefix in config.mak by running configure before running make."
	@exit 1

else

install:
	install -vd "$(prefix)/share/harmony/examples"
	install -vd "$(prefix)/share/harmony/plugins"
	install -vd "$(prefix)/sbin"

	install -vD share/harmony/examples/* "$(prefix)/share/harmony/examples/"
	install -vD share/harmony/plugins/* "$(prefix)/share/harmony/plugins"

	install -vD -m 755 harmony "$(prefix)/sbin"

uninstall:
	rm -vfr "$(prefix)/share/harmony"
	rm -vf "$(prefix)/sbin/harmony"

endif

.PHONY: install uninstall
