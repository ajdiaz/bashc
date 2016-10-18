#
# Makefile
# Andres J. Diaz, 2016-10-18 08:57
#

all:
	@./scripts/build.sh && rm -f ./releases/bash

clean:
	rm -rf build/* releases/*
# vim:ft=make
#
