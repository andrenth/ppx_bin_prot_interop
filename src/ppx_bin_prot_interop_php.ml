open Printf
open StdLabels

open Ppx_bin_prot_interop_impl
open Interop

let indent_level = 4

let expr_terminator s =
  if s.[String.length s - 1] = '}'
  then s
  else s ^ ";"

let string_of_var = function
  | `Indexed i -> "$var_" ^ string_of_int i
  | `Named s -> "$" ^ s

let string_of_lit = function
  | `Int i -> string_of_int i
  | `String s -> "\"" ^ s ^ "\""

let string_of_error = function
  | `Empty_type       _ -> "bin_prot\\exceptions\\EmptyType"
  | `No_variant_match   -> "bin_prot\\exceptions\\NoVariantMatch"
  | `Sum_tag            -> "bin_prot\\exceptions\\SumTag"


let is_builtin = function
  | "bool" | "char" | "int" | "float" | "string" | "list"  -> true
  | _                                                      -> false

let starts_with s str =
  let len = String.length s in
  if len > String.length str then false
  else s = String.sub str 0 len

let is_function_pointer = starts_with "_of__"

let path_to_namespace =
  String.concat ~sep:"\\"

let namespaced path name =
  match path with
  | [] -> name
  | _  -> sprintf "%s\\%s" (path_to_namespace path) name

let rec string_of_expr ?(pad = 0) expr =
  let padding = String.make pad ' ' in
  match expr with
  | #Lit.t as l -> string_of_lit l
  | #Var.t as v -> string_of_var v
  | `Add (e1, e2) -> sprintf "%s + %s" (string_of_expr e1) (string_of_expr e2)
  | `Binding (vars, expr) ->
      let s =
        match vars with
        | []  -> assert false
        | [v] -> sprintf "%s = %s" (string_of_var v) (string_of_expr expr)
        | _   ->
            let vars =
              List.map vars ~f:string_of_var
              |> String.concat ~sep:", " in
            sprintf "list(%s) = %s" vars (string_of_expr expr) in
      sprintf "%s%s" padding s
  | `App app ->
      sprintf "%s%s" padding (string_of_app app)
  | `Ret [] ->
      sprintf "%sreturn" padding
  | `Ret [e] ->
      sprintf "%sreturn %s" padding (string_of_expr e)
  | `Ret (es : Expr.t list) ->
      let s = String.concat ", " (List.map es ~f:string_of_expr) in
      sprintf "%sreturn array(%s)" padding s
  | `Raise (e, msg) ->
      let e = string_of_error e in
      let msg =
        match msg with
        | Some s -> s
        | None   -> "" in
      sprintf "%sthrow new %s(%s)" padding e msg
  | `Tuple es ->
      let s = String.concat ", " (List.map es ~f:string_of_expr) in
      sprintf "%sarray(%s)" padding s
  | `Record labels ->
      let args =
        List.map labels ~f:
          (fun (name, e) ->
            sprintf "\"%s\" => %s" name (string_of_expr e))
        |> String.concat ~sep:", " in
      sprintf "%sarray(%s)" padding args
  | `Variant (label, param) ->
      string_of_variant_or_sum padding label param
  | `Sum (label, param) ->
      string_of_variant_or_sum padding label param
  | `Switch (e, cases) ->
      let init = sprintf "%sswitch (%s) {\n" padding (string_of_expr e) in
      List.fold_left cases ~init ~f:
        (fun acc case -> acc ^ string_of_case ~pad case)
      ^ sprintf "%s}" padding
  | `Try (es, rs) ->
      let s = string_of_exprs ~pad:(pad + indent_level) es in
      let catches =
        List.map rs ~f:
          (fun (ex, es) ->
            let es = string_of_exprs ~pad:(pad + indent_level) es in
            let ex = string_of_error ex in
            sprintf "%scatch (%s $e) {\n%s\n%s}" padding ex es padding) in
      let try_ = sprintf "%stry {\n%s\n%s}" padding s padding in
      begin match catches with
      | [] -> try_
      | cs -> try_ ^ "\n" ^ String.concat ~sep:"\n" cs
      end
  | `Function_pointer ([], f) ->
      let ns =
        if starts_with "bin_read_" f       then "bin_prot\\read"
        else if starts_with "bin_write_" f then "bin_prot\\write"
        else if starts_with "bin_size_"  f then "bin_prot\\size"
        else failwith (sprintf "unexpected function reference '%s'" f) in
      sprintf "'%s\\%s'" ns f
  | `Function_pointer (path, f) ->
      sprintf "'%s'" (namespaced path f)

and string_of_exprs ?(pad = 0) es =
  es
  |> List.map ~f:(fun e -> string_of_expr ~pad e |> expr_terminator)
  |> String.concat ~sep:"\n"

and string_of_variant_or_sum padding label param =
  let s =
    match param with
    | Some e -> string_of_expr e
    | None   -> "null" in
  sprintf "%sarray(\"%s\", %s)" padding label s

and string_of_app = function
  | `Read  fn -> string_of_read_function  fn
  | `Write fn -> string_of_write_function fn
  | `Size  fn -> string_of_size_function  fn
  | `Get   fn -> string_of_get_function   fn

and string_of_read_function fn =
  let ns = "bin_prot\\read" in
  let to_string = string_of_expr in
  match fn with
  | `Bin_read_int_8bit (buf, pos) ->
      sprintf "%s\\bin_read_int_8bit(%s, %s)"
        ns (to_string buf) (to_string pos)
  | `Bin_read_int_16bit (buf, pos) ->
      sprintf "%s\\bin_read_int_16bit(%s, %s)"
        ns (to_string buf) (to_string pos)
  | `Bin_read_variant_int (buf, pos) ->
      sprintf "%s\\bin_read_variant_int(%s, %s)"
        ns (to_string buf) (to_string pos)
  | `Bin_read_bool (buf, pos) ->
      sprintf "%s\\bin_read_bool(%s, %s)"
        ns (to_string buf) (to_string pos)
  | `Bin_read_char (buf, pos) ->
      sprintf "%s\\bin_read_char(%s, %s)"
        ns (to_string buf) (to_string pos)
  | `Bin_read_int (buf, pos) ->
      sprintf "%s\\bin_read_int(%s, %s)"
        ns (to_string buf) (to_string pos)
  | `Bin_read_float (buf, pos) ->
      sprintf "%s\\bin_read_float(%s, %s)"
        ns (to_string buf) (to_string pos)
  | `Bin_read_string (buf, pos) ->
      sprintf "%s\\bin_read_string(%s, %s)"
        ns (to_string buf) (to_string pos)
  | `Bin_read_list (conv, buf, pos) ->
      sprintf "%s\\bin_read_list(%s, %s, %s)"
        ns (to_string conv) (to_string buf) (to_string pos)
  | `Bin_read_custom (ftn, [], buf, pos) ->
      let name = ftn |> Full_type_name.name in
      let prefix = if is_function_pointer name then "$" else "bin_read_" in
      let base = sprintf "%s%s" prefix name in
      let full = namespaced (Full_type_name.path ftn) base in
      sprintf "%s(%s, %s)" full (to_string buf) (to_string pos)
  | `Bin_read_custom (ftn, convs, buf, pos) ->
      let name = ftn |> Full_type_name.name in
      let prefix = if is_function_pointer name then "$" else "bin_read_" in
      let base = sprintf "%s%s" prefix name in
      let full = namespaced (Full_type_name.path ftn) base in
      let reader_args =
        String.concat ~sep:", " (List.map convs ~f:to_string) in
      sprintf "%s(%s, %s, %s)" full reader_args (to_string buf) (to_string pos)

and string_of_write_function fn =
  let ns = "bin_prot\\write" in
  let to_string = string_of_expr in
  match fn with
  | `Bin_write_int_8bit (buf, pos, value) ->
      sprintf "%s\\bin_write_int_8bit(%s, %s, %s)"
        ns (to_string buf) (to_string pos) (to_string value)
  | `Bin_write_int_16bit (buf, pos, value) ->
      sprintf "%s\\bin_write_int_8bit(%s, %s, %s)"
        ns (to_string buf) (to_string pos) (to_string value)
  | `Bin_write_variant_int (buf, pos, value) ->
      sprintf "%s\\bin_write_variant_int(%s, %s, %s)"
        ns (to_string buf) (to_string pos) (to_string value)
  | `Bin_write_bool (buf, pos, value) ->
      sprintf "%s\\bin_write_bool(%s, %s, %s)"
        ns (to_string buf) (to_string pos) (to_string value)
  | `Bin_write_char (buf, pos, value) ->
      sprintf "%s\\bin_write_char(%s, %s, %s)"
        ns (to_string buf) (to_string pos) (to_string value)
  | `Bin_write_int (buf, pos, value) ->
      sprintf "%s\\bin_write_int(%s, %s, %s)"
        ns (to_string buf) (to_string pos) (to_string value)
  | `Bin_write_float (buf, pos, value) ->
      sprintf "%s\\bin_write_float(%s, %s, %s)"
        ns (to_string buf) (to_string pos) (to_string value)
  | `Bin_write_string (buf, pos, value) ->
      sprintf "%s\\bin_write_string(%s, %s, %s)"
        ns (to_string buf) (to_string pos) (to_string value)
  | `Bin_write_list (conv, buf, pos, value) ->
      sprintf "%s\\bin_write_list(%s, %s, %s, %s)"
        ns (to_string conv) (to_string buf) (to_string pos) (to_string value)
  | `Bin_write_custom (ftn, [], buf, pos, value) ->
      let name = ftn |> Full_type_name.name in
      let prefix = if is_function_pointer name then "$" else "bin_write_" in
      let base = sprintf "%s%s" prefix name in
      let full = namespaced (Full_type_name.path ftn) base in
      sprintf "%s(%s, %s, %s)"
        full (to_string buf) (to_string pos) (to_string value)
  | `Bin_write_custom (ftn, convs, buf, pos, value) ->
      let name = ftn |> Full_type_name.name in
      let prefix = if is_function_pointer name then "$" else "bin_write_" in
      let base = sprintf "%s%s" prefix name in
      let full = namespaced (Full_type_name.path ftn) base in
      let writer_args =
        String.concat ~sep:", " (List.map convs ~f:to_string) in
      sprintf "%s(%s, %s, %s, %s)"
        full writer_args (to_string buf) (to_string pos) (to_string value)

and string_of_size_function fn =
  let ns = "bin_prot\\size" in
  let to_string = string_of_expr in
  match fn with
  | `Bin_size_int_8bit value ->
      sprintf "%s\\bin_size_int_8bit(%s)" ns (to_string value)
  | `Bin_size_int_16bit value ->
      sprintf "%s\\bin_size_int_16bit(%s)" ns (to_string value)
  | `Bin_size_variant_int value ->
      sprintf "%s\\bin_size_variant_int(%s)" ns (to_string value)
  | `Bin_size_bool value ->
      sprintf "%s\\bin_size_bool(%s)" ns (to_string value)
  | `Bin_size_char value ->
      sprintf "%s\\bin_size_char(%s)" ns (to_string value)
  | `Bin_size_int value ->
      sprintf "%s\\bin_size_int(%s)" ns (to_string value)
  | `Bin_size_float value ->
      sprintf "%s\\bin_size_float(%s)" ns (to_string value)
  | `Bin_size_string value ->
      sprintf "%s\\bin_size_string(%s)" ns (to_string value)
  | `Bin_size_list (conv, value) ->
      sprintf "%s\\bin_size_list(%s, %s)" ns (to_string conv) (to_string value)
  | `Bin_size_custom (ftn, [], value) ->
      let name = ftn |> Full_type_name.name in
      let prefix = if is_function_pointer name then "$" else "bin_size_" in
      let base = sprintf "%s%s" prefix name in
      let full = namespaced (Full_type_name.path ftn) base in
      sprintf "%s(%s)" full (to_string value)
  | `Bin_size_custom (ftn, convs, value) ->
      let name = ftn |> Full_type_name.name in
      let prefix = if is_function_pointer name then "$" else "bin_size_" in
      let base = sprintf "%s%s" prefix name in
      let full = namespaced (Full_type_name.path ftn) base in
      let sizer_args =
        String.concat ~sep:", " (List.map convs ~f:to_string) in
      sprintf "%s(%s, %s)" full sizer_args (to_string value)

and string_of_get_function = function
  | `At  (e, i) -> sprintf "%s[%d]"     (string_of_expr e) i
  | `Key (e, s) -> sprintf "%s[\"%s\"]" (string_of_expr e) s
  | `Tag e      -> sprintf "%s[0]"      (string_of_expr e)
  | `Value e    -> sprintf "%s[1]"      (string_of_expr e)

and string_of_case ?(pad = 0) case =
  let padding = String.make pad ' ' in
  let string_of_exprs = string_of_exprs ~pad:(pad + indent_level) in
  let string_of_break b =
    if b then
      let padding = String.make (pad + indent_level) ' ' in
      sprintf "%sbreak;\n" padding
    else
      "" in
  match case with
  | `Case (l, es, break) ->
      sprintf "%scase %s:\n%s\n%s"
        padding
        (string_of_lit l)
        (string_of_exprs es)
        (string_of_break break)
  | `Default es ->
      sprintf "%sdefault:\n%s\n" padding (string_of_exprs es)

let string_of_interop ?(pad = 0) f =
  let open Fun_decl in
  let padding = String.make pad ' ' in
  let params =
    List.map f.params ~f:string_of_expr
    |> String.concat ~sep:", " in
  let body =
    List.map f.body ~f:
      (fun e -> string_of_expr ~pad:(pad + indent_level) e |> expr_terminator)
    |> String.concat ~sep:"\n" in
  sprintf "%sfunction %s(%s) {\n%s\n%s}" padding f.name params body padding

let header =
  "<?php\n\n"

let type_header ?(pad = 0) ftn =
  let ns = ftn |> Full_type_name.path |> String.concat ~sep:"\\" in
  sprintf "namespace %s;\n\n" ns

let define_function ?(pad = 0) fn =
  sprintf "%s\n\n" (string_of_interop ~pad fn)

let function_prefixes = ["bin_read_"; "bin_write_"; "bin_size_"]

let define_standard_typeclass ?(pad = 0) name =
  let fns = List.map function_prefixes ~f:(fun p -> sprintf "%s%s" p name) in
  let parent_constr_args = String.concat ~sep:", " fns in
  let indent1 = String.make pad ' ' in
  let indent2 = String.make (pad + indent_level) ' ' in
  let indent3 = String.make (pad + 2 * indent_level) ' ' in
  sprintf "%sclass bin_%s extends bin_prot\\type_class\\type_class {\n"
    indent1 name
  ^
  sprintf "%spublic function __construct()\n%s{\n"
    indent2 indent2
  ^
  sprintf "%sparent::__construct(%s);\n%s}\n%s}\n"
    indent3 parent_constr_args indent2 indent1

let define_lambda ?(pad = 0) kind name params type_args =
  let indent k =
    String.make (pad + k * indent_level) ' ' in
  let args = String.concat ~sep:", " type_args in
  let calls =
    List.map type_args ~f:(fun arg -> sprintf "%s->%s()" arg kind)
    |> String.concat ~sep:", " in
  sprintf "%s$this->_%s = function(%s) use (%s) {\n"
    (indent 1) kind params args
  ^
  sprintf "%sbin_%s_%s(%s, %s);\n%s};\n"
    (indent 2) kind name calls params (indent 1)

let define_higher_order_typeclass ?(pad = 0) name num_params =
  let constr_params =
    let arr = Array.make num_params "" in
    for i = 0 to num_params - 1 do
      arr.(i) <- sprintf "$bin%d" i
    done;
    Array.to_list arr in
  let indent k =
    String.make (pad + k * indent_level) ' ' in
  let constr_params_str = String.concat ~sep:", " constr_params in
  let lambda_pad = pad + indent_level in
  sprintf "%sclass bin_%s extends bin_prot\\type_class\\type_class {\n"
    (indent 0) name
  ^
  sprintf "%spublic function __construct(%s)\n%s{\n"
    (indent 1) constr_params_str (indent 1)
  ^
  define_lambda ~pad:lambda_pad "read" name "$buf, $pos" constr_params
  ^
  define_lambda ~pad:lambda_pad "write" name "$buf, $pos, $v" constr_params
  ^
  define_lambda ~pad:lambda_pad "size" name "$v" constr_params
  ^
  sprintf "%s}\n%s}\n" (indent 1) (indent 0)

let define_typeclass ?(pad = 0) ftn =
  let name       = ftn |> Full_type_name.name in
  let num_params = ftn |> Full_type_name.num_params in
  if num_params = 0 then
    define_standard_typeclass ~pad name
  else
    define_higher_order_typeclass ~pad name num_params

let define_interop ?(pad = 0) ~read ~write ~size ftn =
  define_function ~pad read
  ^ define_function ~pad write
  ^ define_function ~pad size
  ^ define_typeclass ~pad ftn

let mkdir_p path =
  let sep = Filename.dir_sep in
  let mkdir dir =
    try Unix.mkdir dir 0o755
    with Unix.Unix_error (Unix.EEXIST, _, _) -> () in
  List.fold_left path ~init:"" ~f:
    (fun acc p ->
      let acc = if acc = "" then p else sprintf "%s%s%s" acc sep p in
      mkdir acc;
      acc)

module FileMap =
  Map.Make(struct
    type t = string
    let compare = compare
  end)

  let add_or_init k v m =
    try
      let l = FileMap.find k m in
      FileMap.add k (v::l) m
    with Not_found ->
      FileMap.add k [v] m

let interop ~out_dir_base ~full_type_names ~reads ~writes ~sizes =
  let sep = Filename.dir_sep in
  let rec loop = function
    | ftn::ftns, r::rs, w::ws, s::ss ->
        let name = ftn |> Full_type_name.name in
        let path = ftn |> Full_type_name.path in
        let out_dir = mkdir_p (out_dir_base :: "php" :: path) in
        let file = sprintf "%s%s%s.php" out_dir sep name in
        let code = define_interop ~pad:0 ~read:r ~write:w ~size:s ftn in
        let ch = open_out file in
        fprintf ch "%s%s%s" header (type_header ftn) code;
        close_out ch;
        loop (ftns, rs, ws, ss)
    | [], [], [], [] -> ()
    |  _,  _,  _,  _ -> failwith "PHP interop bug" in
  loop (full_type_names, reads, writes, sizes)
