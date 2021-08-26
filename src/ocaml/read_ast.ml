open Printf
open Tsast
open Asttransforms
open Simple_fun

let () =
  if Array.length Sys.argv != 3 then begin
    printf "Usage: %s IN_FILE OUT_FILE\n" Sys.argv.(0);
    exit 1
  end

let file_name = Sys.argv.(1)
let out_name = Sys.argv.(2)

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
  let p = WhileLifting.lift_program p in
  print_endline "While loops lifted:\n";
  print_program p;
  let p = PullIf.pull_if p in
  printf "\nProgram after pulling out ifs:\n\n";
  print_program p;
  let p = DisambiguateFunctions.disambigute_funs p in
  printf "\nProgram after disambiguating functions with optional parameters:\n\n";
  print_program p;
  (* Final phase: turn blocks into iterated lets, ad-hoc conversion of expressions *)
  let p = ToSimpleFun.letify_program p in
  (* Add empty pre-/post-conditions *)
  let funs, prop = p in
  let funs = Base.List.map funs ~f:(fun (s, signature, f) -> (s, signature, None, None, f)) in
  let p = funs, prop in
  Format.printf "\nProgram after conversion:\n%a\n@." SimpleProgram.pp_program p;
  let sexp = SimpleProgram.sexp_of_program p in
  Stdio.Out_channel.write_all out_name ~data:(Base.Sexp.to_string sexp)