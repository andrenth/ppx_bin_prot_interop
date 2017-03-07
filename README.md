# ppx\_bin\_prot\_interop

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

## OCaml types representation in PHP

### Integers

PHP only has one integer type, `int`, which corresponds to a `long` in C,
meaning it's either 32 or 64 bits long. Since OCaml integers are 31 or 63 bits
long, serializing a PHP `int` with `bin_write_int()` can throw an exception.

One can, of course, define RPC types using OCaml's `int32` or `int64` if needed.

### Tuples and lists

OCaml tuples and lists are represented as arrays in PHP (with numeric indices).

### Sum types and polymorphic variants

These are represented as two-element arrays, the first being the label (as a
string) and the second the corresponding value. Even if the constructor has
no associated value, a two-element array will be used, with `null` as the
second element.

So, for example, a type defined as `type t = A of int | B`, will be deserialized
as, say, `array("A", 42)` for the `A` case and `array("B", null)` for the `B`
case.

### Records

Records are represented as PHP associative arrays (hash tables), with string
keys corresponding to the record field names.
