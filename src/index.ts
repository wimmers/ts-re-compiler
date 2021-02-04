import { filter } from './filterAst'
import { pprintExpr } from "./OCamlModules.gen"
import { readFileSync } from "fs";
import * as ts from "typescript";

export const sum = (a: number, b: number) => {
  if ('development' === process.env.NODE_ENV) {
    console.log('boop');
  }
  return a + b;
};

const fileNames = process.argv.slice(2);
fileNames.forEach(fileName => {
  // Parse a file
  const sourceFile = ts.createSourceFile(
    fileName,
    readFileSync(fileName).toString(),
    ts.ScriptTarget.ES2015,
    /*setParentNodes */ true
  );

  // delint it
  // delint(sourceFile);

  const results = filter(sourceFile)
  for (const result of results) {
    const printedExpr = pprintExpr(result)
    console.log(printedExpr)
  }
});