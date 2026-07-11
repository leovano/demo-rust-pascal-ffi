.PHONY: all 01 run valgrind clean

all: 01

01:
	$(MAKE) -C 01_string_concat all

run:
	$(MAKE) -C 01_string_concat run

valgrind:
	$(MAKE) -C 01_string_concat valgrind

clean:
	$(MAKE) -C 01_string_concat clean
