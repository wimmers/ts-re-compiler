open AstTransformers

class unprotecter = object
  inherit [unit, unit] ast_transformer as super

  method! expr () () = function
  | `Protected(e) -> super#expr () () e
  | e -> super#expr () () e

end

let the_unprotecter = new unprotecter

(** [unprotect b] removes any [`Protect] markers from block [b] *)
let unprotect b =
  let _, b1 = the_unprotecter#block () () b in b1


class denoper = object
  inherit [unit, unit] ast_transformer as super

  method! block () () = function
  | `Block bs ->
    let bs1 = List.filter((<>) `NoOp) bs in
    super#block () () (`Block bs1)

end

let the_denoper = new denoper

(** [denop b] removes any [`NoOp] markers from block [b] *)
let denop b =
  let _, b1 = the_denoper#block () () b in b1

(** [denop_program p] removes any [`NoOp] markers from program [p] *)
let denop_program p =
  let _, p1 = the_denoper#program () () p in p1


class let_stripper = object
  inherit [unit, unit] ast_transformer as super

  method! stmt () () = function
  | `VarDecl _ -> (), `NoOp
  | stmt -> super#stmt () () stmt

end

let the_let_stripper = new let_stripper

(** [strip_let p] removes any [`NoOp] markers from program [p] *)
let strip_let p =
  let _, p1 = the_let_stripper#program () () p in p1


class function_stripper function_names = object
  inherit [unit, unit] ast_transformer as super

  method! expr () () = function
  | `App(`Var(x), [arg]) as e0 ->
    let e1 = if List.mem x function_names then arg else e0 in
    super#expr () () e1
  | e -> super#expr () () e

end


let strip_functions function_names b =
  let the_function_stripper = new function_stripper function_names in
  let _, b1 = the_function_stripper#block () () b in
  b1