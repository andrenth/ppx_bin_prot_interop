# ppx\_bin\_prot\_interop

## Introduction

In a few words, ppx\_bin\_prot\_interop is [ppx\_bin\_prot](https://github.com/janestreet/ppx_bin_prot)
for languages other than OCaml, i.e. a code generator for [bin\_prot](https://github.com/janestreet/bin_prot)
serializers implemented as a PPX rewriter.

Currently only PHP interoperability is implemented, though it shouldn't be very
hard to add others, as the rewriter builds a sort-of-AST for the generated code,
so support for other languages would consist in simply converting that to
strings in the appropriate syntax. The hard work, of course consists in writing
bindings for [libbin\_prot](https://github.com/andrenth/libbin_prot), as was
done in [php-bin\_prot](https://github.com/andrenth/php-bin_prot) (or porting
bin\_prot to your favorite language if you don't like C bindings).

## Installation

Just type `make` to build and `make install` to install. Tests can be run with
`make test`.

An example RPC server is included in the `examples` directory, which can be
built with `make examples`. Once you execute it, you can try the PHP client
simply running `php client.php`.

## Usage

When declaring your data type type, specify `bin_io_interop` alongside `bin_io`,
including the language you want interoperability with.

```ocaml
type t = int [@@deriving bin_io, bin_io_interop ~php]
```

After compilation, an `interop` directory will be created, with a subdirectory
for the specified language, so in the example above the generated code will be
in `interop/php`.
