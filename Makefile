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
	sh test/test_runner.sh

clean:
	rm -rf _build

.PHONY: default install uninstall reinstall clean test
