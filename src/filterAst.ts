import * as ts from "typescript";
import { expr, parameter, block, binop } from './tsast/Ast_t.gen';
import {
    mkApp, mkNull, mkNumber, mkUndefined, mkVar, mkVarDecl, mkParameter1, mkParameter2,
    mkFunctionDecl, mkBlock,
    mkReturn1, mkReturn2, mkObjLit, mkArrayLit, mkSpread, mkIf1, mkIf2, mkBinop, mkArrow,
    mkObjectBindingPattern, mkArrayBindingPattern
} from './tsast/Ast.gen';

export function filter(sourceFile: ts.SourceFile): block {

    function filterParameter(node: ts.Node): parameter {
        if (node.kind !== ts.SyntaxKind.Parameter && node.kind !== ts.SyntaxKind.PropertyAssignment) {
            throw `Not a parameter: ${node}`
        }
        const param = (node as (ts.ParameterDeclaration | ts.PropertyAssignment))
        const isOpt = param.questionToken !== undefined
        const init = param.initializer
        const name = ((param.name as ts.Identifier).escapedText as string)
        if (init !== undefined) {
            return mkParameter2(name, isOpt, filterAst(init))
        } else {
            return mkParameter1(name, isOpt)
        }
    }

    function filterBlock(node: ts.Node): block {
        if (node.kind !== ts.SyntaxKind.Block && node.kind !== ts.SyntaxKind.SourceFile) {
            throw `Not a block: ${node}`
        }
        const block = (node as ts.BlockLike)
        const exprs = block.statements.map(filterAst)
        return mkBlock(exprs)
    }

    function filterBlockOrExpr(node: ts.Node): block {
        if (ts.isBlock(node)) {
            return filterBlock(node)
        }
        else {
            return mkBlock([filterAst(node)])
        }
    }

    function filterAst(node: ts.Node): expr {
        switch (node.kind) {
            case ts.SyntaxKind.VariableStatement:
                return filterVariableStatement(node as ts.VariableStatement)

            case ts.SyntaxKind.CallExpression:
                return filterCallExpression(node as ts.CallExpression)

            case ts.SyntaxKind.NullKeyword:
                return mkNull

            case ts.SyntaxKind.Identifier:
                return filterIdentifier(node as ts.Identifier)

            case ts.SyntaxKind.NumericLiteral:
                return filterNumericLiteral(node as ts.NumericLiteral)

            case ts.SyntaxKind.FunctionDeclaration:
                return filterFunctionDeclaration(node as ts.FunctionDeclaration)

            case ts.SyntaxKind.ReturnStatement:
                return filterReturnStatement(node as ts.ReturnStatement)

            case ts.SyntaxKind.ObjectLiteralExpression:
                return filterObjectLiteralExpression(node as ts.ObjectLiteralExpression)

            case ts.SyntaxKind.ArrayLiteralExpression:
                return filterArrayLiteralExpression(node as ts.ArrayLiteralExpression)

            case ts.SyntaxKind.SpreadElement:
                return filterSpreadElement(node as ts.SpreadElement)

            case ts.SyntaxKind.IfStatement:
                return filterIfStatement(node as ts.IfStatement)

            case ts.SyntaxKind.BinaryExpression:
                return filterBinaryExpression(node as ts.BinaryExpression)

            case ts.SyntaxKind.ArrowFunction:
                return filterArrowFunction(node as ts.ArrowFunction)

        }

        return mkUndefined
    }

    function filterIdentifier(node: ts.Identifier): expr {
        const name: string = (node.escapedText as string)
        return mkVar(name)
    }

    function filterNumericLiteral(node: ts.NumericLiteral): expr {
        const num = parseFloat(node.getText())
        return mkNumber(num)
    }

    function filterBinaryExpression(node: ts.BinaryExpression): expr {
        const left = filterAst(node.left)
        const right = filterAst(node.right)
        let binop: binop
        switch (node.operatorToken.kind) {
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
            default:
                throw `Unknown binary operator ${node.operatorToken}`;
        }
        return mkBinop(binop, left, right)
    }

    function filterIfStatement(node: ts.IfStatement): expr {
        const b = filterAst(node.expression)
        const e1 = filterBlockOrExpr(node.thenStatement)
        if (node.elseStatement) {
            const e2 = filterBlockOrExpr(node.elseStatement)
            return mkIf2(b, e1, e2)
        } else {
            return mkIf1(b, e1)
        }
    }

    function filterSpreadElement(node: ts.SpreadElement): expr {
        const e = filterAst(node.expression)
        return mkSpread(e)
    }

    function filterArrayLiteralExpression(node: ts.ArrayLiteralExpression): expr {
        const elements = node.elements.map(filterAst)
        return mkArrayLit(elements)
    }

    function filterObjectLiteralExpression(node: ts.ObjectLiteralExpression): expr {
        const props = node.properties.map(filterParameter)
        return mkObjLit(props)
    }

    function filterReturnStatement(node: ts.ReturnStatement): expr {
        const expression = node.expression
        if (expression) {
            return mkReturn2(filterAst(expression))
        }
        else {
            return mkReturn1
        }
    }

    function filterFunctionDeclaration(node: ts.FunctionDeclaration): expr {
        const parameters = node.parameters.map(filterParameter)
        const identifier = (node.name as ts.Identifier)
        const name: string = (identifier.escapedText as string)
        let body
        if (node.body) {
            body = filterBlock(node.body)
        }
        else {
            throw `Body of function needs to be present: ${node}`
        }
        return mkFunctionDecl(name, parameters, body)
    }

    function filterArrowFunction(node: ts.ArrowFunction): expr {
        const parameters = node.parameters.map(filterParameter)
        let body: block
        if (node.body) {
            body = filterBlock(node.body)
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

    function filterVariableStatement(node: ts.VariableStatement): expr {
        const varStatement: ts.VariableStatement = (node as ts.VariableStatement)
        const declarationList = varStatement.declarationList
        const declarations = declarationList.declarations
        if (declarations.length !== 1) {
            console.error("Multi-declarations are not supported")
        }
        if (declarationList.flags & ts.NodeFlags.Const) {
        }
        else {
            console.error("Unsupported variable declaration keyword!", node.getText(sourceFile))
        }
        const declaration = declarations[0]
        const identifier = declaration.name
        const initializer = declaration.initializer
        if (initializer === undefined) {
            console.error("Variable Declaration needs assignment!")
            return mkUndefined
        }
        const initializerResult = filterAst(initializer)
        switch (identifier.kind) {
            case ts.SyntaxKind.Identifier:
                const name: string = ((identifier as ts.Identifier).escapedText as string)
                return mkVarDecl(name, initializerResult)
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
        const expressionResult = filterAst(expression)
        const argsResults = args.map(filterAst)
        return mkApp(expressionResult, argsResults)
    }

    return filterBlock(sourceFile)
}