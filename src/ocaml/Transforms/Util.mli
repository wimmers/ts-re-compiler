val pp_comma_list :
  (Format.formatter -> 'a -> unit) ->
  Format.formatter -> 'a list -> unit
val pp_list :
  (Format.formatter -> 'a -> unit) ->
  Format.formatter -> 'a list -> unit
val pp_string_list : Format.formatter -> string list -> unit
val string_of_string_list : string list -> string
val print_string_list : string list -> unit
val invent_name: string list -> string -> string option
val invent_name1: string list -> string -> string