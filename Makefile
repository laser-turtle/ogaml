include common_defs.mk


# Window constants

INCLUDES = -I src/core -I src/math -I src/graphics

MODULES = ogamlMath.cmxa ogamlCore.cmxa ogamlGraphics.cmxa

PACKAGES = -package bigarray,unix,str


# Install constants

CORE_FILES = src/core/*ogamlCore.*

MATH_FILES = src/math/*ogamlMath.*

GRAPH_FILES = src/graphics/*ogamlGraphics.*

DOC_FILES = src/graphics/ogamlGraphics.mli src/core/ogamlCore.mli src/math/ogamlMath.mli

# Compilation

default: math_lib core_lib graphics_lib

math_lib:
	cd src/math/ && make

core_lib:
	cd src/core/ && make

graphics_lib: core_lib math_lib
	cd src/graphics/ && make

examples:
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package ogaml.graphics examples/cube.ml -o cube.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package ogaml.graphics examples/tut01.ml -o tut01.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package ogaml.graphics examples/tut02.ml -o tut02.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package ogaml.graphics examples/tut_tex.ml -o tut_tex.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package ogaml.graphics examples/tut_idx.ml -o tut_idx.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package ogaml.graphics examples/flat.ml -o flat.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package ogaml.graphics examples/vertexmaps.ml -o vertexmaps.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package ogaml.graphics examples/sprites.ml -o sprites.out

tests: math_lib core_lib graphics_lib
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg $(INCLUDES) $(MODULES) $(PACKAGES) tests/programs.ml -o main.out && ./main.out &&\
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg $(INCLUDES) $(MODULES) $(PACKAGES) tests/vertexarrays.ml -o main.out && ./main.out &&\
	echo "Tests passed !"

doc:
	ocamlbuild -use-ocamlfind -use-menhir -I src/doc -package unix,str gendoc.native;
	./gendoc.native $(DOC_FILES);
	ocamlbuild -clean

install: math_lib core_lib graphics_lib
	$(OCAMLFIND) install ogaml META $(CORE_FILES) $(MATH_FILES) $(GRAPH_FILES)

reinstall:math_lib core_lib graphics_lib uninstall install

uninstall:
	$(OCAMLFIND) remove "ogaml"

clean:
	rm -rf *.out;
	rm -rf doc;
	ocamlbuild -clean;
	cd src/core/ && make clean;
	cd src/math/ && make clean;
	cd src/graphics/ && make clean;
	cd tests/ && make clean;
	cd examples/ && make clean

.PHONY: install uninstall reinstall examples doc
