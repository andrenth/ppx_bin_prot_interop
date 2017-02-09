type t =
  | A
  | B of { x : int; y : float }
  | C of string * char
  | D
  [@@deriving bin_io_interop ~php]
