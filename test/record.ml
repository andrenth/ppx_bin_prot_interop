type t =
  { a : int
  ; b : string
  ; c : char * bool
  ; d : [`A | `B of float | `C]
  ; e : int option
  }
  [@@deriving bin_io_interop ~php]
