open Tsast;;
open Ast_t;;
open Base;;

class ['b,'a] ast_transformer = object(self)

  method stmt (down: 'b) (acc: 'a) = function
  | `VarAssignment(s, e) ->
    let (acc1, e1) = self#expr down acc e in
    (acc1, `VarAssignment(s, e1))
  | `FunctionDecl(s, params, b) ->
    let (acc1, params1, b1) = self#func down acc params b in
    (acc1, `FunctionDecl (s, params1, b1))
  | `If(b, e1, e2_opt) ->
    let (acc1, b1) = self#expr down acc b in
    let (acc2, e11) = self#block down acc1 e1 in (
    match e2_opt with
        | None -> (acc2, `If(b1, e11, None))
        | Some e2 ->
          let (acc3, e22) = self#block down acc2 e2 in
          (acc3, `If(b1, e11, Some e22))
    )
  | `While(b, e) ->
    let acc1, b1 = self#expr down acc b in
    let acc2, e1 = self#block down acc1 e in
    acc2, `While (b1, e1)
  | `Return(Some e) ->
    let (acc1, e1) = self#expr down acc e in
    (acc1, `Return(Some e1))
  | `Expression(e) ->
    let (acc1, e1) = self#expr down acc e in
    (acc1, `Expression(e1))
  | s -> ((acc, s): ('a * stmt))

  method expr (down: 'b) (acc: 'a) = function
  | `App(e, es) ->
    let (acc1, e1) = self#expr down acc e in
    let (acc2, es1) = List.fold_map ~f:(self#expr down) ~init:acc1 es in
    (acc2, `App(e1, es1))
  | `Arrow(params, b) ->
    let (acc1, params1, b1) = self#func down acc params b in
    (acc1, `Arrow (params1, b1))
  | `ObjLit(params) ->
    let (acc1, params1) = List.fold_map ~f:(self#parameter down) ~init:acc params in
    (acc1, `ObjLit(params1))
  | `ArrayLit(es) ->
    let (acc1, params1) = List.fold_map ~f:(self#expr down) ~init:acc es in
    (acc1, `ArrayLit(params1))
  | `Conditional(b, e1, e2) ->
    let (acc1, b1) = self#expr down acc b in
    let (acc2, e11) = self#expr down acc1 e1 in
    let (acc3, e21) = self#expr down acc2 e2 in
    (acc3, `Conditional (b1, e11, e21))
  | `Binop(op, e1, e2) ->
    let (acc1, e11) = self#expr down acc e1 in
    let (acc2, e22) = self#expr down acc1 e2 in
    (acc2, `Binop(op, e11, e22))
  | `Spread(e) ->
    let (acc1, e1) = self#expr down acc e in
    (acc1, `Spread(e1))
  | `ElementAccess(e1, e2) ->
    let (acc1, e11) = self#expr down acc e1 in
    let (acc2, e21) = self#expr down acc1 e2 in
    (acc2, `ElementAccess(e11, e21))
  | `PropertyAccess(e, s) ->
    let (acc1, e1) = self#expr down acc e in
    (acc1, `PropertyAccess(e1, s))
  | e -> ((acc, e): ('a * expr))

  method block (down: 'b) (acc: 'a) = function
    | `Block blocks ->
      let (acc1, blocks1) = List.fold_map ~f:(self#stmt down) ~init:acc blocks in
      (acc1, `Block(blocks1))

  method parameter (down: 'b) (acc: 'a) = function
    | `Parameter (s, b, Some(e)) ->
      let (acc1, e1) = self#expr down acc e in
      (acc1, `Parameter(s,b,Some(e1)))
    | `Parameter _ as p -> ((acc, p): ('a * parameter))

  method func (down: 'b) (acc: 'a) (params: parameter list) (b: block): ('a * parameter list * block)  =
    let (acc1, b1) = self#block down acc b in
    let (acc2, params) = List.fold_map ~f:(self#parameter down) ~init:acc1 params in
    (acc2, params, b1)
  
  method program (down: 'b) (acc: 'a) ((tab, block): BasicTypes.program): 'a * BasicTypes.program =
    let program_folder = fun acc (name, params, body) ->
      let acc1, params1, body1 = self#func down acc params body in
      acc1, (name, params1, body1)
    in
    let acc1, tab1 = List.fold_map tab ~f:program_folder ~init:acc in
    let acc2, block1 = self#block down acc1 block in
    acc2, (tab1, block1)


end


(** @deprecated The implementation is currently incomplete and should not be used. *)
class ['a] ast_folder = object(self)

  method func (acc: 'a) (params: parameter list) (b: block): 'a =
    List.fold ~f:self#parameter ~init:(self#block acc b) params

  method stmt (acc: 'a) = function
  | `VarAssignment(_s, e) -> self#expr acc e
  | `FunctionDecl(_s, params, b) -> self#func acc params b
  | `If(b, e1, e2_opt) -> (
    self#expr acc b
    |> fun acc -> self#block acc e1
    |> fun acc -> match e2_opt with
        | None -> acc
        | Some e2 -> self#block acc e2
  )
  | `While(b, e) -> self#expr acc b |> fun acc -> self#block acc e
  | _ -> acc

  method expr (acc: 'a) = function
  | `App(e, es) -> List.fold ~f:self#expr ~init:(self#expr acc e) es
  | `Arrow(params, b) -> self#func acc params b
  | `ObjLit(params) ->
    List.fold ~f:self#parameter ~init:acc params
  | `ArrayLit(es) ->
    List.fold ~f:self#expr ~init:acc es
  | `Conditional(be, e1, e2) -> (
    self#expr acc be
    |> fun acc -> self#expr acc e1
    |> fun acc -> self#expr acc e2
  )
  | `Binop(_op, e1, e2) ->
    self#expr acc e1
    |> fun acc -> self#expr acc e2
  | _ -> acc

  method block (acc: 'a) = function
    | `Block blocks ->
      (List.fold ~f:self#stmt ~init:acc blocks: 'a)

  method parameter (acc: 'a) = function
    | `Parameter (_s, _b, Some(e)) -> self#expr acc e
    | `Parameter (_, _, None) -> acc

end