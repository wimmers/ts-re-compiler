/* Replace `{...o, x, y: 3}` with `_upd(_upd(o, x, x), y, 3)`. */

module.exports = function({types: t}) {
    const updFn = t.identifier("_updS")
    return {
        visitor: {
            ObjectExpression(path){
              const node = path.node
              const properties = node.properties
              if (properties.length === 0) return
              const first = properties[0]
              if (!t.isSpreadElement(first)) return
              const [_, ...props] = properties
              if (!props.every(t.isProperty)) return
              const obj = first.argument
              const result = props.reduce(
                (obj, param) =>
                  t.callExpression(updFn,
                    [obj, t.stringLiteral(param.key.name), param.value]),
                obj
              )
              path.replaceWith(result)
            }
        }
    }
}