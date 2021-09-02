// Replace `typeof e` and `!b` by `_typeof(e)` and `_neg(b)`, respectively.
module.exports = function({types: t}) {
  return {
      visitor: {
          UnaryExpression(path){
            const node = path.node;
            let fun;
            switch (node.operator) {
                case "!":
                    fun = t.identifier("_neg")
                    break;
                case "typeof":
                    fun = t.identifier("_typeof")
                    break;
                default:
                    return;
            }
            const call = t.callExpression(fun, [node.argument])
            path.replaceWith(call)
          }
      }
  }
}