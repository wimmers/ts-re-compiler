import * as ts from "typescript";
import { stmt, expr, parameter, block, binop } from './tsast/Ast_t.gen';
import {
    mkApp, mkNull, mkNumber, mkString, mkUndefined, mkVar, mkVarDecl, mkVarAssignment,
    mkParameter1, mkParameter2,
    mkFunctionDecl, mkBlock,
    mkReturn1, mkReturn2, mkObjLit, mkArrayLit, mkSpread, mkIf1, mkIf2, mkWhile, mkBinop, mkArrow,
    mkObjectBindingPattern, mkArrayBindingPattern, mkNoOp, mkExpression, mkConditional, mkElementAccess, mkPropertyAccess
} from './tsast/Ast.gen';

const babelFills = [
    "_toConsumableArray",
    "_nonIterableSpread",
    "_nonIterableSpread",
    "_unsupportedIterableToArray",
    "_iterableToArray",
    "_arrayWithoutHoles",
    "_arrayLikeToArray",
]

export function filter(sourceFile: ts.SourceFile): block {

    function filterParameter(node: ts.Node): parameter {
        if (node.kind !== ts.SyntaxKind.Parameter && node.kind !== ts.SyntaxKind.PropertyAssignment) {
            throw `Not a parameter: ${node}`
        }
        const param = (node as (ts.ParameterDeclaration | ts.PropertyAssignment))
        const isOpt = param.questionToken !== undefined
        const init = param.initializer
        const name = (param.name as ts.Identifier).escapedText as string
            || (param.name as ts.StringLiteral).text as string
        if (init !== undefined) {
            return mkParameter2(name, isOpt, filterExpr(init))
        } else {
            return mkParameter1(name, isOpt)
        }
    }

    function filterBlock(node: ts.Node): block {
        if (node.kind !== ts.SyntaxKind.Block && node.kind !== ts.SyntaxKind.SourceFile) {
            throw `Not a block: ${node}`
        }
        const block = (node as ts.BlockLike)
        const stmts = block.statements.map(filterStmt)
        return mkBlock(stmts)
    }

    function filterBlockOrExprOrStatement(node: ts.Node): block {
        if (ts.isBlock(node)) {
            return filterBlock(node)
        } else if (ts.isExpressionStatement(node)) {
            return mkBlock([mkExpression(filterExpr(node))])
        }
        else {
            return mkBlock([filterStmt(node)])
        }
    }

    function filterStmt(node: ts.Node): stmt {
        switch (node.kind) {
            case ts.SyntaxKind.VariableStatement:
                return filterVariableStatement(node as ts.VariableStatement)

            case ts.SyntaxKind.FunctionDeclaration:
                return filterFunctionDeclaration(node as ts.FunctionDeclaration)

            case ts.SyntaxKind.ReturnStatement:
                return filterReturnStatement(node as ts.ReturnStatement)

            case ts.SyntaxKind.IfStatement:
                return filterIfStatement(node as ts.IfStatement)
            
            case ts.SyntaxKind.WhileStatement:
                return filterWhileStatement(node as ts.WhileStatement)

            case ts.SyntaxKind.ExpressionStatement:
                return filterExpressionStatement(node as ts.ExpressionStatement)
        }

        return mkExpression(mkUndefined)
    }

    function filterExpr(node: ts.Node): expr {
        switch (node.kind) {

            case ts.SyntaxKind.CallExpression:
                return filterCallExpression(node as ts.CallExpression)

            case ts.SyntaxKind.NullKeyword:
                return mkNull

            case ts.SyntaxKind.Identifier:
                return filterIdentifier(node as ts.Identifier)

            case ts.SyntaxKind.NumericLiteral:
                return filterNumericLiteral(node as ts.NumericLiteral)
            
            case ts.SyntaxKind.PrefixUnaryExpression:
                return filterNumericLiteral(node as ts.PrefixUnaryExpression)

            case ts.SyntaxKind.StringLiteral:
                return filterStringLiteral(node as ts.StringLiteral)

            case ts.SyntaxKind.ObjectLiteralExpression:
                return filterObjectLiteralExpression(node as ts.ObjectLiteralExpression)

            case ts.SyntaxKind.ArrayLiteralExpression:
                return filterArrayLiteralExpression(node as ts.ArrayLiteralExpression)

            case ts.SyntaxKind.SpreadElement:
                return filterSpreadElement(node as ts.SpreadElement)

            case ts.SyntaxKind.BinaryExpression:
                return filterBinaryExpression(node as ts.BinaryExpression)

            case ts.SyntaxKind.FunctionExpression:
            case ts.SyntaxKind.ArrowFunction:
                return filterArrowFunction(node as ts.ArrowFunction)

            case ts.SyntaxKind.ConditionalExpression:
                return filterConditionalExpression(node as ts.ConditionalExpression)

            case ts.SyntaxKind.PropertyAccessExpression:
                return filterPropertyAccessExpression(node as ts.PropertyAccessExpression)

            case ts.SyntaxKind.ElementAccessExpression:
                return filterElementAccessExpression(node as ts.ElementAccessExpression)

        }

        return mkUndefined
    }

    function filterIdentifier(node: ts.Identifier): expr {
        const name: string = (node.escapedText as string)
        return mkVar(name)
    }

    function filterNumericLiteral(node: ts.NumericLiteral | ts.PrefixUnaryExpression): expr {
        const num = parseFloat(node.getText())
        return mkNumber(num)
    }

    function filterStringLiteral(node: ts.StringLiteral): expr {
        return mkString(node.text)
    }

    function filterElementAccessExpression(node: ts.ElementAccessExpression): expr {
        const e1 = filterExpr(node.expression)
        const e2 = filterExpr(node.argumentExpression)
        return mkElementAccess(e1, e2)
    }

    function filterPropertyAccessExpression(node: ts.PropertyAccessExpression): expr {
        const e = filterExpr(node.expression)
        const identifier = (node.name as ts.Identifier)
        const name: string = (identifier.escapedText as string)
        return mkPropertyAccess(e, name)
    }

    function filterBinaryExpression(node: ts.BinaryExpression): expr {
        const left = filterExpr(node.left)
        const right = filterExpr(node.right)
        let binop: binop
        switch (node.operatorToken.kind) {
            case ts.SyntaxKind.EqualsToken:
                binop = "Eq"
                break;
            case ts.SyntaxKind.EqualsEqualsToken:
                binop = "Eq2"
                break;
            case ts.SyntaxKind.EqualsEqualsEqualsToken:
                binop = "Eq3"
                break;
            case ts.SyntaxKind.ExclamationEqualsToken:
                binop = "Neq2"
                break;
            case ts.SyntaxKind.ExclamationEqualsEqualsToken:
                binop = "Neq3"
                break;
            case ts.SyntaxKind.PlusToken:
                binop = "Plus"
                break;
            case ts.SyntaxKind.MinusToken:
                binop = "Minus"
                break;
            case ts.SyntaxKind.SlashToken:
                binop = "Div"
                break;
            case ts.SyntaxKind.AsteriskToken:
                binop = "Times"
                break;
            case ts.SyntaxKind.LessThanToken:
                binop = "Less"
                break;
            case ts.SyntaxKind.LessThanEqualsToken:
                binop = "LessEq"
                break;
            case ts.SyntaxKind.GreaterThanEqualsToken:
                binop = "GreaterEq"
                break;
            case ts.SyntaxKind.GreaterThanToken:
                binop = "Greater"
                break;
            case ts.SyntaxKind.AmpersandAmpersandToken:
                binop = "And"
                break;
            case ts.SyntaxKind.BarBarToken:
                binop = "Or"
                break;
            default:
                throw `Unknown binary operator ${node.operatorToken}`;
        }
        return mkBinop(binop, left, right)
    }

    function filterConditionalExpression(node: ts.ConditionalExpression): expr {
        const condition = filterExpr(node.condition)
        const e1 = filterExpr(node.whenTrue)
        const e2 = filterExpr(node.whenFalse)
        return mkConditional(condition, e1, e2)
    }

    function filterIfStatement(node: ts.IfStatement): stmt {
        const b = filterExpr(node.expression)
        const e1 = filterBlockOrExprOrStatement(node.thenStatement)
        if (node.elseStatement) {
            const e2 = filterBlockOrExprOrStatement(node.elseStatement)
            return mkIf2(b, e1, e2)
        } else {
            return mkIf1(b, e1)
        }
    }

    function filterWhileStatement(node: ts.WhileStatement): stmt {
        const b = filterExpr(node.expression)
        const e = filterBlockOrExprOrStatement(node.statement)
        return mkWhile(b, e)
    }

    function filterSpreadElement(node: ts.SpreadElement): expr {
        const e = filterExpr(node.expression)
        return mkSpread(e)
    }

    function filterArrayLiteralExpression(node: ts.ArrayLiteralExpression): expr {
        const elements = node.elements.map(filterExpr)
        return mkArrayLit(elements)
    }

    function filterObjectLiteralExpression(node: ts.ObjectLiteralExpression): expr {
        const props = node.properties.map(filterParameter)
        return mkObjLit(props)
    }

    function filterReturnStatement(node: ts.ReturnStatement): stmt {
        const expression = node.expression
        if (expression) {
            return mkReturn2(filterExpr(expression))
        }
        else {
            return mkReturn1
        }
    }

    function filterExpressionStatement(node: ts.ExpressionStatement): stmt {
        const expression = node.expression
        if (expression.kind === ts.SyntaxKind.BinaryExpression
            && (expression as ts.BinaryExpression).operatorToken.kind === ts.SyntaxKind.EqualsToken) {
            return filterAssignmentExpressionStatement(node)
        }
        return mkExpression(filterExpr(expression))
    }

    function filterAssignmentExpressionStatement(node: ts.ExpressionStatement): stmt {
        let expression = node.expression as ts.BinaryExpression
        let left = expression.left
        let name = left.getText()
        let right = expression.right
        return mkVarAssignment(name, filterExpr(right))
    }

    function filterFunctionDeclaration(node: ts.FunctionDeclaration): stmt {
        const parameters = node.parameters.map(filterParameter)
        const identifier = (node.name as ts.Identifier)
        const name: string = (identifier.escapedText as string)
        if (babelFills.includes(name)) {
            return mkNoOp
        }
        let body
        if (node.body) {
            body = filterBlock(node.body)
        }
        else {
            throw `Body of function needs to be present: ${node}`
        }
        return mkFunctionDecl(name, parameters, body)
    }

    function filterArrowFunction(node: ts.FunctionLikeDeclaration): expr {
        const parameters = node.parameters.map(filterParameter)
        let body: block
        if (node.body) {
            if (node.body.kind !== ts.SyntaxKind.Block) {
                const innerBody = filterExpr(node.body)
                body = mkBlock([mkReturn2(innerBody)])
            } else {
                body = filterBlock(node.body)
            }
        }
        else {
            throw `Body of function needs to be present: ${node}`
        }
        return mkArrow(parameters, body)
    }

    function getPatternBinders(binders: ts.NodeArray<ts.Node>): string[] {
        return binders.map((node) => {
            if (node.kind !== ts.SyntaxKind.BindingElement) {
                throw `Unknown binder: ${node.getText()}`
            }
            const binder = node as ts.BindingElement
            return (binder.name as ts.Identifier).escapedText as string
        }
        )
    }

    function filterVariableStatement(node: ts.VariableStatement): stmt {
        const varStatement: ts.VariableStatement = (node as ts.VariableStatement)
        const declarationList = varStatement.declarationList
        const declarations = declarationList.declarations
        if (declarations.length !== 1) {
            console.error("Multi-declarations are not supported")
        }
        // if (declarationList.flags & (ts.NodeFlags.Const | ts.NodeFlags.Let)) {
        // }
        // else {
        //     console.error("Unsupported variable declaration keyword!", node.getText(sourceFile))
        // }
        const declaration = declarations[0]
        const identifier = declaration.name
        const initializer = declaration.initializer
        if (initializer === undefined) {
            console.error("Variable Declaration needs assignment!")
            return mkExpression(mkUndefined)
        }
        const initializerResult = filterExpr(initializer)
        switch (identifier.kind) {
            case ts.SyntaxKind.Identifier:
                const name: string = ((identifier as ts.Identifier).escapedText as string)
                return mkVarAssignment(name, initializerResult)
            case ts.SyntaxKind.ObjectBindingPattern:
                const objPattern = identifier as ts.ObjectBindingPattern
                const objBinders = getPatternBinders(objPattern.elements)
                return mkObjectBindingPattern(objBinders, initializerResult)
            case ts.SyntaxKind.ArrayBindingPattern:
                const arrPattern = identifier as ts.ArrayBindingPattern
                const arrBinders = getPatternBinders(arrPattern.elements)
                return mkArrayBindingPattern(arrBinders, initializerResult)
            default:
                throw `Pattern assignment not supported: ${node.getText()}`
        }
    }

    function filterCallExpression(node: ts.CallExpression): expr {
        const expression = node.expression
        const args = node.arguments
        const expressionResult = filterExpr(expression)
        const argsResults = args.map(filterExpr)
        return mkApp(expressionResult, argsResults)
    }

    return filterBlock(sourceFile)
}