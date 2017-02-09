type simple = int * float [@@deriving bin_io_interop ~php]
type nested1 = int * (string * char) * float [@@deriving bin_io_interop ~php]
type nested2 = int * (string * (bool * int) * char) * float [@@deriving bin_io_interop ~php]
