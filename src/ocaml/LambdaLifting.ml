open Tsast;;
open Ast_t;;
open AstTransformers;;
open Base;;

let add_bounds = fun bounds -> function
  | VarDecl (s, _) -> s :: bounds
  | FunctionDecl (s, _, _) -> s :: bounds
  | VarObjectPatternDecl (xs, _) -> xs @ bounds
  | VarArrayPatternDecl (xs, _) -> xs @ bounds
  | _ -> bounds

let invent_name bounds s =
  let rec loop n =
    let name = s ^ "$" ^ Int.to_string n in
    if List.mem ~equal:(String.equal) bounds name then loop (n + 1) else name
  in if List.mem ~equal:(String.equal) bounds s then Some (loop 0) else None

let disambiguate_parameter (bounds, name_tab as arg) = function
| Parameter (s, is_opt, e) as e0 -> (
  match invent_name bounds s with
  | None -> (arg, e0)
  | Some s1 ->
    let name_tab1 = Map.set name_tab ~key:s ~data:s1
    and bounds1 = s1 :: bounds
    in ((bounds1, name_tab1), Parameter (s1, is_opt, e))
)

type 'a string_tab = (string, 'a, String.comparator_witness) Base.Map.t

(*
 * Transforms functions such that function parameters do not capture bound variables.
*)
class parameter_disambiguater = object(self)
  inherit [string list * string string_tab, unit] ast_transformer as super

  (* Incomplete: nested arrows *)
  method! expr (_, name_tab as down) () = function
  | Var(s) as e -> (
    match Map.find name_tab s with
    | Some(s1) -> ((), Var(s1))
    | None -> ((), e)
  )
  | e -> super#expr down () e

  val disambiguate_parameters = fun arg params ->
    List.fold_map params ~init:arg ~f:disambiguate_parameter

  method! func arg () params b =
    let arg1, params1 = disambiguate_parameters arg params in
    super#func arg1 () params1 b

  method! block (bounds, name_tab) () = function
  | Block blocks ->
    let folder bounds e =
      let bounds1 = add_bounds bounds e in
      (* We pass the new binding down immediately *)
      let ((), e1) = self#expr (bounds1, name_tab) () e in
      (bounds1, e1)
    in
    let (_, blocks1) = List.fold_map ~f:folder ~init:bounds blocks in
    ((), Block blocks1)

  end

let the_parameter_disambiguater = new parameter_disambiguater

let disambiguate_parameters block =
  let ((), block1) = the_parameter_disambiguater#block ([], Map.empty(module String)) () block
  in block1


(* 
 * Folds declarations of the form
 *   const f = (params) => { body }
 * into
 *   function f(params) => { body } .
 * We use this in an attempt to preserve the recursive structure of functions.
 *)
class const_arrow_folder = object
  inherit [unit, unit] ast_transformer as super

  method! expr () () = function
  | VarDecl(f, Arrow(params, body)) ->  ((), FunctionDecl(f, params, body))
  | e -> super#expr () () e

end

let fold_const_arrows =
  let the_folder = new const_arrow_folder in
  fun b ->
    let ((), b1) = the_folder#block () () b in
    b1


let get_parameter_var = function
  Parameter (s, _, _) -> s

let get_parameter_vars = List.map ~f:get_parameter_var

let is_function_decl = function
| FunctionDecl _ -> true
| _ -> false

(*
 * Compute the free variables of an expression.
 *)
class free_vars_computer = object(self)
  inherit [string list, string list] ast_transformer as super

  method! expr bounds frees = function
  | Var (s) as e ->
    let frees1 = if List.mem bounds s ~equal:String.equal then frees else s :: frees in
    (frees1, e)
  (* We assume that functions bind their name recursively, everything else not. *)
  | FunctionDecl(s,_,_) as e -> super#expr (s :: bounds) frees e
  | e -> super#expr bounds frees e

  method! func bounds frees params b =
    let ps = get_parameter_vars params in
    let (frees1, _) = List.fold_map ~f:(self#parameter frees) ~init:frees params in
    let (frees2, _) = self#block (ps @ bounds) frees1 b in
    (frees2, params, b)

  method! block bounds frees = function
  | Block blocks as b ->
    let folder (bounds, frees) e =
      let bounds1 = add_bounds bounds e
      and (frees1, _) = self#expr bounds frees e in
      (bounds1, frees1)
    in
    let (_bounds1, frees1) = List.fold ~f:folder ~init:(bounds, frees) blocks in
    (frees1, b)

end

let the_free_vars_computer = new free_vars_computer

let free_vars ?(bounds=[]) e =
  let (frees, _) = the_free_vars_computer#expr bounds [] e in
  List.dedup_and_sort ~compare:(String.compare) frees


let pp_expr_list = Util.pp_list Pprint.pprint_expr
let pp_parameter_list = Util.pp_list Pprint.pprint_parameter

type func_tab = (string, parameter list * string * expr list, String.comparator_witness) Base.Map.t
(*
  * Constant propagation:
  * Remove const-arrow declarations
  *  const f = (args) => f_new(context_vars...args)
  * and substitute f_new for f at call sites.
*)
class constant_propagater = object(self)
  inherit [func_tab, unit] ast_transformer as super

  val subst_func_call = fun (params0, f, args) es ->
    let num_params = List.length params0 in
    if List.length es > num_params
      then raise (Invalid_argument
        (Caml.Format.asprintf "Parameter lists do not match! %s|%a|%a"
          f pp_expr_list es pp_parameter_list params0 ))
      else
        let args_context = List.take args (List.length args - num_params) in
        let args_all = args_context @ es in
        App(Var(f), args_all)

  (* Incomplete: nested arrows *)
  method! expr func_tab () = function
  | App(Var(x), es) as e0 -> (
    match Map.find func_tab x with
      None -> super#expr func_tab () e0
    | Some(call) ->
      let e1 = subst_func_call call es in
      super#expr func_tab () e1
    )
  | e -> super#expr func_tab () e
  
  (* Incomplete: other stmts also generate bindings *)
  val update_func_tab = fun tab -> function
  | VarDecl(s, Arrow(params0, Block [App(Var(f), args)])) ->
    (Map.set tab ~key:s ~data:(params0, f, args), true)
  | VarDecl(s, _)  -> (Map.remove tab s, false)
  | _ -> (tab, false)

  method! block func_tab () = function
  | Block blocks ->
    let folder func_tab e =
      let (func_tab1, remove) = update_func_tab func_tab e
      and (), e1 = self#expr func_tab () e in
      (func_tab1, if remove then None else Some e1)
    in
    let (_, blocks1_opt) = List.fold_map ~f:folder ~init:func_tab blocks in
    let blocks1 = List.filter_opt blocks1_opt in
    ((), Block blocks1)

  end

let the_constant_propagater = new constant_propagater

let propagate_fun_bindings b =
  let m = Map.empty (module String) in
  let ((), b1) = the_constant_propagater#block m () b in
  b1


(*
 * Lambda lifting, i.e. removing nested function definitions:
 * - Identify all function definitions
 * - Store them in a table with entries of the form
 *   (<function name>, <parameter list>, <function body>)
 * - For anonymous functions a name is invented
 * - Any function name is prefixed with any name bindings encountered on the path from the root
 * - Replace function defs
 *     function f(args) = { body(context_vars) }
 *   by constant declarations
 *     const f = (args) => f_new(context_vars...args)
 * - Propagate such a constant declaration (see propagate_fun_bindings)
 * - Recurse until every function has been lifted
 *)
let make_params = List.map ~f:(fun p -> Parameter(p, false, None))

type ('a, 'b) lifter_result = Result of 'a | Found of 'b

let insert_block e = function
| Block b -> Block (e :: b)

class lifter(bounds: string list) = object(self)
  inherit [string, (string * parameter list * block) option] ast_transformer as super

  val make_partial = fun (s, params_0, params_ext) ->
    let ps = get_parameter_vars params_0 in
    let args = List.map ~f:(fun v -> Var (v)) (params_ext @ ps) in
    Arrow(params_0, Block [App(Var(s), args)])

  method func1 = fun name params b e0 ->
    let (acc1, params1, b1) = super#func name None params b in (
      match acc1 with
      | Some r -> (r, Result(params1, b1))
      | None ->
      let frees = free_vars ~bounds e0 in
      let new_params = make_params frees @ params1 in
      let e1 = make_partial (name, params, frees)
      and r = (name, new_params, b1) in
      (r, Found e1)
    )

  method! expr name = function
  | Some(result) -> fun e -> (Some (result), e)
  | None as acc -> function
    | VarDecl (s, _) as e0 -> super#expr (name ^ "_" ^ s) acc e0
    | Arrow (params, b) as e0 -> (
      match self#func1 name params b e0 with
      | (r, Result(params1, b1)) -> (Some r, Arrow(params1, b1))
      | (r, Found e1) -> (Some r, e1)
      )
    | FunctionDecl(s, params, b) as e0 ->
      let name1 = name ^ "_" ^ s in (
      match self#func1 name1 params b e0 with
      | (r, Result(params1, b1)) -> (Some r, FunctionDecl(s, params1, b1))
      | ((name2, params1, b1), Found e1) ->
        let decl = VarDecl (s, e1) in
        let b2 = insert_block decl b1 in
        (Some (name2, params1, propagate_fun_bindings b2), VarDecl (s, e1))
      )
    | e -> super#expr name acc e
end

let lift b =
  let rec iter tab b n =
    if n > 100 then
      raise (Invalid_argument "Seems like we have a termination problem!")
    else
    let bounds = List.map tab ~f:(fun (s, _, _) -> s) in
    let the_lifter = new lifter bounds in
    let (r_opt, b1) = the_lifter#block "#top" None b in (
    match r_opt with
    | None -> (tab, b1)
    | Some r ->
      let b2 = propagate_fun_bindings b1 in
      let () = Stdio.printf "\nIteration %d before propagation:\n" n
      and () = Stdio.print_endline (Pprint.print_block b1 ())
      and () = Stdio.printf "\nIteration %d:\n" n
      and () = Stdio.print_endline (Pprint.print_block b2 ()) in
      iter (r :: tab) b2 (n + 1)
    )
  in iter [] b 0