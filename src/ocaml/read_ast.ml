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

let print_program (tab, b) =
  List.iter (fun (s, params, block) ->
    print_endline (Pprint.print_stmt (`FunctionDecl (s, params, block)) ())
  ) tab;
  print_endline "\n";
  print_endline (Pprint.print_block b ())

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
  let b = PullIf.complete_if b in
  print_endline "If completed:\n";
  print_endline (Pprint.print_block b ());
  let b = LambdaLifting.disambiguate_parameters b in
  printf "\nProgram after disambiguating parameters:\n\n";
  print_endline (Pprint.print_block b ());
  let b = LambdaLifting.fold_const_arrows b in
  printf "\nProgram after const-arrow folding:\n\n";
  print_endline (Pprint.print_block b ());
  let p = LambdaLifting.lift b in
  printf "\nProgram after lambda lifting:\n\n";
  print_program p;
  let p = PullIf.pull_if p in
  printf "\nProgram after pulling out ifs:\n\n";
  print_program p;
  let p = DisambiguateFunctions.disambigute_funs p in
  printf "\nProgram after disambiguating functions with optional parameters:\n\n";
  print_program p;