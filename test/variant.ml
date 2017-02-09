type t =
  [ `A
  | `B of int
  | `C of string * char
  | `D
  ]
  [@@deriving bin_io_interop ~php]
