open Base
open Tsast
open BasicTypes

let split_optionals params =
  let optionals, regulars =
    List.partition_tf params ~f:(
      function
        `Parameter (_, false, Some _) -> true
      | `Parameter (_, true, None) -> true
      | _ -> false
    )
  in if Poly.(regulars @ optionals <> params) then
    raise (Invalid_argument "Optional parameters cannot appear before regular ones!")
  else
    regulars, optionals

let extend_body optionals = function
| `Block stmts ->
  let new_stmts = List.fold_right optionals ~init:stmts ~f:(
  fun param stmts -> match param with
  | `Parameter (s, false, Some e) -> `VarDecl (s, e) :: stmts
  | `Parameter (s, true, None) -> `VarDecl (s, `Undefined) :: stmts
  | p -> raise (Invalid_argument
      (Caml.Format.asprintf "Not a valid optional %a" Pprint.pprint_parameter p))
  ) in
  `Block new_stmts

let optionals_to_regulars optionals =
  List.map optionals ~f:(
    function
      `Parameter (s, false, Some _) -> `Parameter (s, false, None)
    | `Parameter (s, true, None) -> `Parameter (s, false, None)
    | _ -> raise (Invalid_argument "Not an optional!")
  )

let disambigute_fun (s, params, block) =
  let regulars, optionals = split_optionals params in
  let n_regular = List.length regulars in
  if List.is_empty regulars then
    n_regular, [(s ^ "_" ^ Int.to_string n_regular, params, block)]
  else
    let n_optional = List.length optionals in
    let range = List.range ~stop:`inclusive 0 n_optional in
    let new_funs = List.map range ~f:(
      fun n ->
        let optionals = List.drop optionals n
        and non_optionals = List.take optionals n in
        let block = extend_body optionals block in
        let n_params = n_regular + n in
        let non_optionals = optionals_to_regulars non_optionals in
        let new_params = regulars @ non_optionals in
        let name = s ^ "_" ^ Int.to_string n_params in
        name, new_params, block
    ) in
    n_regular, (new_funs: fun_decl list)

type fn_map = (string, (int * string list)) Map.Poly.t

let substitute_fun (fn_map: fn_map) f_name args =
  match Map.Poly.find fn_map f_name with
  | None ->
    let _ = Stdio.printf "Warning: Did not find function name: %s" f_name in
    `App (`Var(f_name), args)
  | Some (num_regulars, fun_names) ->
    let new_name = List.nth_exn fun_names (List.length args - num_regulars) in
    `App (`Var(new_name), args)

class fun_substitution (fn_map: fn_map) = object

inherit [unit, unit] AstTransformers.ast_transformer as super

method! expr down acc = function
| `App(`Var(f), es) -> super#expr down acc (substitute_fun fn_map f es) 
| e -> super#expr down acc e

method fun_decl: fun_decl -> fun_decl = fun (s, params, body) -> 
  let (), body1 = super#block () () body in
  let params1 = List.map params ~f:(fun p -> snd (super#parameter () () p)) in
  s, params1, body1

end

let disambigute_funs (funs, block) =
  let funs_disambiguated = List.map funs ~f:(
    fun (s, params, block) ->
      let n_regular, new_funs = disambigute_fun (s, params, block) in
      s, n_regular, new_funs
  ) in
  let all_new_funs = List.concat_map funs_disambiguated ~f:(fun (_, _, x) -> x) in
  let fn_map = Map.Poly.of_alist_exn (List.map funs_disambiguated ~f:(
    fun (s, n_regular, new_funs) ->
      let fun_names = List.map new_funs ~f:(fun (name, _, _) -> name) in
      s, (n_regular, fun_names)
  )) in
  let substitution = new fun_substitution fn_map in
  let _, new_block = substitution#block () () block in
  let all_new_funs = List.map all_new_funs ~f:substitution#fun_decl in
  all_new_funs, new_block