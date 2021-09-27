open Tsast
open Ast_t
open AstTransformers
open BasicTypes
open Base

let free_vars = LambdaLifting.free_vars
let internal_fun_names = Consts.builtins

(* XXX Move, see also insert_block *)
let push_block e = function
| `Block b -> `Block (b @ [e])

let bind_vars_from_obj frees e =
  List.map frees ~f:(fun s -> `VarAssignment (s, `PropertyAccess (e, s)))

let while_to_function bounds name = function `While (cond, body) as stmt ->
  (* Assume distinct and unique *)
  let frees = free_vars ~bounds stmt in
  let params = List.map frees ~f:(fun s -> `Parameter (s, false, None)) in
  let free_vars = List.map frees ~f:(fun s -> `Var s) in
  let recursion: expr = `App (`Var name, free_vars) in
  let bt = push_block (`Return (Some recursion): stmt) body in
  let bf = `Block [`Return (Some (`ObjLit params))] in
  let body1 = `If (cond, bt, Some bf) in
  let func_decl = name, params, `Block [body1] in
  (* XXX This could yield a name clash. Invent a proper fresh variable for current scope. *)
  let result_name = name ^ "_result" in
  let assignment = `VarAssignment (result_name, recursion) in
  let assignments = bind_vars_from_obj frees (`Var result_name) in
  let replacement = assignment :: assignments in
  func_decl, replacement

(* Modify ast_transformer such that single statements can be replaced by multiple statements. *)
class ['b,'a] ast_stmt_multi_transformer = object(self)
  inherit ['b, 'a] ast_transformer

  method stmt_multi (down: 'b) (acc: 'a) stmt =
    let acc1, r = self#stmt down acc stmt in
    acc1, [r]

  method! block (down: 'b) (acc: 'a) = function
  | `Block blocks ->
    let (acc1, blocks1) = List.fold_map ~f:(self#stmt_multi down) ~init:acc blocks in
    acc1, `Block (List.concat blocks1)

end

class lifter = object(self)
  inherit [string, fun_decl list] ast_stmt_multi_transformer as super

  (* method! expr name acc = function
  | e -> super#expr name acc e *)

  method! stmt_multi name acc = function
  | `While (cond, body) ->
    (* Replace with super? *)
    let acc0, cond1 = self#expr name acc cond in
    let acc1, body1 = self#block name acc0 body in
    let stmt = `While (cond1, body1) in
    let bounds = List.map acc1 ~f:(fun (s, _, _) -> s) @ internal_fun_names in
    let f_name = Util.invent_name1 bounds (name ^ "$loop") in
    let func_decl, replacements = while_to_function bounds f_name stmt in
    let acc2 = func_decl :: acc1 in
    acc2, replacements
  | `FunctionDecl(s, _, _) | `VarAssignment (s, _) as s0 ->
    super#stmt_multi (name ^ "_" ^ s) acc s0
  | s -> super#stmt_multi name acc s

end

let the_lifter = new lifter

let lift ?prefix:(prefix="#top") ?tab:(tab=[]) b =
  (* XXX Pass in all function names to avoid name clashes in invented names *)
  the_lifter#block prefix tab b

let lift_program (tab, b) =
  let orig_len = List.length tab in
  (* We first append everything to tab, and then remove the old stuff *)
  let tab1, tab2 = List.fold_map tab ~init:tab ~f:(fun tab ->
    function (s, params, b) ->
      let tab1, b1 = lift ~prefix:s ~tab b in
      tab1, (s, params, b1)
    ) in
  (* [tab1] now contains [[new_defs] @ tab] and [tab2] contains updated defs from [tab]. *)
  let tab3 = List.take tab1 (List.length tab1 - orig_len) @ tab2 in
  lift ~tab:tab3 b
