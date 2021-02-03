@gentype
type rec expr =
  | VarDecl(string, expr)
  | Var(string)
  | App(expr, list<expr>)
  | Number(string)
  | String(string)
  | Undefined
  | Null
