INSTALL_ARGS := $(if $(PREFIX),--prefix $(PREFIX),)

# Default rule
default:
	jbuilder build @install

install:
	jbuilder install $(INSTALL_ARGS)

uninstall:
	jbuilder uninstall $(INSTALL_ARGS)

reinstall: uninstall install

ppx: default
	ocamlfind ocamlopt -predicates ppx_driver -o _build/ppx -linkpkg \
		-package ppx_bin_prot         \
		-package ppx_bin_prot_interop \
		-package ppx_driver.runner

test: ppx
	sh test/test_runner.sh

clean:
	rm -rf _build

.PHONY: default install uninstall reinstall clean test
