all: Makefile.coq
	@+$(MAKE) -f Makefile.coq all

html: Makefile.coq
	@+$(MAKE) -f Makefile.coq html COQDOCEXTRAFLAGS="--gallina --external https://plv.mpi-sws.org/coqdoc/stdpp/ stdpp"

clean: Makefile.coq
	@+$(MAKE) -f Makefile.coq cleanall
	@rm -f Makefile.coq Makefile.coq.conf

Makefile.coq: _CoqProject
	$(COQBIN)coq_makefile -f _CoqProject -o Makefile.coq

force _CoqProject Makefile: ;

%: Makefile.coq force
	@+$(MAKE) -f Makefile.coq $@

.PHONY: all clean force
