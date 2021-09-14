/*
* Replace `o[e] = v` with `const _tmp = _upd(o, e, v); o = _tmp`.
* Replace `o.k = v` with `const _tmp = _updS(o, k, v); o = _tmp`.
*/
module.exports = function({types: t}) {
    const updFn = t.identifier("_upd")
    const updFnS = t.identifier("_updS")
    const visitor = {
      ExpressionStatement(path){
        const node = path.node.expression
        if (!t.isAssignmentExpression(node, {operator: "="})) return
        const left = node.left
        if (!t.isMemberExpression(left)) return
        const right = node.right
        const object = left.object
        const property = left.property
        const fn = left.computed ? updFn : updFnS
        const prop = left.computed ? property : t.stringLiteral(property.name)
        const newRight = t.callExpression(fn, [object, prop, right])
        const id = path.scope.generateUidIdentifier("tmp")
        const declarator = t.variableDeclarator(id, newRight)
        const declaration = t.variableDeclaration("const", [declarator])
        const assignment = t.assignmentExpression("=", object, id)
        path.replaceWithMultiple(
          [declaration, t.expressionStatement(assignment)])
      }
    }
    return {
        visitor
    }
}