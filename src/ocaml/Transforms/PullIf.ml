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


let disambiguate_function_name (bounds, name_tab as arg) = function
| `VarAssignment (s, e) as e0 -> (
  match Util.invent_name bounds s with
  | None -> (s::bounds, name_tab), e0
  | Some s1 ->
    let name_tab1 = Map.set name_tab ~key:s ~data:s1
    and bounds1 = s1 :: bounds
    in (bounds1, name_tab1), `VarAssignment (s1, e)
)
| `FunctionDecl (_s, _, _) ->
  raise (Invalid_argument "Unexpected function declaration!")
| `VarObjectPatternDecl (_xs, _) ->
  raise (Invalid_argument "Object pattern matching not implemented!")
| `VarArrayPatternDecl (_xs, _) ->
  raise (Invalid_argument "Array pattern matching not implemented!")
| stmt -> arg, stmt

(** Disambiguate variable names: Each variable should be bound at most once. **)
class variable_disambiguater_class = object(self)
  inherit [string list * string string_tab, unit] AstTransformers.ast_transformer as super

  (* Incomplete: nested arrows *)
  method! expr (_, name_tab as down) () = function
  | `Var(s) as e -> (
    match Map.find name_tab s with
    | Some(s1) -> (), `Var(s1)
    | None -> (), e
  )
  | e -> super#expr down () e

  method! block down () = function
  | `Block blocks ->
    let folder down stmt =
      (* First recurse on the statement itself *)
      let _, stmt1 = self#stmt down () stmt in
      (* Then update name bindings *)
      disambiguate_function_name down stmt1
    in
    let _, blocks1 = List.fold_map ~f:folder ~init:down blocks in
    (), `Block blocks1

  method! func (bounds, name_tab) () params b  =
    let new_bounds = BasicTransformers.get_parameter_vars params in
    super#func (new_bounds @ bounds, name_tab) () params b

end

let variable_disambiguater = new variable_disambiguater_class


let apply_to_program ~down transformer ((funs: fun_decl list), block) =
  let funs1 = List.map funs ~f:(fun (s, params, block) ->
    let _, block1 = transformer#block down () block in
    (s, params, block1)
  )
  in let _, block1 = transformer#block down () block in
  (funs1: fun_decl list), block1

let pull_if p =
  p
  |> variable_disambiguater#program ([], Map.empty(module String)) ()
  |> snd
  |> apply_to_program if_pullover ~down:()
  |> apply_to_program return_cutoff ~down:()