(* Auto-generated from "Ast.atd" *)
[@@@ocaml.warning "-27-32-35-39"]

open Tsast;;

type binop = Ast_t.binop

type block = Ast_t.block

and expr = Ast_t.expr

and parameter = Ast_t.parameter

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

