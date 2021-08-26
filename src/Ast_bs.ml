(* Auto-generated from "Ast.atd" *)
              [@@@ocaml.warning "-27-32-35-39"]

type binop = Ast_t.binop

type block = Ast_t.block

and expr = Ast_t.expr

and parameter = Ast_t.parameter

and stmt = Ast_t.stmt

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
  Atdgen_codec_runtime.Encode.make (fun (x : _) -> match x with
    | `Eq ->
    Atdgen_codec_runtime.Encode.constr0 "Eq"
    | `Eq2 ->
    Atdgen_codec_runtime.Encode.constr0 "Eq2"
    | `Eq3 ->
    Atdgen_codec_runtime.Encode.constr0 "Eq3"
    | `Neq2 ->
    Atdgen_codec_runtime.Encode.constr0 "Neq2"
    | `Neq3 ->
    Atdgen_codec_runtime.Encode.constr0 "Neq3"
    | `Times ->
    Atdgen_codec_runtime.Encode.constr0 "Times"
    | `Plus ->
    Atdgen_codec_runtime.Encode.constr0 "Plus"
    | `Minus ->
    Atdgen_codec_runtime.Encode.constr0 "Minus"
    | `Div ->
    Atdgen_codec_runtime.Encode.constr0 "Div"
    | `Less ->
    Atdgen_codec_runtime.Encode.constr0 "Less"
    | `Greater ->
    Atdgen_codec_runtime.Encode.constr0 "Greater"
    | `And ->
    Atdgen_codec_runtime.Encode.constr0 "And"
    | `Or ->
    Atdgen_codec_runtime.Encode.constr0 "Or"
  )
)
let read_binop = (
  Atdgen_codec_runtime.Decode.enum
  [
      (
      "Eq"
      ,
        `Single (`Eq)
      )
    ;
      (
      "Eq2"
      ,
        `Single (`Eq2)
      )
    ;
      (
      "Eq3"
      ,
        `Single (`Eq3)
      )
    ;
      (
      "Neq2"
      ,
        `Single (`Neq2)
      )
    ;
      (
      "Neq3"
      ,
        `Single (`Neq3)
      )
    ;
      (
      "Times"
      ,
        `Single (`Times)
      )
    ;
      (
      "Plus"
      ,
        `Single (`Plus)
      )
    ;
      (
      "Minus"
      ,
        `Single (`Minus)
      )
    ;
      (
      "Div"
      ,
        `Single (`Div)
      )
    ;
      (
      "Less"
      ,
        `Single (`Less)
      )
    ;
      (
      "Greater"
      ,
        `Single (`Greater)
      )
    ;
      (
      "And"
      ,
        `Single (`And)
      )
    ;
      (
      "Or"
      ,
        `Single (`Or)
      )
  ]
)
let rec write__1 js = (
  Atdgen_codec_runtime.Encode.list (
    write_parameter
  )
) js
and write__2 js = (
  Atdgen_codec_runtime.Encode.option_as_constr (
    write_expr
  )
) js
and write__3 js = (
  Atdgen_codec_runtime.Encode.option_as_constr (
    write_block
  )
) js
and write__5 js = (
  Atdgen_codec_runtime.Encode.list (
    write_expr
  )
) js
and write__6 js = (
  Atdgen_codec_runtime.Encode.list (
    write_stmt
  )
) js
and write_block js = (
  Atdgen_codec_runtime.Encode.make (fun (x : _) -> match x with
    | `Block x ->
    Atdgen_codec_runtime.Encode.constr1 "Block" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          write__6
        )
    ) x
  )
) js
and write_expr js = (
  Atdgen_codec_runtime.Encode.make (fun (x : _) -> match x with
    | `Var x ->
    Atdgen_codec_runtime.Encode.constr1 "Var" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          Atdgen_codec_runtime.Encode.string
        )
    ) x
    | `App x ->
    Atdgen_codec_runtime.Encode.constr1 "App" (
      Atdgen_codec_runtime.Encode.tuple2
        (
          write_expr
        )
        (
          write__5
        )
    ) x
    | `PropertyAccess x ->
    Atdgen_codec_runtime.Encode.constr1 "PropertyAccess" (
      Atdgen_codec_runtime.Encode.tuple2
        (
          write_expr
        )
        (
          Atdgen_codec_runtime.Encode.string
        )
    ) x
    | `ElementAccess x ->
    Atdgen_codec_runtime.Encode.constr1 "ElementAccess" (
      Atdgen_codec_runtime.Encode.tuple2
        (
          write_expr
        )
        (
          write_expr
        )
    ) x
    | `Number x ->
    Atdgen_codec_runtime.Encode.constr1 "Number" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          Atdgen_codec_runtime.Encode.float
        )
    ) x
    | `String x ->
    Atdgen_codec_runtime.Encode.constr1 "String" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          Atdgen_codec_runtime.Encode.string
        )
    ) x
    | `Null ->
    Atdgen_codec_runtime.Encode.constr0 "Null"
    | `Undefined ->
    Atdgen_codec_runtime.Encode.constr0 "Undefined"
    | `ObjLit x ->
    Atdgen_codec_runtime.Encode.constr1 "ObjLit" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          write__1
        )
    ) x
    | `ArrayLit x ->
    Atdgen_codec_runtime.Encode.constr1 "ArrayLit" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          write__5
        )
    ) x
    | `Spread x ->
    Atdgen_codec_runtime.Encode.constr1 "Spread" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          write_expr
        )
    ) x
    | `Conditional x ->
    Atdgen_codec_runtime.Encode.constr1 "Conditional" (
      Atdgen_codec_runtime.Encode.tuple3
        (
          write_expr
        )
        (
          write_expr
        )
        (
          write_expr
        )
    ) x
    | `Binop x ->
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
    | `Arrow x ->
    Atdgen_codec_runtime.Encode.constr1 "Arrow" (
      Atdgen_codec_runtime.Encode.tuple2
        (
          write__1
        )
        (
          write_block
        )
    ) x
    | `Protected x ->
    Atdgen_codec_runtime.Encode.constr1 "Protected" (
      write_expr
    ) x
  )
) js
and write_parameter js = (
  Atdgen_codec_runtime.Encode.make (fun (x : _) -> match x with
    | `Parameter x ->
    Atdgen_codec_runtime.Encode.constr1 "Parameter" (
      Atdgen_codec_runtime.Encode.tuple3
        (
          Atdgen_codec_runtime.Encode.string
        )
        (
          Atdgen_codec_runtime.Encode.bool
        )
        (
          write__2
        )
    ) x
  )
) js
and write_stmt js = (
  Atdgen_codec_runtime.Encode.make (fun (x : _) -> match x with
    | `Expression x ->
    Atdgen_codec_runtime.Encode.constr1 "Expression" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          write_expr
        )
    ) x
    | `VarDecl x ->
    Atdgen_codec_runtime.Encode.constr1 "VarDecl" (
      Atdgen_codec_runtime.Encode.tuple2
        (
          Atdgen_codec_runtime.Encode.string
        )
        (
          write_expr
        )
    ) x
    | `FunctionDecl x ->
    Atdgen_codec_runtime.Encode.constr1 "FunctionDecl" (
      Atdgen_codec_runtime.Encode.tuple3
        (
          Atdgen_codec_runtime.Encode.string
        )
        (
          write__1
        )
        (
          write_block
        )
    ) x
    | `Return x ->
    Atdgen_codec_runtime.Encode.constr1 "Return" (
      Atdgen_codec_runtime.Encode.tuple1
        (
          write__2
        )
    ) x
    | `If x ->
    Atdgen_codec_runtime.Encode.constr1 "If" (
      Atdgen_codec_runtime.Encode.tuple3
        (
          write_expr
        )
        (
          write_block
        )
        (
          write__3
        )
    ) x
    | `While x ->
    Atdgen_codec_runtime.Encode.constr1 "While" (
      Atdgen_codec_runtime.Encode.tuple2
        (
          write_expr
        )
        (
          write_block
        )
    ) x
    | `VarObjectPatternDecl x ->
    Atdgen_codec_runtime.Encode.constr1 "VarObjectPatternDecl" (
      Atdgen_codec_runtime.Encode.tuple2
        (
          write__4
        )
        (
          write_expr
        )
    ) x
    | `VarArrayPatternDecl x ->
    Atdgen_codec_runtime.Encode.constr1 "VarArrayPatternDecl" (
      Atdgen_codec_runtime.Encode.tuple2
        (
          write__4
        )
        (
          write_expr
        )
    ) x
    | `NoOp ->
    Atdgen_codec_runtime.Encode.constr0 "NoOp"
  )
) js
let rec read__1 js = (
  Atdgen_codec_runtime.Decode.list (
    read_parameter
  )
) js
and read__2 js = (
  Atdgen_codec_runtime.Decode.option_as_constr (
    read_expr
  )
) js
and read__3 js = (
  Atdgen_codec_runtime.Decode.option_as_constr (
    read_block
  )
) js
and read__5 js = (
  Atdgen_codec_runtime.Decode.list (
    read_expr
  )
) js
and read__6 js = (
  Atdgen_codec_runtime.Decode.list (
    read_stmt
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
            read__6
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`Block x) : _))
        )
      )
  ]
) js
and read_expr js = (
  Atdgen_codec_runtime.Decode.enum
  [
      (
      "Var"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple1
          (
            Atdgen_codec_runtime.Decode.string
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`Var x) : _))
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
            read__5
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`App x) : _))
        )
      )
    ;
      (
      "PropertyAccess"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple2
          (
            read_expr
          )
          (
            Atdgen_codec_runtime.Decode.string
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`PropertyAccess x) : _))
        )
      )
    ;
      (
      "ElementAccess"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple2
          (
            read_expr
          )
          (
            read_expr
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`ElementAccess x) : _))
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
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`Number x) : _))
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
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`String x) : _))
        )
      )
    ;
      (
      "Null"
      ,
        `Single (`Null)
      )
    ;
      (
      "Undefined"
      ,
        `Single (`Undefined)
      )
    ;
      (
      "ObjLit"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple1
          (
            read__1
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`ObjLit x) : _))
        )
      )
    ;
      (
      "ArrayLit"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple1
          (
            read__5
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`ArrayLit x) : _))
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
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`Spread x) : _))
        )
      )
    ;
      (
      "Conditional"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple3
          (
            read_expr
          )
          (
            read_expr
          )
          (
            read_expr
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`Conditional x) : _))
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
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`Binop x) : _))
        )
      )
    ;
      (
      "Arrow"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple2
          (
            read__1
          )
          (
            read_block
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`Arrow x) : _))
        )
      )
    ;
      (
      "Protected"
      ,
        `Decode (
        read_expr
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`Protected x) : _))
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
            read__2
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`Parameter x) : _))
        )
      )
  ]
) js
and read_stmt js = (
  Atdgen_codec_runtime.Decode.enum
  [
      (
      "Expression"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple1
          (
            read_expr
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`Expression x) : _))
        )
      )
    ;
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
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`VarDecl x) : _))
        )
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
            read__1
          )
          (
            read_block
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`FunctionDecl x) : _))
        )
      )
    ;
      (
      "Return"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple1
          (
            read__2
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`Return x) : _))
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
            read__3
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`If x) : _))
        )
      )
    ;
      (
      "While"
      ,
        `Decode (
        Atdgen_codec_runtime.Decode.tuple2
          (
            read_expr
          )
          (
            read_block
          )
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`While x) : _))
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
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`VarObjectPatternDecl x) : _))
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
        |> Atdgen_codec_runtime.Decode.map (fun x -> ((`VarArrayPatternDecl x) : _))
        )
      )
    ;
      (
      "NoOp"
      ,
        `Single (`NoOp)
      )
  ]
) js
