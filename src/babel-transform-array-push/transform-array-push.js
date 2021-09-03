/*
* Replace `a.push(e)` with `a[a.length] = e`.
*/
module.exports = function({types: t}) {
    const length = t.identifier("length")
    const visitor = {
      ExpressionStatement(path){
        const node = path.node.expression
        if (!t.isCallExpression(node)) return
        const callee = node.callee
        if (!t.isMemberExpression(callee, {computed: false})) return
        if (!t.isIdentifier(callee.property, {name: "push"})) return
        const arguments = node.arguments
        if (arguments.length !== 1) return
        const argument = arguments[0]
        const arr = callee.object
        const len = t.memberExpression(arr, length)
        const newLeft = t.memberExpression(arr, len, true)
        const assignment = t.assignmentExpression("=", newLeft, argument)
        path.replaceWith(assignment)
      }
    }
    return {
        visitor
    }
}