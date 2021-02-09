export mkVarDecl = (s, e) => Ast_t.VarDecl(s, e)
export mkVar = s => Ast_t.Var(s)
export mkApp = (e, xs) => Ast_t.App(e, Array.to_list(xs))
export mkNumber = x => Ast_t.Number(x)
export mkString = x => Ast_t.String(x)
export mkUndefined = Ast_t.Undefined
export mkNull = Ast_t.Null
export mkFunctionDecl = (s, ps, e) => Ast_t.FunctionDecl(s, Array.to_list(ps), e)
export mkReturn1 = Ast_t.Return(None)
export mkReturn2 = e => Ast_t.Return(Some(e))
export mkObjLit = xs => Ast_t.ObjLit(Array.to_list(xs))
export mkArrayLit = xs => Ast_t.ArrayLit(Array.to_list(xs))
export mkSpread = e => Ast_t.Spread(e)
export mkIf1 = (b, e) => Ast_t.If(b, e, None)
export mkIf2 = (b, e1, e2) => Ast_t.If(b, e1, e2)
export mkBinop = (op, e1, e2) => Ast_t.Binop(op, e1, e2)
export mkArrow = (xs, block) => Ast_t.Arrow(Array.to_list(xs), block)
export mkObjectBindingPattern = (xs, e) => Ast_t.VarObjectPatternDecl(Array.to_list(xs), e)
export mkArrayBindingPattern = (xs, e) => Ast_t.VarArrayPatternDecl(Array.to_list(xs), e)

export mkParameter1 = (s, b) => Ast_t.Parameter(s, b, None)
export mkParameter2 = (s, b, e) => Ast_t.Parameter(s, b, Some(e))

export mkBlock = xs => Ast_t.Block(Array.to_list(xs))
