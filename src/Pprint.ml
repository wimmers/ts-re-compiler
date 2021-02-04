open Ast;;
open Format;;

let ident = pp_print_string
let kwd = pp_print_string
let print_space = pp_print_space
let pp_sep sep ppf = pp_print_string ppf sep; pp_print_space ppf

let pprint_binop (ppf: formatter) (op) =
let binop op =
    pp_print_space ppf ();
    pp_print_string ppf op;
    pp_print_space ppf ()
in binop (match op with
| Eq2 -> "=="
| Eq3 -> "==="
| _ -> "<...>")

let rec pprint_expr (ppf: formatter) =
let kwd = kwd ppf
and ident = ident ppf
and print_space = print_space ppf
and open_hovbox = pp_open_hovbox ppf
and close_box = pp_close_box ppf
in
function
| Var(x) -> Js.log(x); ident x
| VarDecl(name, expr) ->
    open_hovbox 2;
        kwd "const";
        print_space ();
        ident name;
        print_space ();
        kwd "=";
        print_space ();
        pprint_expr ppf expr;
        kwd ";";
    close_box ()
| FunctionDecl(name, params, body) ->
    open_hovbox 2;
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
        kwd ";";
    close_box ()
| Arrow(params, body) ->
    open_hovbox 2;
        kwd "(";
        open_hovbox 1;
            pp_print_list ~pp_sep:(pp_sep ",") pprint_parameter ppf params;
        close_box ();
        kwd ")";
        print_space ();
        kwd "=>";
        print_space ();
        pprint_block ppf body;
    close_box ()
| String(string) -> kwd "\""; ident string; kwd "\""
| App(e, args) ->
    pprint_expr ppf e;
    kwd "(";
    open_hovbox 1;
        pp_print_list ~pp_sep:(pp_sep ",") pprint_expr ppf args;
    close_box ();
    kwd ")"
| Binop(op, e1, e2) ->
    pprint_expr ppf e1;
    (* pprint_binop ppf op; *)
    pprint_expr ppf e2
| Null -> kwd "null"
| Undefined -> kwd "undefined"
| Number(n) -> kwd (Belt.Float.toString n)
| _ -> kwd "<>"
and pprint_block ppf = function
| Block(exprs) ->
    kwd ppf "{";
    pp_open_vbox ppf 2;
        List.map (fun x -> pprint_expr ppf x) exprs |> fun _ -> ();
    pp_close_box ppf ();
    kwd ppf "}"
and pprint_parameter ppf = function
| Parameter(name, is_opt, init_opt) ->
    ident ppf name;
    if is_opt then kwd ppf "?" else ();
    match init_opt with
    | None -> ()
    | Some(init) ->
        pp_print_space ppf ();
        kwd ppf "=";
        pp_print_space ppf ();
        pprint_expr ppf init

let print_expr e =
    pp_set_margin str_formatter 81;
    pp_set_max_indent str_formatter 11;
    pprint_expr str_formatter e;
    flush_str_formatter