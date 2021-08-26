open Simple_fun.SimpleFun
open Tsast
open Pprint
open BasicTypes
open Base

let  x = Float.Parts.fractional
let is_int_float v =
  let c = Float.classify (Float.Parts.fractional (Float.modf v)) in
  Poly.(c = Zero)

module Builtins =
struct
  let array_cons = "array_cons"
  let array_append = "array_append"

  let all_internals = [array_cons; array_append]
end

let asprintf = Caml.Format.asprintf

let strip_top_level_undefineds: Ast_t.block -> Ast_t.block = function
| `Block xs ->
  let xs1 = List.filter xs ~f:(function `Expression `Undefined -> false | _ -> true) in
  `Block xs1

let conv_op = function
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
            `App (`Var Builtins.array_append, [e1; tail]))
  | e -> super#expr () () e

end

let compile_internals =
  let the_internals_compiler = new internals_compiler in
  fun block -> let (), block1 = the_internals_compiler#block () () block in
  block1

let ensure_prop_stmt = function
| `Expression (`App (`PropertyAccess (`Var "console", "assert"), [prop]))
  -> `Expression prop
| s -> raise (Invalid_argument (asprintf "Not a prop: %a" pprint_stmt s)) 

let ensure_prop: Ast_t.block -> Ast_t.block = function
| `Block xs ->
  if List.is_empty xs then
    raise (Invalid_argument "Empty block is not a prop!")
  else
    let stmt = List.last_exn xs in
    `Block (Util.butlast xs @ [ensure_prop_stmt stmt])


let letify (funs: string list) =

let rec letify_expr = function
| `Var s -> Var s
(* XXX This heuristic is generally not correct *)
| `App (`Var s, es) when List.mem funs s ~equal:String.equal ->
  App (s, List.map es ~f:letify_expr)
| `App(e, es) -> AppE (letify_expr e, List.map es ~f:letify_expr)
| `ArrayLit (es) -> List.fold_right es ~init:(Const (Array []))
    ~f:(fun e tail -> App (Builtins.array_cons, [letify_expr e; tail]))
| `ObjLit (params) -> List.fold params ~init:(Const (Obj []))
    ~f:(fun obj -> function
        | `Parameter (s, false, Some e) ->
          UpdateS (obj, Const (String s), letify_expr e)
        | `Parameter (s, false, None) ->
          UpdateS (obj, Const (String s), Var s)
        | p ->
          raise (Invalid_argument (
            asprintf "Cannot tranlsate parameter in object literal: %a"
              pprint_parameter p))
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
  let [@warning "-8"] [eb; e1; e2] = List.map [eb;e1;e2] ~f:letify_expr in
  If (eb, e1, e2)
| `Binop (op, e1, e2) ->
  Binop (conv_op op, letify_expr e1, letify_expr e2)
(* XXX This translation works for closures of the form `(params) => f(args...params)`.
   For closures that violate this format, additional variants of f would need to be introduced
   that take care of the reordering. Q: is this invariant already established by earlier stages?
*)
| `Arrow (params, `Block [`Expression (`App (`Var s, es))]) as e when
    List.mem funs s ~equal:String.equal
  ->
    let n_params = List.length params in
    let n_prefix = List.length es - n_params in
    let last_args = List.drop es n_prefix in
    let first_args = List.take es n_prefix in
    let vs = List.map last_args ~f:(function `Var s -> s | _ ->
      raise (Invalid_argument
        (asprintf "Closure; last arguments need to be variables: %a" pprint_expr e))) in
    let params1 = List.map params ~f:(function `Parameter (s, false, None) -> s | _ ->
      raise (Invalid_argument
        (asprintf "Closure; parameters need to be regular: %a" pprint_expr e))) in
    let do_params_match = Poly.(vs = params1) in
    if do_params_match then
      UpdateS (
        Const (Obj ["fun", String s]),
        Const (String "args"),
        letify_expr (`ArrayLit first_args)
      )
    else
      raise (Invalid_argument
        (asprintf "Closure; last arguments need to match parameters: %a" pprint_expr e))
| e -> raise
    (Invalid_argument (asprintf "Unsupported expression: %a" pprint_expr e))
and letify_stmt = function
| `Expression e -> letify_expr e
| `If (cond, b1, (Some b2)) ->
  If (letify_expr cond, letify_block b1, letify_block b2)
| stmt -> raise
    (Invalid_argument (asprintf "Unsupported statement: %a" pprint_stmt stmt))
and letify_var_decl = function
| `VarDecl (s, e) -> (s, letify_expr e)
| stmt -> raise
    (Invalid_argument (asprintf "Not a variable declaration: %a" pprint_stmt stmt))
and letify_block = function
| `Block [] -> raise (Invalid_argument "Cannot translate empty block!")
| `Block [stmt] -> letify_stmt stmt
| `Block stmts ->
  let stmts1 = Util.butlast stmts
  and stmt = List.last_exn stmts in
  let decls = List.map stmts1 ~f:letify_var_decl
  and e = letify_stmt stmt in
  Lets (decls, e)
in letify_block

let letify_fun fun_names (name, params, body) =
  let body =
    body
    |> compile_internals
    |> letify fun_names
  in
  let param_names = List.map params ~f:(function
  | `Parameter (s, false, None) -> s
  | p -> raise (Invalid_argument (
            asprintf "Cannot tranlsate parameter in function declaration: %a"
              pprint_parameter p))
  ) in
  let typs = List.init (List.length params) ~f:(fun _ -> Val) in
  name, (typs, Val), Fun (param_names, body)

let letify_program ((tab, b): program) =
  let fun_names = List.map tab ~f:(fun (s, _, _) -> s) in
  let fun_names = fun_names @ Builtins.all_internals in
  let b =
    b
    |> strip_top_level_undefineds
    |> compile_internals
    |> ensure_prop
  in
  let e = letify fun_names b in
  let funs = List.map tab ~f:(letify_fun fun_names) in
  funs, e