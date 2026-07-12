.PHONY: all 01 02 run run01 run02 valgrind valgrind1 valgrind2 clean

all: 01 02

01:
	$(MAKE) -C 01_string_concat all

02:
	$(MAKE) -C 02_invoice_sealer all

run: run01 run02

run01:
	$(MAKE) -C 01_string_concat run

run02:
	$(MAKE) -C 02_invoice_sealer run

valgrind: valgrind1 valgrind2

valgrind1:
	$(MAKE) -C 01_string_concat valgrind

valgrind2:
	$(MAKE) -C 02_invoice_sealer valgrind

clean:
	$(MAKE) -C 01_string_concat clean
	$(MAKE) -C 02_invoice_sealer clean
