(* Auto-generated from "Ast.atd" *)
              [@@@ocaml.warning "-27-32-35-39"]

type binop = Ast_t.binop

type block = Ast_t.block

and expr = Ast_t.expr

and parameter = Ast_t.parameter

val read_binop :  binop Atdgen_codec_runtime.Decode.t

val write_binop :  binop Atdgen_codec_runtime.Encode.t

val read_block :  block Atdgen_codec_runtime.Decode.t

val write_block :  block Atdgen_codec_runtime.Encode.t

val read_expr :  expr Atdgen_codec_runtime.Decode.t

val write_expr :  expr Atdgen_codec_runtime.Encode.t

val read_parameter :  parameter Atdgen_codec_runtime.Decode.t

val write_parameter :  parameter Atdgen_codec_runtime.Encode.t

