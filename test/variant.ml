type t =
  [ `A
  | `B of int
  | `C of string * char
  | `D
  ]
  [@@deriving bin_io_interop ~php]

type u = [`X of float] [@@deriving bin_io_interop ~php]

type v = [ t | u | `Y ] [@@deriving bin_io_interop ~php]
