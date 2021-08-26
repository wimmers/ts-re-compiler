module.exports = function ({ types: t }) {
    return {
        visitor: {
            ForStatement(path) {
                const node = path.node
                const initializer = node.init
                const condition = node.test
                const incrementor = node.update
                let body = node.body
                if (incrementor) {
                    const incrementorStatement = t.expressionStatement(incrementor)
                    if (t.isBlockStatement(node.body)) {
                        path.get('body').pushContainer('body', incrementorStatement);
                    } else if (t.isStatement(node.body)) {
                        body = t.blockStatement([node.body, incrementorStatement])
                    } else { // XXX Is this branch reachable?
                        throw "Unexpected body type in for-loop. Should be statement or block."
                    }
                }
                let trueCondition = t.booleanLiteral(true)
                let newLoop = t.WhileStatement(condition || trueCondition, body)
                let stmts = []
                if (initializer) stmts.push(initializer)
                stmts.push(newLoop)
                path.replaceWithMultiple(stmts)
            }
        }
    };
}