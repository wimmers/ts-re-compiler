open Printf
open Tsast
open Asttransforms

let () =
  if Array.length Sys.argv != 2 then begin
    printf "Usage: %s IN_FILE\n" Sys.argv.(0);
    exit 1
  end

let file_name = Sys.argv.(1)

let in_text = Stdio.In_channel.read_all file_name

let program = Ast_j.block_of_string in_text

let out_text = Pprint.print_block program ()

let babelFills = ["_toConsumableArray"]

let () =
  let b = program in
  print_endline "Input:\n";
  print_endline out_text;
  let b = BasicTransformers.denop b in
  print_endline "Nops removed:\n";
  print_endline (Pprint.print_block b ());
  let b = BasicTransformers.strip_functions babelFills b in
  print_endline "Babel fills removed:\n";
  print_endline (Pprint.print_block b ());
  let b = LambdaLifting.disambiguate_parameters b in
  printf "\nProgram after disambiguating parameters:\n\n";
  print_endline (Pprint.print_block b ());
  let b = LambdaLifting.fold_const_arrows b in
  printf "\nProgram after const-arrow folding:\n\n";
  print_endline (Pprint.print_block b ());
  let (tab, b) = LambdaLifting.lift b in
  printf "\nExtracted %d function definitions:\n\n" (List.length tab);
  List.iter (fun (s, params, block) ->
    print_endline (Pprint.print_stmt (`FunctionDecl (s, params, block)) ())
    ) tab;
  printf "\nProgram after lambda lifting:\n\n";
  print_endline (Pprint.print_block b ());
  let (tab, b) = DisambiguateFunctions.disambigute_funs (tab, b) in
  printf "\nDisambiguated %d function definitions:\n\n" (List.length tab);
  List.iter (fun (s, params, block) ->
    print_endline (Pprint.print_stmt (`FunctionDecl (s, params, block)) ())
    ) tab;
  printf "\nProgram after function disambiguation:\n\n";
  print_endline (Pprint.print_block b ());