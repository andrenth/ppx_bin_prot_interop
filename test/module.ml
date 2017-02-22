type t = int [@@deriving bin_io_interop ~php]

module M = struct
  type t = string [@@deriving bin_io_interop ~php]

  module N = struct
    type t = bool [@@deriving bin_io_interop ~php]
  end
end

type u =
  { x : t
  ; y : M.t
  ; z : M.N.t
  } [@@deriving bin_io_interop ~php]
