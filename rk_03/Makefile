CFLAGS := -Wall -fmodules-ts
CURDIR := $(shell pwd)

.DEFAULT_GOAL := debug

.PHONY: default debug profile
default:
	cmake -B build -G Ninja -DCMAKE_CXX_FLAGS="$(CFLAGS) -O0" .
	cmake --build build

debug:
	cmake -B build -G Ninja -DCMAKE_CXX_FLAGS="$(CFLAGS) -O0 -g" -DCMAKE_EXE_LINKER_FLAGS="-g" .
	cmake --build build

.PHONY: run dbg test
run:
	@# Run from build directory, not from current (to not generate gmon.out
	@# here in case of profiling).
	cd build && ./main

dbg:
	cgdb build/main

.PHONY: clean
clean:
	rm -rf build
