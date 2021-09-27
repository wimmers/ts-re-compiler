open Simple_fun.SimpleFun
open Tsast
open Pprint
open BasicTypes
open Consts
open Base

let is_int_float v =
  let c = Float.classify (Float.Parts.fractional (Float.modf v)) in
  Poly.(c = Zero)

let pre_prefix = "P$"

let asprintf = Caml.Format.asprintf

let strip_top_level_undefineds: Ast_t.block -> Ast_t.block = function
| `Block xs ->
  let xs1 = List.filter xs ~f:(function `Expression `Undefined -> false | _ -> true) in
  `Block xs1

type binop_t = [
| `And
| `Div
| `Eq
| `Eq2
| `Eq3
| `Greater
| `Less
| `Minus
| `Neq2
| `Neq3
| `Or
| `Plus
| `Times ]

let conv_op: binop_t -> _ = function
  | `Eq -> Eq
  | `Eq2 -> Eq2
  | `Neq2 -> Neq2
  | `Eq3 -> Eq3
  | `Neq3 -> Neq3
  | `Times -> Times
  | `Plus -> Plus
  | `Minus -> Minus
  | `Div -> Div
  | `Greater -> Greater
  | `Less -> Less
  | `Or -> Or
  | `And -> And
  (* | op -> raise (Invalid_argument (asprintf "Unsupported binop: %a" pprint_binop op)) *)

class internals_compiler = object(self)
  inherit [unit, unit] AstTransformers.ast_transformer as super

  method! expr () () = function
  | `App (`PropertyAccess (`ArrayLit [], "concat"), args) ->
    if List.is_empty args then
      (), `ArrayLit []
    else (), List.fold_right (Util.butlast args) ~init:(List.last_exn args)
      ~f:(fun e tail -> 
            let (), e1 = self#expr () () e in
            `App (`Var array_append, [e1; tail]))
  | e -> super#expr () () e

end

let compile_internals =
  let the_internals_compiler = new internals_compiler in
  fun block -> let (), block1 = the_internals_compiler#block () () block in
  block1

let ensure_prop_stmt = function
| `Expression (`App (`Var s, [prop])) when String.equal s assert_name
  -> `Expression prop
| s -> raise (Invalid_argument (asprintf "Not a prop: %a" pprint_stmt s)) 

let ensure_prop: Ast_t.block -> Ast_t.block = function
| `Block xs ->
  if List.is_empty xs then
    raise (Invalid_argument "Empty block is not a prop!")
  else
    let stmt = List.last_exn xs in
    `Block (Util.butlast xs @ [ensure_prop_stmt stmt])


let true_const = Const (Bool true)
let get_bool b = Option.value ~default:true_const b
let mk_and b1 b2 = Binop (And, b1, b2)
let mk_and0 b1 b2 = `Binop (`And, b1, b2)

let fun_name_to_pre name = pre_prefix ^ name

(* XXX wrong *)
let mk_call_pre_expr e es = (*`App (`PropertyAccess (e, "pre"), es) *)
  let fun_name = `PropertyAccess (e, closure_fun_name) in
  let pre_name = `App (`Var str_concat_name, [`String pre_prefix; fun_name]) in
  let obj = `App (`Var updS_name, [e; `String closure_fun_name; pre_name]) in
  `App (obj, es)

(* XXX Move? *)
let extract_object_param = function
| `Parameter (s, false, Some e) -> s, e
| `Parameter (s, false, None) -> s, `Var s
| p ->
  raise (Invalid_argument (
    asprintf "Invalid parameter in object literal: %a"
      pprint_parameter p))

(* XXX What would be a nice monadic version of this? *)
let rec expr_cond funs = function
| `App (`Var name, [cond]) when String.equal name assert_name -> Some cond
| `App (e, es) ->
  let cond = (match e with
    | `Var name when List.mem funs name ~equal:String.equal ->
      let pre_name = fun_name_to_pre name in
      `App (`Var pre_name, es)
    | _ -> mk_call_pre_expr e es
  ) in
  let conds = List.filter_map ~f:(expr_cond funs) es in
  let conj = List.fold conds ~init:cond ~f:mk_and0 in
  Some conj
| `ObjLit(params) ->
  let conds = List.filter_map params ~f:(fun p ->
    extract_object_param p |> snd |> expr_cond funs) in
  List.reduce conds ~f:mk_and0
| `ArrayLit(es) ->
  let conds = List.filter_map es ~f:(expr_cond funs) in
  List.reduce conds ~f:mk_and0
| `Binop(_, e1, e2) | `ElementAccess(e1, e2) ->
  Option.merge (expr_cond funs e1) (expr_cond funs e2) ~f:mk_and0
| `PropertyAccess(e, _s) ->
  expr_cond funs e
| `Arrow _ | `Var _ | `String _ | `Number _ | `Null | `Undefined -> None
| e -> raise
    (Invalid_argument (asprintf "Unsupported expression: %a" pprint_expr e))

let translate_updS = function
| [obj; k; v] -> UpdateS (obj, k, v)
| args -> raise (Invalid_argument
    (asprintf "Invalid number of args for %s: %d" updS_name (List.length args)))

let custom_translations = [
  updS_name, translate_updS
]

let letify (funs: string list) = List.(

let rec letify_expr = function
| `Var s -> Var s
| `App (`Var s, es) when Assoc.mem custom_translations s ~equal:String.equal ->
  let translator = Assoc.find_exn custom_translations s ~equal:String.equal in
  let args = map ~f:letify_expr es in
  translator args
(* XXX This heuristic is generally not correct *)
| `App (`Var s, es) when mem funs s ~equal:String.equal ->
  App (s, map es ~f:letify_expr)
| `App(e, es) -> AppE (letify_expr e, map es ~f:letify_expr)
| `ArrayLit (es) -> fold_right es ~init:(Const (Array []))
    ~f:(fun e tail -> App (array_cons, [letify_expr e; tail]))
| `ObjLit (params) -> fold params ~init:(Const (Obj []))
    ~f:(fun obj param -> let (s, e) = extract_object_param param in
      UpdateS (obj, Const (String s), letify_expr e)
    )
| `PropertyAccess (e, s) ->
  AccessS(letify_expr e, Const (String s))
| `ElementAccess (e1, e2) ->
  (* XXX Need to figure if accessing array or object *)
  AccessI(letify_expr e1, letify_expr e2)
| `Number f ->
  if is_int_float f then
    Const (Int (Int.of_float f))
  else Const (Float f)
| `String s -> Const (String s)
| `Undefined -> Const Undefined
| `Null -> Const Null
| `Conditional (eb, e1, e2) ->
  let [@warning "-8"] [eb; e1; e2] = map [eb;e1;e2] ~f:letify_expr in
  If (eb, e1, e2)
| `Binop (op, e1, e2) ->
  let e1, e2 = letify_expr e1, letify_expr e2 in (
    match op with (* XXX This is lazy, handle in backend *)
  | `GreaterEq -> Binop (Or, Binop (Greater, e1, e2), Binop (Eq3, e1, e2))
  | `LessEq -> Binop (Or, Binop (Less, e1, e2), Binop (Eq3, e1, e2))
  | #binop_t as op -> Binop (conv_op op, e1, e2)
  )
(* XXX This translation works for closures of the form `(params) => f(args...params)`.
   For closures that violate this format, additional variants of f would need to be introduced
   that take care of the reordering. Q: is this invariant already established by earlier stages?
*)
| `Arrow (params, `Block [`Expression (`App (`Var s, es))]) as e when
    mem funs s ~equal:String.equal
  ->
    let n_params = length params in
    let n_prefix = length es - n_params in
    let last_args = drop es n_prefix in
    let first_args = take es n_prefix in
    let vs = map last_args ~f:(function `Var s -> s | _ ->
      raise (Invalid_argument
        (asprintf "Closure; last arguments need to be variables: %a" pprint_expr e))) in
    let params1 = map params ~f:(function `Parameter (s, false, None) -> s | _ ->
      raise (Invalid_argument
        (asprintf "Closure; parameters need to be regular: %a" pprint_expr e))) in
    let do_params_match = Poly.(vs = params1) in
    if do_params_match then
      UpdateS (
        Const (Obj [closure_fun_name, String s]),
        Const (String closure_args_name),
        letify_expr (`ArrayLit first_args)
      )
    else
      raise (Invalid_argument
        (asprintf "Closure; last arguments need to match parameters: %a" pprint_expr e))
| e -> raise
    (Invalid_argument (asprintf "Unsupported expression: %a" pprint_expr e))
in
let rec letify_stmt = function
| `Expression e -> letify_expr e
| `If (cond, b1, (Some b2)) ->
  If (letify_expr cond, letify_block b1, letify_block b2)
| stmt -> raise
    (Invalid_argument (asprintf "Unsupported statement: %a" pprint_stmt stmt))
and letify_var_decl = function
| `VarAssignment (s, e) -> Some (s, letify_expr e)
| `Expression (`App (`Var s, [_prop])) when String.equal s assert_name ->
  None
| stmt -> raise
    (Invalid_argument (asprintf "Not a variable declaration: %a" pprint_stmt stmt))
and letify_block = function
| `Block [] -> raise (Invalid_argument "Cannot translate empty block!")
| `Block [stmt] -> letify_stmt stmt
| `Block stmts ->
  let stmts1 = Util.butlast stmts
  and stmt = last_exn stmts in
  let decls = filter_map stmts1 ~f:letify_var_decl
  and e = letify_stmt stmt in
  if is_empty decls then e else Lets (decls, e)
in
let rec preify_stmt = function
| `Expression e -> expr_cond funs e |> Option.map ~f:letify_expr
| `If (cond, b1, Some b2) ->
  let b11 = preify_block b1 in
  let b21 = preify_block b2 in
  let if_cond_opt = (
    if Option.is_none b11 && Option.is_none b21 then
      None
    else Some (If (letify_expr cond, get_bool b11, get_bool b21))
  ) in
  let expr_cond_opt = expr_cond funs cond |> Option.map ~f:letify_expr in
  Option.merge if_cond_opt expr_cond_opt ~f:mk_and
| stmt -> raise
    (Invalid_argument (asprintf "Unsupported statement: %a" pprint_stmt stmt))
and preify_var_decl = function
| `VarAssignment (s, e) ->
  let decl = s, letify_expr e
  and e_cond_opt = expr_cond funs e |> Option.map ~f:letify_expr
  in e_cond_opt, Some decl
| `Expression (`App (`Var s, [prop])) when String.equal s assert_name ->
  Some (letify_expr prop), None
| stmt -> raise
    (Invalid_argument (asprintf "Not a variable declaration: %a" pprint_stmt stmt))
and preify_block = function
| `Block [] -> raise (Invalid_argument "Cannot translate empty block!")
| `Block stmts ->
  let stmts1 = Util.butlast stmts
  and stmt = last_exn stmts in
  let conds, decls = map stmts1 ~f:preify_var_decl |> unzip in
  let decls = filter_opt decls in
  let e = preify_stmt stmt in
  let conds = filter_opt (e :: conds) in
  let cond = reduce conds ~f:mk_and in
  Option.map cond ~f:(fun e ->
    if is_empty decls then e else  Lets (decls, e))
in letify_block, fun b -> preify_block b |> get_bool)

let letify_preify_fun fun_names (name, params, body) =
  let fun_names = fun_names in
  let letify, preify = letify fun_names in
  let body0 = body |> compile_internals in
  let body = body0 |> letify in
  let body_pre = body0 |> preify in
  let param_names = List.map params ~f:(function
  | `Parameter (s, false, None) -> s
  | p -> raise (Invalid_argument (
            asprintf "Cannot tranlsate parameter in function declaration: %a"
              pprint_parameter p))
  ) in
  let typs = List.init (List.length params) ~f:(fun _ -> Val) in
  let func = name, (typs, Val), Fun (param_names, body)
  and pre = fun_name_to_pre name, (typs, Val), Fun (param_names, body_pre) in
  [func; pre]

let letify_program ((tab, b): program) =
  let fun_names = List.map tab ~f:(fun (s, _, _) -> s) in
  let pre_names = List.map fun_names ~f:fun_name_to_pre in
  let fun_names = pre_names @ fun_names @ all_internals in
  let b =
    b
    |> strip_top_level_undefineds
    |> compile_internals
    |> ensure_prop
  in
  let letify, preify = letify fun_names in
  let e, pre = letify b, preify b in
  let funs = List.concat_map tab ~f:(letify_preify_fun fun_names) in
  funs, mk_and e pre