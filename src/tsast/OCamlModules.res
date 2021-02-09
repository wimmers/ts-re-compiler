export pprintExpr = Pprint.print_expr
export pprintBlock = Pprint.print_block

@genType.opaque export type serializer<'a> = 'a => Js.Json.t
let write_expr: serializer<Ast_t.expr> = Ast_bs.write_expr
let write_block: serializer<Ast_t.block> = Ast_bs.write_block
export serializeExpr = write_expr
export serializeBlock = write_block
