open Ppx_bin_prot_interop_impl
open Interop

module type S = sig
  val interop : out_dir_base:string
             -> full_type_names:Full_type_name.t list
             -> reads:Fun_decl.t list
             -> writes:Fun_decl.t list
             -> sizes:Fun_decl.t list
             -> unit
end
