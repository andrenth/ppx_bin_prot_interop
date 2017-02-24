(*module M = struct
  type t =
    [ `A of int
    | `B
    ]
    [@@deriving bin_io_interop ~php]
end*)

(*type u = [`X] [@@deriving bin_io, bin_io_interop ~php]
type t = [u|`A of int * string | `B | `C of float] [@@deriving bin_io, bin_io_interop ~php]*)

(* type t = int * (string * char) * float [@@deriving bin_io, bin_io_interop ~php] *)

(*type t = float * (string * string) * int list [@@deriving bin_io_interop ~php]*)

(*type u = [`X] [@@deriving bin_io_interop ~php]
type v = [`Y] [@@deriving bin_io_interop ~php]
module M = struct
type t = [u | v |`A of int * float | `B | `C of string] [@@deriving bin_io_interop ~php]
end*)

(* type u = [`A of int | `B] [@@deriving bin_io] *)

(* type u = { x : float } [@@deriving bin_io_interop ~php] *)

(*type t =
  { a: int
  ; b: string
  ; c: u
  } [@@deriving bin_io, bin_io_interop ~php]*)

(* type t = int * float [@@deriving bin_io_interop ~php] *)

type v = char * (string * float) * bool [@@deriving bin_io_interop ~php]
type u = { x : string; y : v } [@@deriving bin_io_interop ~php]

type t =
  | A of int
  | B of u
  | C of string * float * int
  | D of int * (char * bool) * string
  | X
  | Y of [`M of int | `N]
  [@@deriving bin_io, bin_io_interop ~php]
