import * as ts from "typescript";
import { expr, mkApp, mkNull, mkNumber, mkUndefined, mkVar, mkVarDecl } from './Ast.gen'

export function filter(sourceFile: ts.SourceFile): expr[] {
    // console.log(sourceFile)
    // filterAst(sourceFile);

    function filterAst(node: ts.Node): expr {
        switch (node.kind) {
            case ts.SyntaxKind.ForStatement:
            case ts.SyntaxKind.ForInStatement:
            case ts.SyntaxKind.WhileStatement:
            case ts.SyntaxKind.DoStatement:
                if ((node as ts.IterationStatement).statement.kind !== ts.SyntaxKind.Block) {
                    report(
                        node,
                        'A looping statement\'s contents should be wrapped in a block body.'
                    );
                }
                break;

            case ts.SyntaxKind.IfStatement:
                const ifStatement = node as ts.IfStatement;
                if (ifStatement.thenStatement.kind !== ts.SyntaxKind.Block) {
                    report(ifStatement.thenStatement,
                        'An if statement\'s contents should be wrapped in a block body.');
                }
                if (
                    ifStatement.elseStatement &&
                    ifStatement.elseStatement.kind !== ts.SyntaxKind.Block &&
                    ifStatement.elseStatement.kind !== ts.SyntaxKind.IfStatement
                ) {
                    report(
                        ifStatement.elseStatement,
                        'An else statement\'s contents should be wrapped in a block body.'
                    );
                }
                break;

            // case ts.SyntaxKind.BinaryExpression:
            //     const op = (node as ts.BinaryExpression).operatorToken.kind;
            //     if (op === ts.SyntaxKind.EqualsEqualsToken
            //         || op === ts.SyntaxKind.ExclamationEqualsToken) {
            //         report(node, 'Use \'===\' and \'!==\'.');
            //     }
            //     break;


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

            // default:
            //     console.log("Unsupported AST element!", node)
        }

        return mkUndefined

        // const results = <(object | undefined)[]>[]
        // ts.forEachChild(node, filterAndCollect(results))
        // ts.forEachChild(node, filterAst);
    }

    function filterIdentifier(node: ts.Identifier): expr {
        const name: string = (node.escapedText as string)
        return mkVar(name)
    }

    function filterNumericLiteral(node: ts.NumericLiteral): expr {
        const num = parseFloat(node.getText())
        return mkNumber(num)
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
        if (identifier.kind !== ts.SyntaxKind.Identifier) {
            console.error("Pattern assignment not supported!")
        }
        const name: string = ((identifier as ts.Identifier).escapedText as string)
        if (name === undefined) {
            console.log("Warning: undefined")
        }
        const initializerResult = filterAst(initializer)
        return mkVarDecl(name, initializerResult)
    }

    function filterCallExpression(node: ts.CallExpression): expr {
        const expression = node.expression
        const args = node.arguments
        const expressionResult = filterAst(expression)
        const argsResults = args.map(filterAst)
        return mkApp(expressionResult, argsResults)
    }

    function report(node: ts.Node, message: string) {
        const { line, character } = sourceFile.getLineAndCharacterOfPosition(node.getStart());
        console.log(`${sourceFile.fileName} (${line + 1},${character + 1}): ${message}`);
    }

    function filterAndCollect(arr: (expr)[]) {
        function doIt(node: ts.Node): void {
            arr.push(filterAst(node))
        }
        return doIt
    }

    const results = <expr[]>[]

    ts.forEachChild(sourceFile, filterAndCollect(results))

    return results
}