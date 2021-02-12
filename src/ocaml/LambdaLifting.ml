open Tsast;;
open Ast_t;;
open Base;;

let (|>) v f = f v

class ['b,'a] ast_transformer = object(self)

  method expr (down: 'b) (acc: 'a) = function
  | VarDecl(s, e) ->
    let (acc1, e1) = self#expr down acc e in
    (acc1, VarDecl(s, e1))
  | App(e, es) ->
    let (acc1, e1) = self#expr down acc e in
    let (acc2, es1) = List.fold_map ~f:(self#expr down) ~init:acc1 es in
    (acc2, App(e1, es1))
  | FunctionDecl(s, params, b) ->
    let (acc1, params1, b1) = self#func down acc params b in
    (acc1, FunctionDecl (s, params1, b1))
  | Arrow(params, b) ->
    let (acc1, params1, b1) = self#func down acc params b in
    (acc1, Arrow (params1, b1))
  | ObjLit(params) ->
    let (acc1, params1) = List.fold_map ~f:(self#parameter down) ~init:acc params in
    (acc1, ObjLit(params1))
  | ArrayLit(es) ->
    let (acc1, params1) = List.fold_map ~f:(self#expr down) ~init:acc es in
    (acc1, ArrayLit(params1))
  | If(b, e1, e2_opt) ->
    let (acc1, b1) = self#expr down acc b in
    let (acc2, e11) = self#block down acc1 e1 in (
    match e2_opt with
        | None -> (acc2, If(b1, e11, None))
        | Some e2 ->
          let (acc3, e22) = self#block down acc2 e2 in
          (acc3, If(b1, e11, Some e22))
    )
  | Binop(op, e1, e2) ->
    let (acc1, e11) = self#expr down acc e1 in
    let (acc2, e22) = self#expr down acc1 e2 in
    (acc2, Binop(op, e11, e22))
  | Return(Some e) ->
    let (acc1, e1) = self#expr down acc e in
    (acc1, Return(Some e1))
  | Spread(e) ->
    let (acc1, e1) = self#expr down acc e in
    (acc1, Spread(e1))
  | e -> ((acc, e): ('a * expr))

  method block (down: 'b) (acc: 'a) = function
    | Block blocks ->
      let (acc1, blocks1) = List.fold_map ~f:(self#expr down) ~init:acc blocks in
      (acc1, Block(blocks1))

  method parameter (down: 'b) (acc: 'a) = function
    | Parameter (s, b, Some(e)) ->
      let (acc1, e1) = self#expr down acc e in
      (acc1, Parameter(s,b,Some(e1)))
    | Parameter _ as p -> ((acc, p): ('a * parameter))

  method func (down: 'b) (acc: 'a) (params: parameter list) (b: block): ('a * parameter list * block)  =
    let (acc1, b1) = self#block down acc b in
    let (acc2, params) = List.fold_map ~f:(self#parameter down) ~init:acc1 params in
    (acc2, params, b1)

end


class ['a] ast_folder = object(self)

  method func (acc: 'a) (params: parameter list) (b: block): 'a =
    List.fold ~f:self#parameter ~init:(self#block acc b) params

  method expr (acc: 'a) = function
  | VarDecl(_s, e) -> self#expr acc e
  | App(e, es) -> List.fold ~f:self#expr ~init:(self#expr acc e) es
  | FunctionDecl(_s, params, b) -> self#func acc params b
  | Arrow(params, b) -> self#func acc params b
  | ObjLit(params) ->
    List.fold ~f:self#parameter ~init:acc params
  | ArrayLit(es) ->
    List.fold ~f:self#expr ~init:acc es
  | If(b, e1, e2_opt) -> (
    self#expr acc b
    |> fun acc -> self#block acc e1
    |> fun acc -> match e2_opt with
        | None -> acc
        | Some e2 -> self#block acc e2
  )
  | Binop(_op, e1, e2) ->
    self#expr acc e1
    |> fun acc -> self#expr acc e2
  | _ -> acc

  method block (acc: 'a) = function
    | Block blocks ->
      (List.fold ~f:self#expr ~init:acc blocks: 'a)

  method parameter (acc: 'a) = function
    | Parameter (_s, _b, Some(e)) -> self#expr acc e
    | Parameter (_, _, None) -> acc

end

class lifter = object
  inherit [string * (string * parameter list * block) list] ast_folder as super

  method! func acc params b =
    let (name, xs) = acc in
    (name, (name, params, b) :: xs)

  method! expr acc = function
  | VarDecl (s, e) ->
    let (_name, xs) = acc in super#expr (s, xs) e
  | FunctionDecl(s, params, b) ->
    let (name, xs) = acc in
    (name, (s, params, b) :: xs)
  | e -> super#expr acc e
end

let the_lifter = new lifter

let lift b =
  let (_, tab) = the_lifter#block ("#top", []) b in
  tab

let get_parameter_var = function
  Parameter (s, _, _) -> s

let get_parameter_vars = List.map ~f:get_parameter_var

class free_vars_computer = object(self)
  inherit [string list, string list] ast_transformer as super

  val add_bounds = fun bounds -> function
  | VarDecl (s, _) -> s :: bounds
  | FunctionDecl (s, _, _) -> s :: bounds
  | VarObjectPatternDecl (xs, _) -> xs @ bounds
  | VarArrayPatternDecl (xs, _) -> xs @ bounds
  | _ -> bounds

  method! expr bounds frees = function
  | Var (s) as e ->
    let frees1 = if List.mem bounds s ~equal:String.equal then frees else s :: frees in
    (frees1, e)
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

let free_vars e =
  let (frees, _) = the_free_vars_computer#expr [] [] e in
  List.dedup_and_sort ~compare:(String.compare) frees

let make_params = List.map ~f:(fun p -> Parameter(p, false, None))
class lifter2 = object
  inherit [string, (string * parameter list * block) list] ast_transformer as super

  method! func name acc params b =
    super#func name ((name, params, b) :: acc) params b

  val make_partial = fun (s, params_0, params_ext) ->
    let ps = get_parameter_vars params_0 in
    let args = List.map ~f:(fun v -> Var (v)) (params_ext @ ps) in
    Arrow(params_0, Block [App(Var(s), args)])

  method! expr name acc = function
  | VarDecl (s, _) as e0 -> super#expr (name ^ "_" ^ s) acc e0
  | Arrow (params, b) as e0 ->
    let (acc1, params1, b1) = super#func name acc params b in
    let frees = free_vars e0 in
    let () = Util.print_string_list frees in
    let new_params = make_params frees @ params1 in
    let e1 = make_partial (name, params, frees)
    and acc2 = (name, new_params, b1) :: acc1 in
    (acc2, e1)
  | FunctionDecl(s, params, b) as e0 ->
    let name1 = name ^ "_" ^ s in
    let (acc1, params1, b1) = super#func name1 acc params b in
    let frees = free_vars e0 in
    let new_params = make_params frees @ params1 in
    let e1 = VarDecl (s, make_partial (name1, params, frees))
    and acc2 = (name1, new_params, b1) :: acc1 in
    (acc2, e1)
  | e -> super#expr name acc e
end

let the_lifter2 = new lifter2

let lift2 b =
  let (tab, b1) = the_lifter2#block "#top" [] b in
  (tab, b1)

type func_tab = (string, parameter list * string * expr list, String.comparator_witness) Base.Map.t

let pp_expr_list = Util.pp_list Pprint.pprint_expr
let pp_parameter_list = Util.pp_list Pprint.pprint_parameter

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