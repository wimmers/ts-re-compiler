open Base
open BasicTypes

let disambiguate_var_name (bounds, name_tab as arg) = function
| `VarAssignment (s, e) as e0 -> (
  match Util.invent_name bounds s with
  | None -> (s::bounds, name_tab), e0
  | Some s1 ->
    let name_tab1 = Map.set name_tab ~key:s ~data:s1
    and bounds1 = s1 :: bounds
    in (bounds1, name_tab1), `VarAssignment (s1, e)
)
| stmt -> arg, stmt

(** Disambiguate variable names: Each variable should be bound at most once. **)
class variable_disambiguater_class = object(self)
  inherit
    [string list * string string_tab, unit] AstTransformers.ast_transformer
    as super

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
      disambiguate_var_name down stmt1
    in
    let _, blocks1 = List.fold_map ~f:folder ~init:down blocks in
    (), `Block blocks1

  method! func (bounds, name_tab) () params b  =
    let new_bounds = BasicTransformers.get_parameter_vars params in
    super#func (new_bounds @ bounds, name_tab) () params b

end

let variable_disambiguater = new variable_disambiguater_class

let disambiguate_variable_names p =
  p
  |> variable_disambiguater#program ([], Map.empty(module String)) ()
  |> snd