(* Auto-generated from "Ast.atd" *)
              [@@@ocaml.warning "-27-32-35-39"]

type binop = Ast_t.binop = 
    Eq2 | Eq3 | Neq2 | Neq3 | Times | Plus | Minus | Div


type block = Ast_t.block =  Block of (expr list) 

and expr = Ast_t.expr = 
    VarDecl of (string * expr)
  | Var of (string)
  | App of (expr * expr list)
  | Number of (float)
  | String of (string)
  | Undefined
  | Null
  | FunctionDecl of (string * parameter list * block)
  | Return of (expr option)
  | ObjLit of (parameter list)
  | ArrayLit of (expr list)
  | VarObjectPatternDecl of (string list * expr)
  | VarArrayPatternDecl of (string list * expr)
  | Spread of (expr)
  | If of (expr * block * block option)
  | Binop of (binop * expr * expr)
  | Arrow of (parameter list * block)


and parameter = Ast_t.parameter = 
  Parameter of (string * bool * expr option)


let write__4 = (
  Atdgen_codec_runtime.Encode.list (
    Atdgen_codec_runtime.Encode.string
  )
)
let read__4 = (
  Atdgen_codec_runtime.Decode.list (
    Atdgen_codec_runtime.Decode.string
  )
)
let write_binop = (
  Atdgen_codec_runtime.Encode.make (fun (x : binop) -> match x with
    | Eq2 ->
    Atdgen_codec_runtime.Encode.constr0 "Eq2"
    | Eq3 ->
    Atdgen_codec_runtime.Encode.constr0 "Eq3"
    | Neq2 ->
    Atdgen_codec_runtime.Encode.constr0 "Neq2"
    | Neq3 ->
    Atdgen_codec_runtime.Encode.constr0 "Neq3"
    | Times ->
    Atdgen_codec_runtime.Encode.constr0 "Times"
    | Plus ->
    Atdgen_codec_runtime.Encode.constr0 "Plus"
    | Minus ->
    Atdgen_codec_runtime.Encode.constr0 "Minus"
    | Div ->
    Atdgen_codec_runtime.Encode.constr0 "Div"
  )
)
let read_binop = (
  Atdgen_codec_runtime.Decode.enum
  [
      (
      "Eq2"
      ,
        `Single (Eq2)
      )
    ;
      (
      "Eq3"
      ,
        `Single (Eq3)
      )
    ;
      (
      "Neq2"
      ,
        `Single (Neq2)
      )
    ;
      (
      "Neq3"
      ,
        `Single (Neq3)
      )
    ;
      (
      "Times"
      ,
        `Single (Times)
      )
    ;
      (
      "Plus"
      ,
        `Single (Plus)
      )
    ;
      (
      "Minus"
      ,
        `Single (Minus)
      )
    ;
      (
      "Div"
      ,
        `Single (Div)
      )
  ]
)
let rec write__1 js = (
  Atdgen_codec_runtime.Encode.list (
    write_expr
  )
) js
and write__2 js = (
  Atdgen_codec_runtime.Encode.list (
    write_parameter
  )
) js
and write__3 js = (
  Atdgen_codec_runtime.Encode.option_as_constr (
    write_expr
  )
) js
and write__5 js = (
  Atdgen_codec_runtime.Encode.option_as_constr (
    write_block
  )
) js
and write_block js = (
  Atdgen_codec_runtime.Encode.make (fun (x : block) -> match x with
    | Block x ->
    Atdgen_codec_runtime.Encode.constr1 "Block" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          write__1
        )
    ) x
  )
) js
and write_expr js = (
  Atdgen_codec_runtime.Encode.make (fun (x : expr) -> match x with
    | VarDecl x ->
    Atdgen_codec_runtime.Encode.constr1 "VarDecl" (
      Atdgen_codec_runtime.Encode.tuple2
        (
          Atdgen_codec_runtime.Encode.string
        )
        (
          write_expr
        )
    ) x
    | Var x ->
    Atdgen_codec_runtime.Encode.constr1 "Var" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          Atdgen_codec_runtime.Encode.string
        )
    ) x
    | App x ->
    Atdgen_codec_runtime.Encode.constr1 "App" (
      Atdgen_codec_runtime.Encode.tuple2
        (
          write_expr
        )
        (
          write__1
        )
    ) x
    | Number x ->
    Atdgen_codec_runtime.Encode.constr1 "Number" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          Atdgen_codec_runtime.Encode.float
        )
    ) x
    | String x ->
    Atdgen_codec_runtime.Encode.constr1 "String" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          Atdgen_codec_runtime.Encode.string
        )
    ) x
    | Undefined ->
    Atdgen_codec_runtime.Encode.constr0 "Undefined"
    | Null ->
    Atdgen_codec_runtime.Encode.constr0 "Null"
    | FunctionDecl x ->
    Atdgen_codec_runtime.Encode.constr1 "FunctionDecl" (
      Atdgen_codec_runtime.Encode.tuple3
        (
          Atdgen_codec_runtime.Encode.string
        )
        (
          write__2
        )
        (
          write_block
        )
    ) x
    | Return x ->
    Atdgen_codec_runtime.Encode.constr1 "Return" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          write__3
        )
    ) x
    | ObjLit x ->
    Atdgen_codec_runtime.Encode.constr1 "ObjLit" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          write__2
        )
    ) x
    | ArrayLit x ->
    Atdgen_codec_runtime.Encode.constr1 "ArrayLit" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          write__1
        )
    ) x
    | VarObjectPatternDecl x ->
    Atdgen_codec_runtime.Encode.constr1 "VarObjectPatternDecl" (
      Atdgen_codec_runtime.Encode.tuple2
        (
          write__4
        )
        (
          write_expr
        )
    ) x
    | VarArrayPatternDecl x ->
    Atdgen_codec_runtime.Encode.constr1 "VarArrayPatternDecl" (
      Atdgen_codec_runtime.Encode.tuple2
        (
          write__4
        )
        (
          write_expr
        )
    ) x
    | Spread x ->
    Atdgen_codec_runtime.Encode.constr1 "Spread" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          write_expr
        )
    ) x
    | If x ->
    Atdgen_codec_runtime.Encode.constr1 "If" (
      Atdgen_codec_runtime.Encode.tuple3
        (
          write_expr
        )
        (
          write_block
        )
        (
          write__5
        )
    ) x
    | Binop x ->
    Atdgen_codec_runtime.Encode.constr1 "Binop" (
      Atdgen_codec_runtime.Encode.tuple3
        (
          write_binop
        )
        (
          write_expr
        )
        (
          write_expr
        )
    ) x
    | Arrow x ->
    Atdgen_codec_runtime.Encode.constr1 "Arrow" (
      Atdgen_codec_runtime.Encode.tuple2
        (
          write__2
        )
        (
          write_block
        )
    ) x
  )
) js
and write_parameter js = (
  Atdgen_codec_runtime.Encode.make (fun (x : parameter) -> match x with
    | Parameter x ->
    Atdgen_codec_runtime.Encode.constr1 "Parameter" (
      Atdgen_codec_runtime.Encode.tuple3
        (
          Atdgen_codec_runtime.Encode.string
        )
        (
          Atdgen_codec_runtime.Encode.bool
        )
        (
          write__3
        )
    ) x
  )
) js
let rec read__1 js = (
  Atdgen_codec_runtime.Decode.list (
    read_expr
  )
) js
and read__2 js = (
  Atdgen_codec_runtime.Decode.list (
    read_parameter
  )
) js
and read__3 js = (
  Atdgen_codec_runtime.Decode.option_as_constr (
    read_expr
  )
) js
and read__5 js = (
  Atdgen_codec_runtime.Decode.option_as_constr (
    read_block
  )
) js
and read_block js = (
  Atdgen_codec_runtime.Decode.enum
  [
      (
      "Block"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple1
          (
            read__1
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((Block x) : block))
        )
      )
  ]
) js
and read_expr js = (
  Atdgen_codec_runtime.Decode.enum
  [
      (
      "VarDecl"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple2
          (
            Atdgen_codec_runtime.Decode.string
          )
          (
            read_expr
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((VarDecl x) : expr))
        )
      )
    ;
      (
      "Var"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple1
          (
            Atdgen_codec_runtime.Decode.string
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((Var x) : expr))
        )
      )
    ;
      (
      "App"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple2
          (
            read_expr
          )
          (
            read__1
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((App x) : expr))
        )
      )
    ;
      (
      "Number"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple1
          (
            Atdgen_codec_runtime.Decode.float
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((Number x) : expr))
        )
      )
    ;
      (
      "String"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple1
          (
            Atdgen_codec_runtime.Decode.string
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((String x) : expr))
        )
      )
    ;
      (
      "Undefined"
      ,
        `Single (Undefined)
      )
    ;
      (
      "Null"
      ,
        `Single (Null)
      )
    ;
      (
      "FunctionDecl"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple3
          (
            Atdgen_codec_runtime.Decode.string
          )
          (
            read__2
          )
          (
            read_block
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((FunctionDecl x) : expr))
        )
      )
    ;
      (
      "Return"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple1
          (
            read__3
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((Return x) : expr))
        )
      )
    ;
      (
      "ObjLit"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple1
          (
            read__2
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((ObjLit x) : expr))
        )
      )
    ;
      (
      "ArrayLit"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple1
          (
            read__1
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((ArrayLit x) : expr))
        )
      )
    ;
      (
      "VarObjectPatternDecl"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple2
          (
            read__4
          )
          (
            read_expr
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((VarObjectPatternDecl x) : expr))
        )
      )
    ;
      (
      "VarArrayPatternDecl"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple2
          (
            read__4
          )
          (
            read_expr
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((VarArrayPatternDecl x) : expr))
        )
      )
    ;
      (
      "Spread"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple1
          (
            read_expr
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((Spread x) : expr))
        )
      )
    ;
      (
      "If"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple3
          (
            read_expr
          )
          (
            read_block
          )
          (
            read__5
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((If x) : expr))
        )
      )
    ;
      (
      "Binop"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple3
          (
            read_binop
          )
          (
            read_expr
          )
          (
            read_expr
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((Binop x) : expr))
        )
      )
    ;
      (
      "Arrow"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple2
          (
            read__2
          )
          (
            read_block
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((Arrow x) : expr))
        )
      )
  ]
) js
and read_parameter js = (
  Atdgen_codec_runtime.Decode.enum
  [
      (
      "Parameter"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple3
          (
            Atdgen_codec_runtime.Decode.string
          )
          (
            Atdgen_codec_runtime.Decode.bool
          )
          (
            read__3
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((Parameter x) : parameter))
        )
      )
  ]
) js
