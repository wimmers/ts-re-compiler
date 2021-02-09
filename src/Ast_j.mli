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


val write_binop :
  Bi_outbuf.t -> binop -> unit
  (** Output a JSON value of type {!binop}. *)

val string_of_binop :
  ?len:int -> binop -> string
  (** Serialize a value of type {!binop}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_binop :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> binop
  (** Input JSON data of type {!binop}. *)

val binop_of_string :
  string -> binop
  (** Deserialize JSON data of type {!binop}. *)

val write_block :
  Bi_outbuf.t -> block -> unit
  (** Output a JSON value of type {!block}. *)

val string_of_block :
  ?len:int -> block -> string
  (** Serialize a value of type {!block}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_block :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> block
  (** Input JSON data of type {!block}. *)

val block_of_string :
  string -> block
  (** Deserialize JSON data of type {!block}. *)

val write_expr :
  Bi_outbuf.t -> expr -> unit
  (** Output a JSON value of type {!expr}. *)

val string_of_expr :
  ?len:int -> expr -> string
  (** Serialize a value of type {!expr}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_expr :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> expr
  (** Input JSON data of type {!expr}. *)

val expr_of_string :
  string -> expr
  (** Deserialize JSON data of type {!expr}. *)

val write_parameter :
  Bi_outbuf.t -> parameter -> unit
  (** Output a JSON value of type {!parameter}. *)

val string_of_parameter :
  ?len:int -> parameter -> string
  (** Serialize a value of type {!parameter}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_parameter :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> parameter
  (** Input JSON data of type {!parameter}. *)

val parameter_of_string :
  string -> parameter
  (** Deserialize JSON data of type {!parameter}. *)

