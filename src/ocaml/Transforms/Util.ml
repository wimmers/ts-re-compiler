let pp_comma_list: 'a. (Format.formatter -> 'a -> unit) -> Format.formatter -> 'a list -> unit =
fun pp_val -> fun xs ->
  Format.pp_print_list
    ~pp_sep:(fun ppf () -> Format.pp_print_text ppf ", ") pp_val xs

let pp_list (pp_val: (Format.formatter -> 'a -> unit)) (ppf: Format.formatter) (xs: 'a list) =
  let ppl = pp_comma_list pp_val
  in Format.fprintf ppf "@[[%a]@]" ppl xs

let pp_string_list = pp_list Format.pp_print_text

let string_of_string_list = Format.asprintf "%a\n" pp_string_list

let print_string_list s = print_endline (string_of_string_list s)

open Base

let invent_name bounds s =
  let rec loop n =
    let name = s ^ "$" ^ Int.to_string n in
    if List.mem ~equal:(String.equal) bounds name then loop (n + 1) else name
  in if List.mem ~equal:(String.equal) bounds s then Some (loop 0) else None

let invent_name1 bounds s = match invent_name bounds s with
| None -> s
| Some(s1) -> s1