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

let _ = print_endline out_text