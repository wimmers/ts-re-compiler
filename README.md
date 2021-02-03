# TypeScript Compiler & ReasonScript Interop

This project tries to setup interaction between the TypeScript and the Reason compiler.
We use `genType` to generate TS type declarations from ReScript.

## Getting Started

### Installation

```sh
npm install
```

### Building

```sh
npm run re:build && npm run build
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

```
npm run run src/examples/tree.ts
```

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