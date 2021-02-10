open Tsast;;
open Ast_t;;
open Base;;

let (|>) v f = f v

class ['a,'b] ast_transformer = object(self)

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

class lifter2 = object
  inherit [(string * parameter list * block) list, string] ast_transformer as super

  method! func name acc params b =
    super#func name ((name, params, b) :: acc) params b

  method! expr name acc = function
  | VarDecl (s, _) as e0 -> super#expr (name ^ "_" ^ s) acc e0
  | FunctionDecl(s, _params, _b) as e0 ->
    let name1 = name ^ "_" ^ s in
    (* super#expr name1 ((name1, params, b) :: acc) e0 *)
    super#expr name1 acc e0
  | e -> super#expr name acc e
end

let the_lifter2 = new lifter2

let lift2 b =
  let (tab, b1) = the_lifter2#block "#top" [] b in
  (tab, b1)