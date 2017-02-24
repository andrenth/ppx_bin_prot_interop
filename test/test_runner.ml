open StdLabels
open Printf

type lang =
  { name : string
  ; ext  : string
  }

let languages =
  [ { name = "php"; ext = "php" }
  ]

let tests =
  [ "basic"
  ; "list"
  ; "tuple"
  ; "variant"
  ; "record"
  ; "sum"
  ; "parametrized"
  ]

let readlines name =
  let ic = open_in name in
  let try_read () =
    try Some (input_line ic) with End_of_file -> None in
  let rec loop acc = match try_read () with
    | Some s -> loop (acc ^ "\n" ^ s)
    | None -> close_in ic; acc in
  loop ""

let each_dir_entry dir ~f =
  let d = Unix.opendir dir in
  let rec readdir () =
    try
      let e = Unix.readdir d in
      if e <> "." && e <> ".." then
        f e;
      readdir ()
    with End_of_file ->
      () in
  readdir ()

let interop_dir ~lang test_name =
  let file_name = test_name |> String.capitalize in
  sprintf "./interop/%s/%s" lang.name file_name

let expected_dir ~lang test_name =
  let file_name = test_name |> String.capitalize in
  sprintf "./test/expected/%s/%s" lang.name file_name

let run_test name =
  let r = Sys.command (sprintf "./_build/ppx ./test/%s.ml" name) in
  assert (r = 0);
  List.iter languages ~f:
    (fun lang ->
      let edir = expected_dir ~lang name in
      let idir = interop_dir  ~lang name in
      each_dir_entry edir ~f:
        (fun file ->
          let efile = sprintf "%s%s%s" edir Filename.dir_sep file in
          let ifile = sprintf "%s%s%s" idir Filename.dir_sep file in
          let res = readlines ifile in
          let exp = readlines efile in
          if res <> exp then
            printf "FAIL - %s <> %s\n%!" ifile efile))

let () =
  List.iter tests ~f:run_test
