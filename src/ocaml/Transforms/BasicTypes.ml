open Tsast.Ast_t

type fun_decl = string * parameter list * block
type program = fun_decl list * block

type 'a string_tab = (string, 'a, Base.String.comparator_witness) Base.Map.t