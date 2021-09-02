(* Auto-generated from "Ast.atd" *)
              [@@@ocaml.warning "-27-32-35-39"]

type binop = [
    `Eq | `Eq2 | `Eq3 | `Neq2 | `Neq3 | `Times | `Plus | `Minus | `Div
  | `Less | `LessEq | `GreaterEq | `Greater | `And | `Or
]

type block = [ `Block of (stmt list) ]

and expr = [
    `Var of (string)
  | `App of (expr * expr list)
  | `PropertyAccess of (expr * string)
  | `ElementAccess of (expr * expr)
  | `Number of (float)
  | `String of (string)
  | `Null
  | `Undefined
  | `ObjLit of (parameter list)
  | `ArrayLit of (expr list)
  | `Spread of (expr)
  | `Conditional of (expr * expr * expr)
  | `Binop of (binop * expr * expr)
  | `Arrow of (parameter list * block)
  | `Protected of expr
]

and parameter = [ `Parameter of (string * bool * expr option) ]

and stmt = [
    `Expression of (expr)
  | `VarDecl of (string * expr)
  | `FunctionDecl of (string * parameter list * block)
  | `Return of (expr option)
  | `If of (expr * block * block option)
  | `While of (expr * block)
  | `VarObjectPatternDecl of (string list * expr)
  | `VarArrayPatternDecl of (string list * expr)
  | `NoOp
]
