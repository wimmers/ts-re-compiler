(** Fundamental constants that are used among various translation phases. *)

(** Builtins that are only added during the final translation phase. *)
let array_cons = "array_cons"
let array_append = "array_append"
let str_concat_name = "_str_conc"

let internals = [array_cons; array_append; str_concat_name]

(* Builtins that are erased during translation. *)
let assert_name = "_assert"

let hypotheticals = [assert_name]

(* Builtins that are preserved (and sometimes inserted) during translation. *)
let updS_name = "_updS"
let upd_name = "_upd"
let typeof_name = "_typeof"
let neg_name = "_neg"
let const2_1_name = "_const2_1"
let const2_2_name = "_const2_2"
let undefined0_name = "_undefined0"
let undefined1_name = "_undefined1"
let id_name = "_id"
let slice_name = "_slice"
let map_name = "_map"
let choose_name = "_choose"
let undefined_name = "undefined"

let builtins = [
  assert_name;
  upd_name;
  updS_name;
  typeof_name;
  neg_name;
  const2_1_name;
  const2_2_name;
  undefined0_name;
  undefined1_name;
  id_name;
  slice_name;
  map_name;
  choose_name;
  undefined_name; (* XXX Hack: why is `Undefined identified as a variable? *)
]

(* Builtins that can show up in the final product. *)
let all_internals = internals @ builtins

(** Property names that play a special internal role. *)

(** Closures consist of a function name and an array of arguments. *)
let closure_fun_name = "fun"
let closure_args_name = "args"