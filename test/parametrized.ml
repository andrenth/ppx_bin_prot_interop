module P1 = struct
  type 'a t = 'a list [@@deriving bin_io_interop ~php]
end

module P2 = struct
  type ('a, 'b) t = 'a * 'b list [@@deriving bin_io_interop ~php]
end
