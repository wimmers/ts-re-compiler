@gentype
type binop =
  | Eq2
  | Eq3
  | Neq2
  | Neq3
  | Times
  | Plus
  | Minus
  | Div

@gentype.opaque
type rec expr =
  | VarDecl(string, expr)
  | Var(string)
  | App(expr, list<expr>)
  | Number(float)
  | String(string)
  | Undefined
  | Null
  | FunctionDecl(string, list<parameter>, block)
  | Return(option<expr>)
  | ObjLit(list<parameter>)
  | ArrayLit(list<expr>)
  | Spread(expr)
  | If(expr, block, option<block>)
  | Binop(binop, expr, expr)
  | Arrow(list<parameter>, block)
@gentype.opaque and parameter = Parameter(string, bool, option<expr>)
@gentype.opaque and block = Block(list<expr>)

export mkVarDecl = (s, e) => VarDecl(s, e)
export mkVar = s => Var(s)
export mkApp = (e, xs) => App(e, Array.to_list(xs))
export mkNumber = x => Number(x)
export mkString = x => String(x)
export mkUndefined = Undefined
export mkNull = Null
export mkFunctionDecl = (s, ps, e) => FunctionDecl(s, Array.to_list(ps), e)
export mkReturn1 = Return(None)
export mkReturn2 = e => Return(Some(e))
export mkObjLit = xs => ObjLit(Array.to_list(xs))
export mkArrayLit = xs => ArrayLit(Array.to_list(xs))
export mkSpread = e => Spread(e)
export mkIf1 = (b, e) => If(b, e, None)
export mkIf2 = (b, e1, e2) => If(b, e1, e2)
export mkBinop = (op, e1, e2) => Binop(op, e1, e2)
export mkArrow = (xs, block) => Arrow(Array.to_list(xs), block)

export mkParameter1 = (s, b) => Parameter(s, b, None)
export mkParameter2 = (s, b, e) => Parameter(s, b, Some(e))

export mkBlock = xs => Block(Array.to_list(xs))
