# TypeScript Compiler & ReasonScript Interop

This project tries to setup interaction between the TypeScript and the Reason compiler.
We use `genType` to generate TS type declarations from ReScript.

## Getting Started

### Installation

```sh
npm install
```

Native:
```
opam switch create 4.11.1
opam install base stdio dune ocaml-lsp-server atdgen
```

### Building

```sh
npm run re:build && npm run build
```

Native build:

```sh
dune build src/ocaml/read_ast.exe
```

### Continuous Build

```sh
npm run re:watch
```

In another:

```sh
npm run watch
```

### Running

```sh
npm run run src/examples/tree.ts
```

Run native:

```sh
_build/default/src/ocaml/read_ast.exe src/examples/tree.ts.json
```

## Implementation Notes

### atd

The data types and JSON (de-)serializers for asts are generated by [atdgen](https://atd.readthedocs.io/en/latest/atdgen.html).
To re-generate, run:

```sh
npm run atd
```

## Usage Notes

I have not yet figured how to let this multi-project setup play nicely with Merlin.
If one deletes the `.merlin` file at the root, then it works nicely for all the OCaml files.
Otherwise, it will not find the local libraries.
However, the `.merlin` file is probably needed to get all features for ReScript files.

## Setup Notes

- `genType` only generates `.tsx` files ([issue](https://github.com/reason-association/genType/issues/453)).
  We work around this by setting `"jsx": "react"` in `tsconfig.json`.
- `genType` uses `require` ([issue](https://github.com/reason-association/genType/issues/465)).
  This is annoying because it means we cannot use Node's ES6 module mode.
  Workaround: use the `esm` package.
- In Node's ES6 mode, file paths need to carry explicit file type suffixes. TS refuses to generate them.
  One way to fix it is to use `.js` imports in the *original TS file* (like [so](https://github.com/microsoft/TypeScript/issues/41887)).
  The other is to update `tsconfig` like [so](https://github.com/Microsoft/TypeScript/issues/27481#issuecomment-449673378).
  This problem vanishes as soon as we use `esm`.
- The paths to the Babel plugins in `src` are set as absolute paths in `babel.config.json`, and need to be adopted to your machine. They should go after all official Babel plugins, in the following order:
  - `mybabel`
  - `babel-for-to-while`
  - `babel-transform-update-expression`
  - `babel-transform-object-spread`
  - `babel-transform-unary-expression`
  - `babel-transform-array-push`
  - `babel-transform-property-assignment`
  - `babel-rename`
  - `babel-hoist-declarations`
  - `babel-transform-internals`
- The module `simple_fun` needs to be installed locally via opam.
