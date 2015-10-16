OCAMLBUILD=ocamlbuild -use-ocamlfind -classic-display -j 4

OCAMLBUILD_DIR=$(shell ocamlc -where)/ocamlbuild

XLIB_DIR=src/wm/xlib

TEST_DIR=src/test


xlib-nat-test: xlib-nat
	$(OCAMLBUILD) -I $(XLIB_DIR) $(TEST_DIR)/xtest_simple.native

xlib-byte-test: xlib-byte
	$(OCAMLBUILD) -I $(XLIB_DIR) $(TEST_DIR)/xtest_simple.byte

xlib: xlib-nat xlib-byte

xlib-nat:
	$(OCAMLBUILD) $(XLIB_DIR)/xlib.cmxa

xlib-byte:
	$(OCAMLBUILD) $(XLIB_DIR)/xlib.cma

clean:
	$(OCAMLBUILD) -clean


