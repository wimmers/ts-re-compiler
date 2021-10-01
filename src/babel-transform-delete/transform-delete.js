/*
* Replace `delete o.x` with `o[x] = undefined`.
*/
module.exports = function({types: t}) {
    const visitor = {
      ExpressionStatement(path){
        const node = path.node.expression
        if (!t.isUnaryExpression(node, {operator: "delete"})) return
        const argument = node.argument
        if (!t.isMemberExpression(argument)) return
        const undefined = t.identifier("undefined")
        const assignment = t.assignmentExpression("=", argument, undefined)
        path.replaceWith(assignment)
      }
    }
    return {
        visitor
    }
}