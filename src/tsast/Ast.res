export mkVarDecl: _ => Ast_t.stmt = s => #VarDecl(s)
export mkVarAssignment: (_, _) => Ast_t.stmt = (s, e) => #VarAssignment(s, e)
export mkFunctionDecl: (_, _, _) => Ast_t.stmt = (s, ps, e) =>
  #FunctionDecl(s, Array.to_list(ps), e)
export mkReturn1: Ast_t.stmt = #Return(None)
export mkReturn2: _ => Ast_t.stmt = e => #Return(Some(e))
export mkObjectBindingPattern: (_, _) => Ast_t.stmt = (xs, e) =>
  #VarObjectPatternDecl(Array.to_list(xs), e)
export mkArrayBindingPattern: (_, _) => Ast_t.stmt = (xs, e) =>
  #VarArrayPatternDecl(Array.to_list(xs), e)
export mkNoOp: Ast_t.stmt = #NoOp
export mkExpression: Ast_t.expr => Ast_t.stmt = e => #Expression(e)
export mkIf1: (_, _) => Ast_t.stmt = (b, e) => #If(b, e, None)
export mkIf2: (_, _, _) => Ast_t.stmt = (b, e1, e2) => #If(b, e1, e2)
export mkWhile: (_, _) => Ast_t.stmt = (b, e) => #While(b, e)

export mkVar: string => Ast_t.expr = s => #Var(s)
export mkApp: (_, _) => Ast_t.expr = (e, xs) => #App(e, Array.to_list(xs))
export mkNumber: _ => Ast_t.expr = x => #Number(x)
export mkString: _ => Ast_t.expr = x => #String(x)
export mkUndefined: Ast_t.expr = #Undefined
export mkNull: Ast_t.expr = #Null
export mkObjLit: _ => Ast_t.expr = xs => #ObjLit(Array.to_list(xs))
export mkArrayLit: _ => Ast_t.expr = xs => #ArrayLit(Array.to_list(xs))
export mkSpread: _ => Ast_t.expr = e => #Spread(e)
export mkConditional: (_, _, _) => Ast_t.expr = (b, e1, e2) => #Conditional(b, e1, e2)
export mkBinop: (_, _, _) => Ast_t.expr = (op, e1, e2) => #Binop(op, e1, e2)
export mkArrow: (_, _) => Ast_t.expr = (xs, block) => #Arrow(Array.to_list(xs), block)
export mkPropertyAccess: (_, _) => Ast_t.expr = (e, s) => #PropertyAccess(e, s)
export mkElementAccess: (_, _) => Ast_t.expr = (e1, e2) => #ElementAccess(e1, e2)

export mkParameter1: (_, _) => Ast_t.parameter = (s, b) => #Parameter(s, b, None)
export mkParameter2: (_, _, _) => Ast_t.parameter = (s, b, e) => #Parameter(s, b, Some(e))

export mkBlock: _ => Ast_t.block = xs => #Block(Array.to_list(xs))
