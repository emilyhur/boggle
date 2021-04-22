open Trie
open Board

val corpus : string

(* CORPUS STUFF *)
(* TODO FOR RICHARD : fix and mli the stuff from read_whole_file to
 filtered_list*)

(* implements the Trie_func module *)
module Trie_module = Trie_func

(* creates a trie with all the words in our corpus *)
val word_trie : Trie_module.t 

(* Array of the adjacent tiles of each tile in a 4x4 board, position of tile 
  corresponds to the index. *)
val adjacent_tiles : int list array

(* Recursive component of the Boggle DFS algorithm. Modified version of the 
  List.fold_left function that folds through adjacent tiles to the current tile,
  accumulating all the found words together. For each of the adjacent tiles,
  the function checks if the new word formed with adjacent letter exists in
  the trie, if it is a valid word, and calls find_helper to recur deeper
  to find more words accordingly. Returns a list of all found strings *)
val fold_custon : string -> int -> Board.board -> int list -> string list 
  -> int list -> string list

(* helper function in the Boggle DFS algorithm. Given a tile location in a 
  boggle board, calls the fold_custom recursive functions and passes in the 
  adjacent tiles. *)
val find_helper : string -> int -> Board.board -> string list -> int list 
  -> string list

(* a modified version List.fold_left that also passes along the index [ind]
  of the current head of in the original starting list [l]. Sort of like an
  incrementing counter in a for loop *)  
val fold_left_ind : (string list -> string -> int -> string list) -> string list
  -> string list -> int -> string list

(* finds all possible words that exist inside a given Boggle board. Returns a
string list of unique words. *)  
val find_possible_words : Board.board -> string list
