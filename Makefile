#
# Makefile
# Andres J. Diaz, 2016-10-18 08:57
#

all:
	@./scripts/build.sh && rm -f ./releases/bash

test: all
	@echo -e "#! /bin/bash\necho \"test OK\"" > test.sh
	./releases/bashc ./test.sh test.bin && \
		[[ "$$(./test.bin)" == "test OK" ]] && \
		ldd ./test.bin 2>&1 | grep 'not a dynamic executable' && \
		rm -f ./test.{sh,bin}

clean:
	rm -rf build/* releases/*
# vim:ft=make
#
