// import hoistVariables from "@babel/helper-hoist-variables";
let hoistVariables = require("@babel/helper-hoist-variables").default;

// Push let-variable declarations to top of scope.
module.exports = function({types: t}) {
    return {
        visitor: {
            BlockStatement(path) {
              const declarations = []
              hoistVariables(
                path,
                id => {
                  declarations.push(id)
                },
                "let"
              )
              function hoister(id) {
                const declarator = t.variableDeclarator(id)
                const declaration = t.variableDeclaration("let", [declarator])
                path.unshiftContainer('body', declaration)
              }
              declarations.map(hoister)
            }
        }
    }
}