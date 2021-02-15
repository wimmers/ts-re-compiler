export mkVarDecl: (_, _) => Ast_t.expr = (s, e) => #VarDecl(s, e)
export mkVar: string => Ast_t.expr = s => #Var(s)
export mkApp: (_, _) => Ast_t.expr = (e, xs) => #App(e, Array.to_list(xs))
export mkNumber: _ => Ast_t.expr = x => #Number(x)
export mkString: _ => Ast_t.expr = x => #String(x)
export mkUndefined: Ast_t.expr = #Undefined
export mkNull: Ast_t.expr = #Null
export mkFunctionDecl: (_, _, _) => Ast_t.expr = (s, ps, e) =>
  #FunctionDecl(s, Array.to_list(ps), e)
export mkReturn1: Ast_t.expr = #Return(None)
export mkReturn2: _ => Ast_t.expr = e => #Return(Some(e))
export mkObjLit: _ => Ast_t.expr = xs => #ObjLit(Array.to_list(xs))
export mkArrayLit: _ => Ast_t.expr = xs => #ArrayLit(Array.to_list(xs))
export mkSpread: _ => Ast_t.expr = e => #Spread(e)
export mkIf1: (_, _) => Ast_t.expr = (b, e) => #If(b, e, None)
export mkIf2: (_, _, _) => Ast_t.expr = (b, e1, e2) => #If(b, e1, e2)
export mkBinop: (_, _, _) => Ast_t.expr = (op, e1, e2) => #Binop(op, e1, e2)
export mkArrow: (_, _) => Ast_t.expr = (xs, block) => #Arrow(Array.to_list(xs), block)
export mkObjectBindingPattern: (_, _) => Ast_t.expr = (xs, e) =>
  #VarObjectPatternDecl(Array.to_list(xs), e)
export mkArrayBindingPattern: (_, _) => Ast_t.expr = (xs, e) =>
  #VarArrayPatternDecl(Array.to_list(xs), e)

export mkParameter1: (_, _) => Ast_t.parameter = (s, b) => #Parameter(s, b, None)
export mkParameter2: (_, _, _) => Ast_t.parameter = (s, b, e) => #Parameter(s, b, Some(e))

export mkBlock: _ => Ast_t.block = xs => #Block(Array.to_list(xs))
