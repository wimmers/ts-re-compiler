/*
* Replace builtins & Babel helpers by our own library functions.
* These translations are very crude and not sound for all input code.
*/

// Replace `obj.f(args)` by `g(args)`. Match on `obj` and `f`.
const obj_prop_replacements = {
  "console": {
    "assert": "_assert",
    "log": "_undefined1"
  },
  "Math": {
    "random": "_undefined0",
    "floor":  "_undefined1"
  },
  "Object": {
    "assign": "_const_2_2" // Assumes `Object.assign({}, obj)` is copy
  }
}

// Replace `f(args)` by `g(args)`. Match on `f`.
const fun_replacements = {
  "choose": "_choose",
  "_slicedToArray": "_const2_1", // for fixed-length array destructuring
  "_toArray": "_id", // for rest-array destructuring
  "_toConsumableArray": "_id" // for [...xs, x]; could be push
}

/*
* Replace `obj.f(args)` by `f(obj, args)`. Match on `f`.
* These all assume that we are talking about arrays.
* More precision could be obtained by instructing Babel to directly translate
* to the right functions.
*/
const prop_replacements = {
  "map": "_map",
  "slice": "_slice"
}

module.exports = function({types: t}) {
    const visitor = {
      MemberExpression(path) {
        const node = path.node
        const object = node.object
        const property = node.property
        if (!t.isIdentifier(object) || !t.isIdentifier(property)) return
        const obj = obj_prop_replacements[object.name]
        if (!obj) return
        const replacement = obj[property.name]
        if (!replacement) return
        path.replaceWith(t.identifier(replacement))
      },
      CallExpression(path) {
        const callee = path.node.callee
        if (t.isIdentifier(callee)) {
          const replacement = fun_replacements[callee.name]
          if (!replacement) return
          path.get("callee").replaceWith(t.identifier(replacement))
        }
        else if (t.isMemberExpression(callee)) {
          const replacement = prop_replacements[callee.property.name]
          if (!replacement) return
          const args = path.node.arguments
          args.unshift(callee.object)
          const newCallExpression = t.callExpression(
            t.identifier(replacement), args)
          path.replaceWith(newCallExpression)
        }
      }
    }
    return {
        visitor
    }
}