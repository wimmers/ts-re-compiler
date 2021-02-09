(* Auto-generated from "Ast.atd" *)
              [@@@ocaml.warning "-27-32-35-39"]

type binop = Ast_t.binop = 
    Eq2 | Eq3 | Neq2 | Neq3 | Times | Plus | Minus | Div


type block = Ast_t.block =  Block of (expr list) 

and expr = Ast_t.expr = 
    VarDecl of (string * expr)
  | Var of (string)
  | App of (expr * expr list)
  | Number of (float)
  | String of (string)
  | Undefined
  | Null
  | FunctionDecl of (string * parameter list * block)
  | Return of (expr option)
  | ObjLit of (parameter list)
  | ArrayLit of (expr list)
  | VarObjectPatternDecl of (string list * expr)
  | VarArrayPatternDecl of (string list * expr)
  | Spread of (expr)
  | If of (expr * block * block option)
  | Binop of (binop * expr * expr)
  | Arrow of (parameter list * block)


and parameter = Ast_t.parameter = 
  Parameter of (string * bool * expr option)


val read_binop :  binop Atdgen_codec_runtime.Decode.t

val write_binop :  binop Atdgen_codec_runtime.Encode.t

val read_block :  block Atdgen_codec_runtime.Decode.t

val write_block :  block Atdgen_codec_runtime.Encode.t

val read_expr :  expr Atdgen_codec_runtime.Decode.t

val write_expr :  expr Atdgen_codec_runtime.Encode.t

val read_parameter :  parameter Atdgen_codec_runtime.Decode.t

val write_parameter :  parameter Atdgen_codec_runtime.Encode.t

