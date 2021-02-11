open Printf
open Tsast

let () =
  if Array.length Sys.argv != 2 then begin
    printf "Usage: %s IN_FILE\n" Sys.argv.(0);
    exit 1
  end

let file_name = Sys.argv.(1)

let in_text = Stdio.In_channel.read_all file_name

let program = Ast_j.block_of_string in_text

let out_text = Pprint.print_block program ()

let tab = LambdaLifting.lift program

let (tab1, b1) = LambdaLifting.lift2 program

let () =
  print_endline "Input:\n";
  print_endline out_text;
  printf "Extracted %d function definitions:\n\n" (List.length tab);
  List.iter (fun (s, params, block) ->
    print_endline (Pprint.print_expr (Ast_t.FunctionDecl (s, params, block)) ())
    ) tab;
  printf "\nExtracted %d function definitions:\n\n" (List.length tab1);
  List.iter (fun (s, params, block) ->
    print_endline (Pprint.print_expr (Ast_t.FunctionDecl (s, params, block)) ())
    ) tab1;
  printf "\nNew program:\n\n";
  print_endline (Pprint.print_block b1 ())