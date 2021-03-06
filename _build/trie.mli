module Trie_func : sig
  type t

  val empty : unit -> t

  val extract_st_option : (string * t) option -> string * t

  val extract_t_option : t option -> t

  val word_to_list : string -> string list

  val return_child_opt : (string * t) list -> string -> t option

  val trie_insert : t -> string list -> t

  val trie_contains_word : t -> string list -> bool

  val trie_contains : t -> string list -> bool

  val trie_instantiate : string list -> t
end
