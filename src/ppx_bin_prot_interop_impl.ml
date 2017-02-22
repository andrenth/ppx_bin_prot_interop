let split_on_char = String.split_on_char

open StdLabels

module Interop = struct
  module Error = struct
    type t =
      [ `Empty_type of string
      | `No_variant_match
      | `Sum_tag
      ]
    let to_string = function
      | `Empty_type s -> "Empty_type " ^ s
      | `No_variant_match -> "No_variant_match"
  end

  module Var = struct
    type t =
      [ `Indexed of int
      | `Named of string
      ]

    let indexed i = `Indexed i
    let named s = `Named s
  end

  module Lit = struct
    type t =
      [ `Int of int
      | `String of string
      ]

    let int i = `Int i
    let string s = `String s
  end

  module Expr = struct
    type t =
      [ Lit.t
      | Var.t
      | `Add of t * t
      | `Binding of Var.t list * t
      | `App of [`Read of read | `Write of write | `Size of size | `Get of get]
      | `Ret of t list
      | `Raise of Error.t * string option
      | `Tuple of t list
      | `Record of (string * t) list
      | `Variant of string * t option
      | `Sum of string * t option
      | `Switch of t * case list
      | `Try of t list * (Error.t * t list) list
      | `Function_pointer of string
      ]

    and read =
      [ `Bin_read_int_8bit of t * t
      | `Bin_read_int_16bit of t * t
      | `Bin_read_variant_int of t * t
      | `Bin_read_bool of t * t
      | `Bin_read_char of t * t
      | `Bin_read_int of t * t
      | `Bin_read_float of t * t
      | `Bin_read_string of t * t
      | `Bin_read_list of t * t * t
      | `Bin_read_custom of string * t list * t * t
      ]

   and write =
      [ `Bin_write_int_8bit of t * t * t
      | `Bin_write_int_16bit of t * t * t
      | `Bin_write_variant_int of t * t * t
      | `Bin_write_bool of t * t * t
      | `Bin_write_char of t * t * t
      | `Bin_write_int of t * t * t
      | `Bin_write_float of t * t * t
      | `Bin_write_string of t * t * t
      | `Bin_write_list of t * t * t * t
      | `Bin_write_custom of string * t list * t * t * t
      ]

   and size =
      [ `Bin_size_int_8bit of t
      | `Bin_size_int_16bit of t
      | `Bin_size_variant_int of t
      | `Bin_size_bool of t
      | `Bin_size_char of t
      | `Bin_size_int of t
      | `Bin_size_float of t
      | `Bin_size_string of t
      | `Bin_size_list of t * t
      | `Bin_size_custom of string * t list * t
      ]

    and get =
      [ `At of t * int
      | `Key of t * string
      | `Tag of t
      | `Value of t
      ]

    and case =
      [ `Case of Lit.t * t list * bool
      | `Default of t list
      ]

    let add e1 e2 =
      `Add (e1, e2)

    let bind vars expr =
      `Binding (vars, expr)

    let funp f =
      `Function_pointer f

    let bin_read_int_8bit buf pos =
      `App (`Read (`Bin_read_int_8bit (buf, pos)))

    let bin_read_int_16bit buf pos =
      `App (`Read (`Bin_read_int_16bit (buf, pos)))

    let bin_read_variant_int buf pos =
      `App (`Read (`Bin_read_variant_int (buf, pos)))

    let bin_write_int_8bit buf pos value =
      `App (`Write (`Bin_write_int_8bit (buf, pos, value)))

    let bin_write_int_16bit buf pos value =
      `App (`Write (`Bin_write_int_16bit (buf, pos, value)))

    let bin_write_variant_int buf pos value =
      `App (`Write (`Bin_write_variant_int (buf, pos, value)))

    let get_at i e =
      `App (`Get (`At (e, i)))

    let get_key k e =
      `App (`Get (`Key (e, k)))

    let get_tag e =
      `App (`Get (`Tag e))

    let get_value e =
      `App (`Get (`Value e))
  end

  module Fun_decl = struct
    type t =
      { name   : string
      ; params : Expr.t list
      ; body   : Expr.t list
      }

    let make name params body =
      { name; params; body }
  end

  module Read = struct
    type t =
      { readers   : Expr.t list
      ; rev_exprs : Expr.t list
      }

    let function_name name =
      "bin_read_" ^ name

    let empty () =
      { readers   = []
      ; rev_exprs = []
      }

    let call ?(conv = []) type_name =
      let buf = Var.named "buf" in
      let pos = Var.named "pos" in
      let read x = `App (`Read x) in
      match type_name, conv with
      | "bool",   []  -> read (`Bin_read_bool   (buf, pos))
      | "char",   []  -> read (`Bin_read_char   (buf, pos))
      | "int",    []  -> read (`Bin_read_int    (buf, pos))
      | "float",  []  -> read (`Bin_read_float  (buf, pos))
      | "string", []  -> read (`Bin_read_string (buf, pos))
      | "list",   [c] -> read (`Bin_read_list   (c, buf, pos))
      | t,        cs  -> read (`Bin_read_custom (t, cs, buf, pos))
  end

  module Write = struct
    type t =
      { writers   : Expr.t list
      ; rev_exprs : Expr.t list
      }

    let function_name type_name =
      "bin_write_" ^ type_name

    let empty () =
      { writers   = []
      ; rev_exprs = []
      }

    let call ?(conv = []) type_name value =
      let buf = Var.named "buf" in
      let pos = Var.named "pos" in
      let write x = `App (`Write x) in
      match type_name, conv with
      | "bool",   []  -> write (`Bin_write_bool   (buf, pos, value))
      | "char",   []  -> write (`Bin_write_char   (buf, pos, value))
      | "int",    []  -> write (`Bin_write_int    (buf, pos, value))
      | "float",  []  -> write (`Bin_write_float  (buf, pos, value))
      | "string", []  -> write (`Bin_write_string (buf, pos, value))
      | "list",   [c] -> write (`Bin_write_list   (c, buf, pos, value))
      | t,        cs  -> write (`Bin_write_custom (t, cs, buf, pos, value))
  end

  module Size = struct
    type t =
      { sizers    : Expr.t list
      ; rev_exprs : Expr.t list
      }

    let function_name type_name =
      "bin_size_" ^ type_name

    let empty () =
      { sizers    = []
      ; rev_exprs = []
      }

    let call ?(conv = []) type_name value =
      let size x = `App (`Size x) in
      match type_name, conv with
      | "bool",   []  -> size (`Bin_size_bool   value)
      | "char",   []  -> size (`Bin_size_char   value)
      | "int",    []  -> size (`Bin_size_int    value)
      | "float",  []  -> size (`Bin_size_float  value)
      | "string", []  -> size (`Bin_size_string value)
      | "list",   [c] -> size (`Bin_size_list   (c, value))
      | t,        cs  -> size (`Bin_size_custom (t, cs, value))
  end

  type t =
    { read  : Read.t
    ; write : Write.t
    ; size  : Size.t
    }

  let empty () =
    { read  = Read.empty ()
    ; write = Write.empty ()
    ; size  = Size.empty ()
    }
end

module Full_type_name = struct
  type t =
    { path : string list
    ; name : string
    }

  let make_path p =
    Filename.basename p
    |> split_on_char '.'
    |> List.filter ~f:((<>) "ml")
    |> List.map ~f:String.capitalize

  let make path name =
    { path = make_path path
    ; name
    }

  let path t =
    t.path

  let name t =
    t.name

  let to_string t =
    let p = t |> path |> String.concat ~sep:"." in
    p ^ "." ^ name t
end
