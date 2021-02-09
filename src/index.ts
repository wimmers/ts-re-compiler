import { filter } from './filterAst'
import { block } from './tsast/Ast_t.gen';
import { pprintBlock } from "./tsast/OCamlModules.gen"
import * as OCamlModules from "./tsast/OCamlModules.gen"
import * as fs from "fs";
import * as ts from "typescript";

const serializeBlock: ((arg: block) => object) =
  OCamlModules.serializeBlock as unknown as ((arg: block) => object)
// const Ast_bs = require("./Ast_bs.bs.js")
// const serializeBlock = Ast_bs.write_block

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
    fs.readFileSync(fileName).toString(),
    ts.ScriptTarget.ES2015,
    /*setParentNodes */ true
  );

  const result = filter(sourceFile)
  const printedBlock = pprintBlock(result)
  console.log("Printed", printedBlock)
  const serializedBlock = JSON.stringify(serializeBlock(result), undefined, 2)
  const outFileName = fileName + ".json"
  console.log("Dumping JSON to", outFileName)
  fs.writeFileSync(outFileName, serializedBlock)
});