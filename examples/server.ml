open Core
open Async

module M = struct
  type r = { i: int; s: string } [@@deriving bin_io, bin_io_interop ~php]
  type t =
    | I of int
    | S of string
    | R of r
    [@@deriving bin_io, bin_io_interop ~php]

  let rpc = Rpc.Rpc.create
    ~name:"M.t"
    ~version:0
    ~bin_query:bin_t
    ~bin_response:bin_t

  let rpc_impl () = function
    | I i ->
        Log.Global.info "Got (I %d)" i;
        return (I (i + 1))
    | S s ->
        Log.Global.info "Got (S %s)" s;
        return (S (String.rev s))
    | R { i; s } ->
        Log.Global.info "Got (R { %d; %s })" i s;
        return (R { i = i + 1; s = String.rev s})
end

let implementations =
  [ Rpc.Rpc.implement M.rpc M.rpc_impl ]

let port_arg () =
  Command.Spec.(
    flag "-port" (optional_with_default 8124 int)
      ~doc:" Server's port"
  )

let start_server ~env ?(stop=Deferred.never ()) ~implementations ~port () =
  Log.Global.info "Starting server on %d" port;
  let implementations =
    Rpc.Implementations.create_exn ~implementations
      ~on_unknown_rpc:(`Call (fun _st ~rpc_tag ~version ->
        Log.Global.info "Unexpected RPC, tag %s, version %d" rpc_tag version;
        `Continue))
  in
  Tcp.Server.create
    ~on_handler_error:(`Call (fun _ exn -> Log.Global.sexp (Exn.sexp_of_t exn)))
    (Tcp.on_port port)
    (fun _addr r w ->
      Rpc.Connection.server_with_close r w
        ~connection_state:(fun _ -> env)
        ~on_handshake_error:(
          `Call (fun exn -> Log.Global.sexp (Exn.sexp_of_t exn); return ()))
        ~implementations
    )
  >>= fun server ->
  Log.Global.info "Server started, waiting for close";
  Deferred.any
    [ (stop >>= fun () -> Tcp.Server.close server)
    ; Tcp.Server.close_finished server ]

let command =
  Command.async
    ~summary:"Example server"
    Command.Spec.(
      empty +> port_arg ()
    )
    (fun port () -> start_server ~env:() ~port ~implementations ())

let () = Command.run command
