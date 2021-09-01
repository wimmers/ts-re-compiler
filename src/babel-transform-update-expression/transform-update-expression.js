// Replace `x++` and `x--` by `x = x + 1` and `x = x - 1`, respectively.
module.exports = function({types: t}) {
    return {
        visitor: {
            UpdateExpression(path){
              let node = path.node;
              let left = node.argument;
              let operator;
              switch (node.operator) {
                case "++":
                  operator = "+"; break;
                case "--":
                  operator = "-"; break;
                default:
                  return;
              }
              const literal = t.numericLiteral(1)
              const right = t.binaryExpression(operator, left, literal)
              const assignment = t.assignmentExpression("=", left, right)
              path.replaceWith(assignment)
            }
        }
    }
}