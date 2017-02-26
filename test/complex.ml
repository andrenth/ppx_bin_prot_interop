type v = char * (string * float) * bool [@@deriving bin_io_interop ~php]
type u = { x : string; y : v } [@@deriving bin_io_interop ~php]

type t =
  | A of int
  | B of u
  | C of string * float * int
  | D of int * (char * bool) * string
  | X
  | Y of [`M of int | `N]
  | Z of { m : string; n : int list }
  [@@deriving bin_io, bin_io_interop ~php]
