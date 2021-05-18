open Trie
open Board
open Words
open ANSITerminal
open Art
open Score
open Trie_func

let validate_words
    (trie : t)
    (word_list : string list)
    (possible_words : string list) : string list =
  List.filter
    (fun (x : string) ->
      trie_contains_word trie (word_to_list x)
      && List.mem x possible_words)
    word_list

let rec scoring_single input list =
  let try_again = "Invalid Input. Try Again\n" in
  match input with
  | None ->
      ANSITerminal.(print_string [ red; Bold ] try_again);
      let new_input = read_line () |> int_of_string_opt in
      scoring_single new_input list
  | Some int -> (
      match int with
      | 1 -> boggle_scoring_single list
      | 2 -> wordhunt_scoring_single list
      | _ ->
          ANSITerminal.(print_string [ red; Bold ] try_again);
          let new_input = read_line () |> int_of_string_opt in
          scoring_single new_input list)

let game_end_single
    (input_board : board)
    (possible_words : string list)
    (player_name : string) : unit =
  ANSITerminal.(
    print_string [ green ]
      "Please enter the list of words that you found in the board. \
       Separate each word with a space. ");
  ANSITerminal.(print_string [ green; Blink ] "\n>> ");
  let validated_word_list =
    let word_list =
      read_line () |> String.uppercase_ascii |> String.split_on_char ' '
    in
    validate_words word_trie word_list possible_words
  in
  ANSITerminal.(
    print_string [ green ]
      "How would you like your words to be scored? Type (1) for Boggle \
       scoring and (2) for WordHunt scoring. ");
  ANSITerminal.(print_string [ green; Blink ] "\n>> ");
  let input = read_line () |> int_of_string_opt in
  let score = scoring_single input validated_word_list in
  ANSITerminal.(
    print_string [ magenta; Bold ]
      ("CONGRATULATIONS! Your score is: \n" ^ string_of_int score ^ "\n"))

let rec player_word_input
    (player_name_list : string list)
    (acc : string list list) : string list list =
  match player_name_list with
  | [] -> acc
  | h :: t ->
      let input =
        ANSITerminal.(
          printf [ green ]
            "Please enter the list of words for: < %s >. Separate each \
             word with a space. "
            h);
        ANSITerminal.(print_string [ green; Blink ] "\n>> ");
        read_line () |> String.split_on_char ' '
      in
      player_word_input t (acc @ [ input ])

let multi_score_print
    (player_name_list : string list)
    (score_list : int list) : unit =
  ANSITerminal.(print_string [ magenta; Bold ] "SCORES\n");
  List.iter2
    (fun name score ->
      ANSITerminal.(printf [ green ] "%s \t => %d\n" name score);
      ())
    player_name_list score_list;
  ()

let rec scoring_multi input list =
  let try_again = "Invalid Input. Try Again\n" in
  match input with
  | None ->
      ANSITerminal.(print_string [ red; Bold ] try_again);
      let new_input = read_line () |> int_of_string_opt in
      scoring_multi new_input list
  | Some int -> (
      match int with
      | 1 -> boggle_scoring_multi list
      | 2 -> wordhunt_scoring_multi list
      | _ ->
          ANSITerminal.(print_string [ red; Bold ] try_again);
          let new_input = read_line () |> int_of_string_opt in
          scoring_multi new_input list)

let game_end_multi
    (input_board : board)
    (possible_words : string list)
    (player_name_list : string list) : unit =
  let player_word_list = player_word_input player_name_list [] in
  let validated_word_list =
    List.map
      (fun x -> validate_words word_trie x possible_words)
      player_word_list
  in
  ANSITerminal.(
    print_string [ green ]
      "How would you like your words to be scored? Type (1) for Boggle \
       scoring and (2) for WordHunt scoring. ");
  ANSITerminal.(print_string [ green; Blink ] "\n>> ");
  let input = read_line () |> int_of_string_opt in
  let score_list = scoring_multi input validated_word_list in
  multi_score_print player_name_list score_list

let rec repeat (s : string) (n : int) : string =
  if n = 0 then "" else s ^ repeat s (n - 1)

let clear = repeat "\n" 45

(* try let proc = Unix.open_process_in "clear" in try let chars =
   input_line proc in ignore (Unix.close_process_in proc); chars with e
   -> ignore (Unix.close_process_in proc); "" with _ -> "" *)

(* takes in time, keeps counting down every sec (or 5?) to terminal +
   erasing?? and then printing times up, then calling game end*)
let rec countdown
    (input_board : board)
    (time_length : int)
    (time_start : float)
    (player_name_list : string list) : unit =
  ANSITerminal.(resize 120 45);
  (* (print_board input_board); *)
  let time_passed = Unix.gettimeofday () -. time_start in
  (* let _ = ANSITerminal.(print_string [green; Bold] ("\n" ^
     (time_passed |> Float.to_int |> string_of_int) ^ "seconds passed
     out of " ^ (time_length |> string_of_int) ^ "seconds \n")) in *)
  let _ =
    let step = Float.to_int (2. *. time_passed) mod 8 in
    match step with
    | 0 ->
        ANSITerminal.(print_string [ cyan; Bold ] (clock_ascii0 ^ "\n"))
    | 1 ->
        ANSITerminal.(print_string [ cyan; Bold ] (clock_ascii1 ^ "\n"))
    | 2 ->
        ANSITerminal.(print_string [ cyan; Bold ] (clock_ascii2 ^ "\n"))
    | 3 ->
        ANSITerminal.(print_string [ cyan; Bold ] (clock_ascii3 ^ "\n"))
    | 4 ->
        ANSITerminal.(print_string [ cyan; Bold ] (clock_ascii4 ^ "\n"))
    | 5 ->
        ANSITerminal.(print_string [ cyan; Bold ] (clock_ascii5 ^ "\n"))
    | 6 ->
        ANSITerminal.(print_string [ cyan; Bold ] (clock_ascii6 ^ "\n"))
    | 7 ->
        ANSITerminal.(print_string [ cyan; Bold ] (clock_ascii7 ^ "\n"))
    | _ ->
        ANSITerminal.(print_string [ cyan; Bold ] (clock_ascii0 ^ "\n"))
  in
  if time_passed > Float.of_int time_length then begin
    ANSITerminal.(erase Screen);
    print_board input_board;
    ANSITerminal.(print_string [ magenta; Bold ] (time_up ^ "\n"));
    if List.length player_name_list = 1 then
      game_end_single input_board
        (find_possible_words input_board)
        (List.hd player_name_list)
    else
      game_end_multi input_board
        (find_possible_words input_board)
        player_name_list
  end
  else begin
    print_board input_board;
    (* print_endline ""; *)
    ANSITerminal.(
      print_string [ cyan; Bold ]
        ("\n"
        ^ (time_passed |> Float.to_int |> string_of_int)
        ^ " seconds passed out of "
        ^ (time_length |> string_of_int)
        ^ " seconds "));
    print_endline "";
    Unix.sleepf 0.1;
    ANSITerminal.(print_string [ white ] clear);
    (* ANSITerminal.(erase Above); *)
    countdown input_board time_length time_start player_name_list
  end

let terminal_player_name : string list =
  let game_mode =
    ANSITerminal.(resize 120 45);
    ANSITerminal.(print_string [ magenta; Bold ] welcome_ascii);
    ANSITerminal.(print_string [ cyan; Bold ] boggle_ascii2);
    ANSITerminal.(
      print_string [ green ]
        "\n\
         How would you like to play? Type (1) for singleplayer or (2) \
         for  \n\
        \      Multiplayer.\n");
    ANSITerminal.(print_string [ green; Blink ] ">> ");
    let input = read_line () |> int_of_string_opt in
    match input with
    | None ->
        ANSITerminal.(
          print_string [ red; Bold ] "Invalid input. Ending game...\n");
        exit 0
    | Some num -> (
        match num with
        | 1 -> num
        | 2 -> num
        | _ ->
            ANSITerminal.(
              print_string [ red; Bold ]
                "Invalid input. Ending game...\n");
            exit 0)
  in
  if game_mode = 1 then (
    ANSITerminal.(
      print_string [ green ]
        "What is your name? Use the same name if you've played \
         previously.\n");
    ANSITerminal.(print_string [ green; Blink ] ">> ");
    let input = read_line () in
    [ input ])
  else (
    ANSITerminal.(
      print_string [ green ]
        "Please type all the names of the players into the same line, \
         separated by spaces. Use the same names if you've played \
         previously. \n");
    ANSITerminal.(print_string [ green; Blink ] ">> ");
    let input = read_line () |> String.split_on_char ' ' in
    input)

(* let ascii_intro = ANSITerminal.(resize 120 45);
   ANSITerminal.(print_string [ magenta; Bold ] welcome_ascii);
   ANSITerminal.(print_string [ cyan; Bold ] boggle_ascii2); () *)

(* initializes game >>greet user >>ask for name >>ask for size of board
   >>generates board *)
let main () =
  (* let _ = ascii_intro in *)
  (* if singleplayer, it's a length 1 list with the player name *)
  let player_name_list = terminal_player_name in
  ANSITerminal.(
    print_string [ green ]
      "How large would you like your board to be? Provide a \
       side-length between 4 and 10.");
  ANSITerminal.(print_string [ green; Blink ] "\n>> ");
  let board_size =
    let input = read_line () |> int_of_string_opt in
    match input with
    | None ->
        ANSITerminal.(
          print_string [ red; Bold ] "Invalid input. Ending game...\n");
        exit 0
    | Some int ->
        if int >= 4 && int <= 10 then int
        else (
          ANSITerminal.(
            print_string [ red; Bold ] "Invalid input. Ending game...\n");
          exit 0)
  in
  let get_board dim =
    match dim with 4 | 5 -> init_classic dim | _ -> rand_init dim
  in
  let new_board = get_board board_size in
  ANSITerminal.(
    print_string [ green ]
      "How long would you like for the round? Provide a number in \
       seconds. \n\
       (Normal boggle round is 3 minutes = 180 seconds)");
  ANSITerminal.(print_string [ green; Blink ] "\n>> ");
  let time_input =
    let input = read_line () |> int_of_string_opt in
    match input with
    | None ->
        ANSITerminal.(
          print_string [ red; Bold ] "Invalid input. Ending game...\n");
        exit 0
    | Some int ->
        if int >= 0 && int <= 10000 then int
        else (
          ANSITerminal.(
            print_string [ red; Bold ] "Invalid input. Ending game...\n");
          exit 0)
  in
  let curr_time = Unix.gettimeofday () in
  ANSITerminal.(
    print_string [ green ] (String.concat " " player_name_list));
  (* print_board new_board; *)
  countdown new_board time_input curr_time player_name_list

(* launches game *)
let () = main ()
