include ../../../common_defs.mk

# ML constants

ML_SOURCES = windows.ml

ML_CMIS = $(ML_SOURCES:.ml=.cmi)

ML_OBJS = $(ML_SOURCES:.ml=.cmo)

ML_NATS = $(ML_SOURCES:.ml=.cmx)


# Compilation

default: .depend $(ML_CMIS) $(ML_OBJS) $(ML_NATS)

%.cmi:%.mli
	$(OCAMLC_CMD) -c -o $@ $<

%.cmx:%.ml $(wildcard %.cmi)
	$(OCAMLOPT_CMD) -c -o $@ -for-pack $(CORE_PACK) $<

%.cmo:%.ml $(wildcard %.cmi)
	$(OCAMLC_CMD) -c -o $@ -for-pack $(CORE_PACK) $<


# Cleaning

clean:
	rm -rf $(CLEAN_EXTENSIONS)


# Dependencies

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

include .depend

.PHONY: .depend

