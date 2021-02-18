open Ast_t;;
open Format;;

let ident = pp_print_string
let kwd = pp_print_string
let print_space = pp_print_space
let pp_sep sep ppf = pp_print_string ppf sep; pp_print_space ppf
let hovbox pp ppf arg =
    pp_open_hovbox ppf 0;
    pp ppf arg;
    pp_close_box ppf ()

let pprint_binop (ppf: formatter) (op) =
let binop op =
    pp_print_space ppf ();
    pp_print_string ppf op;
    pp_print_space ppf ()
in binop (match op with
| `Eq -> "="
| `Eq2 -> "=="
| `Eq3 -> "==="
| `Neq2 -> "!="
| `Neq3 -> "!=="
| `Plus -> "+"
| `Minus -> "-"
| `Div -> "/"
| `Times -> "*"
(* | _ -> "<...>" *)
)

let rec (pprint_stmt: formatter -> stmt -> unit) = fun ppf ->
let kwd = kwd ppf
and ident = ident ppf
and print_space = print_space ppf
and open_hovbox = pp_open_hovbox ppf
and close_box = pp_close_box ppf
and print_break = pp_print_break ppf
in
function
| `VarDecl(name, expr) ->
    kwd "const";
    print_space ();
    ident name;
    print_space ();
    kwd "=";
    print_space ();
    pprint_expr ppf expr;
    kwd ";"
| `VarObjectPatternDecl(names, expr) ->
    kwd "const";
    print_space ();
    kwd "{";
        pp_print_list ~pp_sep:(pp_sep ",") pp_print_string ppf names;
    kwd "}";
    print_space ();
    kwd "=";
    print_space ();
    pprint_expr ppf expr;
    kwd ";"
| `VarArrayPatternDecl(names, expr) ->
    kwd "const";
    print_space ();
    kwd "[";
        pp_print_list ~pp_sep:(pp_sep ",") pp_print_string ppf names;
    kwd "]";
    print_space ();
    kwd "=";
    print_space ();
    pprint_expr ppf expr;
    kwd ";"
| `FunctionDecl(name, params, body) ->
    kwd "function";
    print_space ();
    ident name;
    kwd "(";
    open_hovbox 1;
        pp_print_list ~pp_sep:(pp_sep ",") pprint_parameter ppf params;
    close_box ();
    kwd ")";
    print_space ();
    kwd "=";
    print_space ();
    pprint_block ppf body;
    kwd ";"
| `Return(e_opt) ->
    kwd "return";
    (
        match e_opt with
        | Some e ->
            print_break 1 2;
            pprint_expr ppf e
        | None -> ()
    );
    kwd ";"
| `If(b, e1, opt_e2) ->
    kwd "if";
    print_space ();
    kwd "(";
        open_hovbox 2;
        pprint_expr ppf b;
        close_box ();
    kwd ")";
    print_space ();
    pprint_block ppf e1;
    (match opt_e2 with
    | Some e2 ->
        print_space ();
        kwd "else";
        print_space ();
        pprint_block ppf e2
    | None -> ())
| `NoOp -> kwd "‹nop›"
| `Expression(e) -> pprint_expr ppf e

and (pprint_expr: formatter -> expr -> unit) = fun ppf ->
let kwd = kwd ppf
and ident = ident ppf
and print_space = print_space ppf
and open_hovbox = pp_open_hovbox ppf
and close_box = pp_close_box ppf
and print_bspace = pp_print_break ppf 1
and open_hvbox = pp_open_hvbox ppf
in
function
| `Var(x) -> ident x
| `Arrow(params, body) ->
    kwd "(";
    open_hovbox 1;
        pp_print_list ~pp_sep:(pp_sep ",") pprint_parameter ppf params;
    close_box ();
    kwd ")";
    print_space ();
    kwd "=>";
    print_space ();
    pprint_block ppf body
| `String(string) -> kwd "\""; ident string; kwd "\""
| `App(e, args) ->
    pprint_expr ppf e;
    kwd "(";
    open_hovbox 1;
        pp_print_list ~pp_sep:(pp_sep ",") pprint_expr ppf args;
    close_box ();
    kwd ")"
| `ObjLit(params) ->
    open_hvbox 2;
    kwd "{";
    (
        if params == [] then () else (
        print_space ();
        pp_print_list ~pp_sep:(pp_sep ",") (hovbox pprint_parameter) ppf params;
        print_bspace (-2)
        )
    );
    kwd "}";
    pp_close_box ppf ()
| `ArrayLit(eles) ->
    open_hvbox 2;
    kwd "[";
    (
        if eles == [] then () else (
        print_space ();
        pp_print_list ~pp_sep:(pp_sep ",") (hovbox pprint_expr) ppf eles;
        print_bspace (-2)
        )
    );
    kwd "]";
    pp_close_box ppf ()
| `Spread(e) ->
    kwd "...";
    pprint_expr ppf e
| `Binop(op, e1, e2) ->
    pprint_expr ppf e1;
    pprint_binop ppf op;
    pprint_expr ppf e2
| `Null -> kwd "null"
| `Undefined -> kwd "undefined"
| `Number(n) -> kwd (string_of_float n)
| `Protected(e) ->
    fprintf ppf "@[«%a»@]" pprint_expr e
| `PropertyAccess(e, s) ->
    fprintf ppf "%a.%a" pprint_expr e pp_print_string s
| `ElementAccess(e1, e2) ->
    fprintf ppf "%a[%a]" pprint_expr e1 pprint_expr e2
| `Conditional(be, e1, e2) ->
    fprintf ppf "@[%a@] ?@ @[%a@] :@ @[%a@]"
        pprint_expr be pprint_expr e1 pprint_expr e2
(* | _ -> kwd "<>" *)
and pprint_block ppf = function
| `Block(stmts) ->
    pp_open_hvbox ppf 2;
    kwd ppf "{";
    print_space ppf ();
        pp_print_list ~pp_sep:(print_space) (hovbox pprint_stmt) ppf stmts;
    pp_print_break ppf 1 (-2);
    kwd ppf "}";
    pp_close_box ppf ();
and pprint_parameter ppf = function
| `Parameter(name, is_opt, init_opt) ->
    ident ppf name;
    if is_opt then kwd ppf "?" else ();
    match init_opt with
    | None -> ()
    | Some(init) ->
        pp_print_space ppf ();
        kwd ppf "=";
        pp_print_space ppf ();
        pprint_expr ppf init

let print_it ppf x =
    pp_set_margin str_formatter 81;
    (hovbox ppf) str_formatter x;
    pp_print_newline str_formatter ();
    flush_str_formatter

let print_stmt = print_it pprint_stmt

let print_expr = print_it pprint_expr

let print_block = print_it pprint_block