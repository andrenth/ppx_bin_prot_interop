open Ast_mapper
open Ast_helper
open Asttypes
open Longident
open Parsetree
open Ast_convenience
open Printf

let split_on_char = String.split_on_char
open StdLabels
open Ppx_type_conv.Std

open Ppx_bin_prot_interop_impl
open Interop

let out_dir_base = "interop"

let error loc fmt = Location.raise_errorf ~loc fmt

let var_name i =
  "var_" ^ string_of_int i

let is_abstract ct =
  match ct.ptyp_desc with
  | Ptyp_var _ -> true
  | _          -> false

let init_and_last l =
  let rec loop acc = function
    | [] -> failwith "init_and_last: empty list"
    | [x] -> (List.rev acc, x)
    | x::xs -> loop (x::acc) xs in
  loop [] l

let list_of_lid lid =
  Longident.flatten lid.Location.txt

let string_of_lid lid =
  String.concat "." (list_of_lid lid)

module type OF_TYPE = sig
  val function_name : string -> string
end

let conv_variable_name v =
  "_of__" ^ v

let of_type (module F : OF_TYPE) ct =
  match ct.ptyp_desc with
  | Ptyp_var v -> Var.named (conv_variable_name v)
  | Ptyp_constr (lid, []) ->
      let path, type_name = init_and_last (list_of_lid lid) in
      Expr.funp ~path (F.function_name type_name)
  | _ -> failwith "of_type: unimplemented"

let bound_vars n bindings =
  bindings
  |> List.filter ~f:
    (function
    | `Binding (`Indexed i::_, _) -> i > n && i < n + 200
    | _ -> false)
  |> List.map ~f:
    (function
    | `Binding ((`Indexed _ as v)::_, _) -> v
    | _ -> assert false)

let expr_of_list = function
  | []  -> None
  | [x] -> Some x
  | xs  -> Some (`Tuple xs)

let rec first_bound_variable = function
  | [] -> None
  | `Binding (v::_, _) :: _ -> Some v
  | _ :: exprs -> first_bound_variable exprs

let value_variable depth =
  if depth >= 100 then Var.indexed depth
  else Var.named "v"

let depth_delta = 100

let read_of_constr ftn cts interop depth =
  let vars = [Var.indexed depth; Var.named "pos"] in
  let conv = List.map cts ~f:(fun ct -> of_type (module Read) ct) in
  let reader_params =
    List.filter cts ~f:is_abstract
    |> List.map ~f:(of_type (module Read)) in
  let expr = Expr.bind vars (Read.call ~conv ftn) in
  let open Read in
  { readers   = reader_params @ interop.read.readers
  ; rev_exprs = expr :: interop.read.rev_exprs
  }

let write_of_constr ftn cts interop depth =
  let conv = List.map cts ~f:(fun ct -> of_type (module Write) ct) in
  let writer_params =
    List.filter cts ~f:is_abstract
    |> List.map ~f:(of_type (module Write)) in
  let expr =
    let v = value_variable depth in
    Expr.bind [Var.named "pos"] (Write.call ~conv ftn v) in
  let open Write in
  { writers   = writer_params @ interop.write.writers
  ; rev_exprs = expr :: interop.write.rev_exprs
  }

let size_of_constr ftn cts interop depth =
  let conv = List.map cts ~f:(fun ct -> of_type (module Size) ct) in
  let sizer_params =
    List.filter cts ~f:is_abstract
    |> List.map ~f:(of_type (module Size)) in
  let expr =
    let v = value_variable depth in
    let sum = Expr.add (Var.named "size") (Size.call ~conv ftn v) in
    Expr.bind [Var.named "size"] sum in
  let open Size in
  { sizers    = sizer_params @ interop.size.sizers
  ; rev_exprs = expr :: interop.size.rev_exprs
  }

let read_of_type_param p interop depth =
  let vars = [Var.indexed depth; Var.named "pos"] in
  let var_name = conv_variable_name p in
  let ftn = Full_type_name.make var_name 0 in
  let call = Expr.bin_read_custom ftn (Var.named "buf") (Var.named "pos") in
  let expr = Expr.bind vars call in
  let open Read in
  { readers   = (Var.named var_name) :: interop.read.readers
  ; rev_exprs = expr :: interop.read.rev_exprs
  }

let write_of_type_param p interop depth =
  let var_name = conv_variable_name p in
  let ftn = Full_type_name.make var_name 0 in
  let v = value_variable depth in
  let call = Expr.bin_write_custom ftn (Var.named "buf") (Var.named "pos") v in
  let expr = Expr.bind [Var.named "pos"] call in
  let open Write in
  { writers   = (Var.named var_name) :: interop.write.writers
  ; rev_exprs = expr :: interop.write.rev_exprs
  }

let size_of_type_param p interop depth =
  let var_name = conv_variable_name p in
  let ftn = Full_type_name.make var_name 0 in
  let v = value_variable depth in
  let call = Expr.bin_size_custom ftn v in
  let expr = Expr.bind [Var.named "pos"] call in
  let open Size in
  { sizers    = (Var.named var_name) :: interop.size.sizers
  ; rev_exprs = expr :: interop.size.rev_exprs
  }

let read_of_record names interop depth =
  let open Read in
  let read = interop.read in
  let vars = bound_vars depth read.rev_exprs |> List.rev in
  let r =
    List.fold_left2 names vars ~init:[] ~f:(fun acc n ct -> (n, ct)::acc)
    |> List.rev in
  let record = `Record r in
  let expr = Expr.bind [Var.indexed depth] record in
  { read with rev_exprs = expr :: read.rev_exprs }

let record_rev_bindings names depth var =
  List.fold_left names ~init:([], depth + depth_delta) ~f:
    (fun (bs, d) name ->
      let b = Expr.bind [Var.indexed d] (Expr.get_key name var) in
      (b :: bs, d + 1))
  |> fst

let write_of_record names interop depth var =
  let open Write in
  let rev_bindings = record_rev_bindings names depth var in
  let write = interop.write in
  { write with rev_exprs = write.rev_exprs @ rev_bindings }

let size_of_record names interop depth var =
  let open Size in
  let rev_bindings = record_rev_bindings names depth var in
  let size = interop.size in
  { size with rev_exprs = size.rev_exprs @ rev_bindings }

let read_of_sum interop depth n cases =
  let read_sum_int =
    if n <= 256 then
      Expr.bin_read_int_8bit (Var.named "buf") (Var.named "pos")
    else
      Expr.bin_read_int_16bit (Var.named "buf") (Var.named "pos") in
  let cases = `Default [`Raise (`Sum_tag, None)] :: cases |> List.rev in
  let exprs =
    [ Expr.bind [Var.named "tag"; Var.named "pos"] read_sum_int
    ; `Switch (Var.named "tag", cases)
    ] in
  Read.{ interop.read with
    rev_exprs = (exprs |> List.rev) @ interop.read.rev_exprs
  }

let write_of_sum interop depth var cases =
  let cases = `Default [`Raise (`Sum_tag, None)] :: cases |> List.rev in
  let expr = `Switch (Expr.get_tag (var :> Expr.t), cases) in
  Write.{ interop.write with
    rev_exprs = expr :: interop.write.rev_exprs
  }

let size_of_sum interop depth var cases =
  let cases = `Default [`Raise (`Sum_tag, None)] :: cases |> List.rev in
  let expr = `Switch (Expr.get_tag (var :> Expr.t), cases) in
  Size.{ interop.size with
    rev_exprs = expr :: interop.size.rev_exprs
  }

let tuple_rev_bindings cts depth var =
  List.mapi cts ~f:
    (fun d ct ->
      Expr.bind [Var.indexed (depth + d + depth_delta)] (Expr.get_at d var))
  |> List.rev

let ends_in_binding = function
  | `Binding _ :: _ -> true
  | _ -> false

let rec bin_core_type loc interop depth ct =
  let outer_var = value_variable depth in
  match ct.ptyp_desc with
  | Ptyp_constr (lid, cts) ->
      let ftn = Full_type_name.of_list (list_of_lid lid) (List.length cts) in
      let read  = read_of_constr ftn cts interop depth in
      let write = write_of_constr ftn cts interop depth in
      let size  = size_of_constr ftn cts interop depth in
      { read; write; size }
  | Ptyp_tuple cts ->
      let read  = read_of_tuple loc interop depth cts in
      let write = write_of_tuple loc interop depth outer_var cts in
      let size  = size_of_tuple loc interop depth outer_var cts in
      { read; write; size }
  | Ptyp_variant (row_fields, closed_flag, labels) ->
      let res, wes, ses = bin_variant loc interop depth row_fields in
      let read = read_of_variant interop res in
      let write = write_of_variant interop wes in
      let size = size_of_variant interop ses in
      { read; write; size }
  | Ptyp_var p ->
      let read  = read_of_type_param p interop depth in
      let write = write_of_type_param p interop depth in
      let size  = size_of_type_param p interop depth in
      { read; write; size }
  | _ ->
      error loc "bin_core_type: unimplemented"

and bin_core_types loc interop depth cts =
  List.fold_left cts ~init:(interop, depth + depth_delta) ~f:
    (fun (itr, d) ct ->
      let itr = bin_core_type loc itr d ct in
      (itr, d + 1))
  |> fst

and bin_variant loc interop depth row_fields =
  let outer_depth = depth in

  let read, write, size, _ =
    let z = ([], []) in
    List.fold_left row_fields ~init:(z, z, z, depth + depth_delta) ~f:
      (fun ((ris, rts), (wis, wts), (sis, sts), depth) row_field ->
        match row_field with
        | Rtag (label, attrs, constant, cts) ->
            let var = Var.indexed outer_depth in
            let rt, wt, st, depth = bin_tagged_variant loc depth var label cts in
            ((ris, rt :: rts), (wis, wt :: wts), (sis, st :: sts), depth)
        | Rinherit ct ->
            let itr = bin_core_type loc (Interop.empty ()) depth ct in
            let ris = ris @ itr.read.Read.rev_exprs in
            let wis = wis @ itr.write.Write.rev_exprs in
            let sis = sis @ itr.size.Size.rev_exprs in
            ((ris, rts), (wis, wts), (sis, sts), depth + 1)) in

  let read_inherited,  read_tagged  = read in
  let write_inherited, write_tagged = write in
  let size_inherited,  size_tagged  = size in

  let check_inherited exprs = function
    | [] -> exprs |> List.rev
    | es ->
        List.fold_left es ~init:[] ~f:
          (fun acc e ->
            let e_with_ret =
              match first_bound_variable [e] with
              | Some v -> [e; `Ret [(v :> Expr.t)]]
              | None -> error loc "variant inheritance bug" in
            match acc with
            | [] -> [`Try (e_with_ret, [`No_variant_match, exprs])]
            | _  -> [`Try (e_with_ret, [`No_variant_match, acc])]) in

  let read_exprs =
    let read_tag =
      Expr.bin_read_variant_int (Var.named "buf") (Var.named "pos") in
    let default = `Default [`Raise (`No_variant_match, None)] in
    let cases = default :: read_tagged |> List.rev in
    let exprs =
      [ Expr.bind [Var.indexed outer_depth] (Lit.string "__dummy__")
      ; Expr.bind [Var.named "vint"; Var.named "pos"] read_tag
      ; `Switch (Var.named "vint", cases)
      ] in
    check_inherited exprs read_inherited in

  let write_exprs =
    let default = `Default [`Raise (`No_variant_match, None)] in
    let cases = (default :: write_tagged) |> List.rev in
    let v = value_variable depth in
    let expr = `Switch (Expr.get_tag v, cases) in
    check_inherited [expr] write_inherited in

  let size_exprs =
    let default = `Default [`Raise (`No_variant_match, None)] in
    let cases = (default :: size_tagged) |> List.rev in
    let v = value_variable depth in
    let expr = `Switch (Expr.get_tag v, cases) in
    check_inherited [expr] size_inherited in

  (read_exprs, write_exprs, size_exprs)

and bin_tagged_variant loc depth var label cts =
  let hash = Btype.hash_variant label in
  let itr = bin_core_types loc (Interop.empty ()) depth cts in
  let read_case =
    let open Read in
    let vars = bound_vars depth itr.read.rev_exprs |> List.rev in
    let arg = expr_of_list vars in
    let binding = Expr.bind [var] (`Variant (label, arg)) in
    let exprs = binding :: itr.read.rev_exprs |> List.rev in
    `Case (Lit.int hash, exprs, true) in
  let write_case =
    let open Write in
    let call =
      Expr.bin_write_variant_int
        (Var.named "buf")
        (Var.named "pos")
        (Lit.int hash) in
    let bindings =
      let value = Expr.get_value (var :> Expr.t) in
      [ Expr.bind [Var.indexed (depth + depth_delta)] value
      ; Expr.bind [Var.named "pos"] call
      ] in
    let exprs = bindings @ List.rev itr.write.rev_exprs in
    `Case (Lit.string label, exprs, true) in
  let size_case =
    let open Size in
    let bindings =
      let sum_vint_size = Expr.add (Var.named "size") (Lit.int 4) in
      let value = Expr.get_value (var :> Expr.t) in
      [ Expr.bind [Var.named "size"] sum_vint_size
      ; Expr.bind [Var.indexed (depth + depth_delta)] value
      ] in
    let exprs = (itr.size.rev_exprs @ bindings) |> List.rev in
    `Case (Lit.string label, exprs, true) in
  (read_case, write_case, size_case, depth + 1)

and bin_record loc interop depth outer_var lds =
  let names, cts =
    List.map lds ~f:(fun ld -> (ld.pld_name.Location.txt, ld.pld_type))
    |> List.split in
  let itr = bin_core_types loc interop depth cts in
  let read = read_of_record names itr depth in
  let write = write_of_record names itr depth outer_var in
  let size = size_of_record names itr depth outer_var in
  { read; write; size }

and bin_sum loc interop depth cds =
  let outer_var = value_variable depth in
  let n = List.length cds in
  let read_cases, write_cases, size_cases, _ =
    List.fold_left cds ~init:([], [], [], 0) ~f:
      (fun (read_cases, write_cases, size_cases, d) cd ->
        let loc = cd.pcd_loc in
        if cd.pcd_res <> None then error loc "GADTs are not supported";
        let name = cd.pcd_name.Location.txt in
        let itr, arg =
          match cd.pcd_args with
          | Pcstr_tuple cts -> sum_tuple loc interop depth outer_var cts name
          | Pcstr_record lds -> sum_record loc interop depth outer_var lds in
        let rc = sum_read_case name arg itr d in
        let wc = sum_write_case loc name itr d n in
        let sc = sum_size_case loc name itr d n in
        (rc :: read_cases, wc :: write_cases, sc :: size_cases, d + 1)) in
  let read  = read_of_sum interop depth n read_cases in
  let write = write_of_sum interop depth outer_var write_cases in
  let size  = size_of_sum interop depth outer_var size_cases in
  { read; write; size }

and sum_read_case name arg itr d =
  let exprs =
    let ret = `Ret [`Sum (name, arg)] in
    let es =
      match itr.read.Read.rev_exprs with
      | [] -> [ret]
      | es when ends_in_binding es -> ret :: es
      | es -> es in
    es |> List.rev in
  `Case (Lit.int d, exprs, false)

and sum_write_case loc name itr d n =
  let write_int =
    let f =
      if n <= 256 then Expr.bin_write_int_8bit
      else if n <= 65536 then Expr.bin_write_int_16bit
      else error loc "too many alternatives (%d > 65536)" n in
    f (Var.named "buf") (Var.named "pos") (Lit.int d) in
  let binding = Expr.bind [Var.named "pos"] write_int in
  let exprs =
    let ret = `Ret [Var.named "pos"] in
    let es =
      match itr.write.Write.rev_exprs with
      | [] -> [ret]
      | es when ends_in_binding es -> ret :: es
      | es -> es in
    es |> List.rev in
  `Case (Lit.string name, binding :: exprs, false)

and sum_size_case loc name itr d n =
  let add_int =
    let i =
      if n <= 256 then 1
      else if n <= 65536 then 2
      else error loc "too many alternatives (%d > 65536)" n in
    Expr.add (Var.named "size") (Lit.int i) in
  let binding = Expr.bind [Var.named "size"] add_int in
  let exprs =
    let ret = `Ret [Var.named "size"] in
    let es =
      match itr.size.Size.rev_exprs with
      | [] -> [ret]
      | es when ends_in_binding es -> ret :: es
      | es -> es in
    es |> List.rev in
  `Case (Lit.string name, binding :: exprs, false)

and read_of_tuple loc interop depth cts =
  let open Read in
  let itr = bin_core_types loc interop depth cts in
  let tuple = `Tuple (bound_vars depth itr.read.rev_exprs |> List.rev) in
  let expr = Expr.bind [Var.indexed depth] tuple in
  { itr.read with
    rev_exprs = expr :: itr.read.rev_exprs
  }

and write_of_tuple loc interop depth var cts =
  let open Write in
  let rev_bindings = tuple_rev_bindings cts depth var in
  let itr = bin_core_types loc interop depth cts in
  { itr.write with
    rev_exprs = itr.write.rev_exprs @ rev_bindings
  }

and size_of_tuple loc interop depth var cts =
  let open Size in
  let rev_bindings = tuple_rev_bindings cts depth var in
  let itr = bin_core_types loc interop depth cts in
  { itr.size with
    rev_exprs = itr.size.rev_exprs @ rev_bindings
  }

and sum_tuple loc interop depth var cts name =
  let value = Var.named "value" in
  let binding = Expr.bind [value] (Expr.get_value var) in
  let itr =
    match cts with
    | []   -> interop
    | [ct] ->
        let itr = bin_core_type loc interop depth ct in
        let write = itr.write in
        let write =
          Write.{ write with rev_exprs = write.rev_exprs @ [binding] } in
        let size = itr.size in
        let size =
          Size.{ size with rev_exprs = size.rev_exprs @ [binding] } in
        { itr with write; size }
    | _    ->
        let read  = read_of_tuple loc interop depth cts in
        let write = write_of_tuple loc interop depth value cts in
        let size  = size_of_tuple loc interop depth value cts in
        let write =
          Write.{ write with rev_exprs = write.rev_exprs @ [binding] } in
        let size  =
          Size.{ size with rev_exprs = size.rev_exprs @ [binding] } in
        { read; write; size } in
  let arg =
    match first_bound_variable itr.read.Read.rev_exprs with
    | Some v -> Some (v :> Expr.t)
    | None -> None in
  (itr, arg)

and sum_record loc interop depth var lds =
  let value = Var.named "value" in
  let binding = Expr.bind [value] (Expr.get_value var) in
  let itr = bin_record loc interop depth value lds in
  let write = itr.write in
  let write =
    Write.{ write with rev_exprs = write.rev_exprs @ [binding] } in
  let size = itr.size in
  let size =
    Size.{ size with rev_exprs = size.rev_exprs @ [binding] } in
  let arg =
    match first_bound_variable itr.read.Read.rev_exprs with
    | Some v -> Some (v :> Expr.t)
    | None -> error loc "read sum record bug" in
  ({ itr with write; size }, arg)

and read_of_variant interop exprs =
  let open Read in
  { interop.read with rev_exprs = exprs @ interop.read.rev_exprs }

and write_of_variant interop exprs =
  let open Write in
  { interop.write with rev_exprs = exprs @ interop.write.rev_exprs }

and size_of_variant interop exprs =
  let open Size in
  { interop.size with rev_exprs = exprs @ interop.size.rev_exprs }

let make_read_function type_name read =
  let open Read in
  let params =
    Var.named "pos" :: Var.named "buf" :: read.readers |> List.rev in
  let function_body =
    let rev_exprs = read.rev_exprs in
    let ret =
      match first_bound_variable rev_exprs with
      | Some var -> (`Ret [(var :> Expr.t); Var.named "pos"] :: rev_exprs)
      | None -> rev_exprs in
    ret |> List.rev in
  Fun_decl.make (Read.function_name type_name) params function_body

let make_write_function type_name write =
  let open Write in
  let params =
    Var.named "v" :: Var.named "pos" :: Var.named "buf" :: write.writers
    |> List.rev in
  let function_body =
    `Ret [Var.named "pos"] :: write.rev_exprs |> List.rev in
  Fun_decl.make (Write.function_name type_name) params function_body

let make_size_function type_name size =
  let open Size in
  let params = Var.named "v" :: size.sizers |> List.rev in
  let function_body =
    let rev_exprs = size.rev_exprs in
    let init = Expr.bind [Var.named "size"] (Lit.int 0) in
    let ret = `Ret [Var.named "size"] in
    init :: (ret :: rev_exprs |> List.rev) in
  Fun_decl.make (Size.function_name type_name) params function_body

module PHP = Ppx_bin_prot_interop_php

let bin_interop ~loc ~path (rec_flag, type_decls) php =
  let full_type_names, reads, writes, sizes =
    List.fold_left type_decls ~init:([], [], [], []) ~f:
      (fun (ftns, reads, writes, sizes) td ->
        let type_name = td.ptype_name.Location.txt in
        let num_params = List.length td.ptype_params in
        let ftn = Full_type_name.make ~path type_name num_params in
        let interop =
          let itr = Interop.empty () in
          match td.ptype_kind with
          | Ptype_variant cds -> bin_sum loc itr 0 cds
          | Ptype_record lds -> bin_record loc itr 0 (Var.named "v") lds
          | Ptype_open -> error loc "open types not yet supported"
          | Ptype_abstract ->
              match td.ptype_manifest with
              | Some ct -> bin_core_type loc itr 0 ct
              | None -> error loc "nil not implemented" in
        let read  = make_read_function type_name interop.read in
        let write = make_write_function type_name interop.write in
        let size  = make_size_function type_name interop.size in
        (ftn :: ftns, read :: reads, write :: writes, size :: sizes)) in
  let reads  = reads  |> List.rev in
  let writes = writes |> List.rev in
  let sizes  = sizes  |> List.rev in
  if php then
    PHP.interop ~out_dir_base ~full_type_names ~reads ~writes ~sizes;
  []

let gen_bin_interop =
  let args =
    Type_conv.Args.(
      empty
      +> flag "php"
    ) in
  Type_conv.Generator.make args bin_interop

let () =
  let bin_interop =
    Type_conv.add
      "bin_interop"
      ~str_type_decl:gen_bin_interop in
  let set = [bin_interop] in
  Type_conv.add_alias "bin_io_interop" set ~str_type_decl:set
  |> Type_conv.ignore
