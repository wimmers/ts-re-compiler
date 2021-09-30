open Base
open BasicTypes

class if_completer_class = object
  inherit [unit, unit] AstTransformers.ast_transformer as super

  method! stmt () () = function
    `If (b, block1, None) -> super#stmt () () (`If (b, block1, Some (`Block [])))
  | s -> super#stmt () () s

end

let if_completer = new if_completer_class

let complete_if block =
  let _, block1 = if_completer#block () () block
  in block1

let append_to_block block stmts = match block with
| `Block stmts1 -> `Block (stmts1 @ stmts)

class if_pullover_class = object(self)
  inherit [unit, unit] AstTransformers.ast_transformer as super

  method! block () () = function
    `Block (`If (cond, bt, Some bf)::stmts) ->
    let _, bt1 = append_to_block bt stmts |> self#block () () in
    let _, bf1 = append_to_block bf stmts |> self#block () () in
    (), `Block [`If (cond, bt1, Some bf1)]
  | `Block (stmt::stmts) ->
    let _, `Block stmts1 = self#block () () (`Block stmts) in
    (), `Block (stmt::stmts1)
  | b -> super#block () () b

end

let if_pullover = new if_pullover_class

class return_cutoff_class = object
  inherit [unit, unit] AstTransformers.ast_transformer as super

  method! block () () = function
    `Block stmts ->
    let stmts1, stmts2 = List.split_while stmts ~f:(
      function `Return _ -> false | _ -> true
      )
    in
    let new_stmts = (match stmts2 with
      | `Return (Some e) :: _ -> stmts1 @ [`Expression e]
      | _ -> stmts1
    )
    in
    super#block () () (`Block new_stmts)

end

let return_cutoff = new return_cutoff_class

let apply_to_program ~down transformer ((funs: fun_decl list), block) =
  let funs1 = List.map funs ~f:(fun (s, params, block) ->
    let _, block1 = transformer#block down () block in
    (s, params, block1)
  )
  in let _, block1 = transformer#block down () block in
  (funs1: fun_decl list), block1

let pull_if p =
  p
  |> apply_to_program if_pullover ~down:()
  |> apply_to_program return_cutoff ~down:()