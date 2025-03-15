
-include config.mak

ifeq ($(prefix),)

all:
	@echo "Please set prefix in config.mak by running configure before running make."
	@exit 1

else

install:
	#install -vd "$PREFIX/share/harmony/examples/cron"
	install -vd "$PREFIX/share/harmony/examples/config"
	install -vd "$PREFIX/share/harmony/plugins"
	install -vd "$PREFIX/sbin"

	#install -vD share/harmony/examples/cron/* "$PREFIX/share/harmony/examples/cron"
	install -vD share/harmony/examples/config/* "$PREFIX/share/harmony/examples/config"
	install -vD share/harmony/plugins/* "$PREFIX/share/harmony/plugins"

	install -vD -m 755 harmony "$PREFIX/sbin"

unistall: install
	rm -vfr "$prefix/share/harmony"
	rm -vf "$prefix/sbin/harmony"

endif

.PHONY: install
