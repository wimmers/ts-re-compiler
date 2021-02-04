@gentype.opaque
type rec expr =
  | VarDecl(string, expr)
  | Var(string)
  | App(expr, array<expr>)
  | Number(float)
  | String(string)
  | Undefined
  | Null

export mkVarDecl = (s, e) => VarDecl(s, e)
export mkVar = s => Var(s)
export mkApp = (e, xs) => App(e, xs)
export mkNumber = x => Number(x)
export mkString = x => String(x)
export mkUndefined = Undefined
export mkNull = Null
