(* Auto-generated from "Ast.atd" *)
              [@@@ocaml.warning "-27-32-35-39"]

type [@gentype] binop = [ `Eq2 | `Eq3 | `Neq2 | `Neq3 | `Times | `Plus | `Minus | `Div ]

type [@gentype.opaque] block = [ `Block of (expr list) ]

and [@gentype.opaque] expr = [
    `VarDecl of (string * expr)
  | `Var of (string)
  | `App of (expr * expr list)
  | `Number of (float)
  | `String of (string)
  | `Undefined
  | `Null
  | `FunctionDecl of (string * parameter list * block)
  | `Return of (expr option)
  | `ObjLit of (parameter list)
  | `ArrayLit of (expr list)
  | `VarObjectPatternDecl of (string list * expr)
  | `VarArrayPatternDecl of (string list * expr)
  | `Spread of (expr)
  | `If of (expr * block * block option)
  | `Binop of (binop * expr * expr)
  | `Arrow of (parameter list * block)
]

and [@gentype.opaque] parameter = [ `Parameter of (string * bool * expr option) ]
