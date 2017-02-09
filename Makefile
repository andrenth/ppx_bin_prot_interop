NAME := ppx_bin_prot_interop
PREFIX := $(shell dirname `opam config var lib`)

# Default rule
default:
	jbuilder build-package $(NAME)

install:
	opam-installer -i --prefix $(PREFIX) $(NAME).install

uninstall:
	opam-installer -u --prefix $(PREFIX) $(NAME).install

reinstall: uninstall install

ppx: default
	ocamlfind ocamlopt -predicates ppx_driver -o _build/ppx -linkpkg -package ppx_bench -package ppx_bin_prot -package ppx_bin_prot_interop ppx_driver_runner.cmxa

test: ppx
	mkdir -p _build/test
	cp test/test_runner.ml _build/test
	ocamlfind ocamlopt -o _build/test/test_runner -linkpkg -package unix _build/test/test_runner.ml
	./_build/test/test_runner

clean:
	rm -rf _build

.PHONY: default install uninstall reinstall clean test
