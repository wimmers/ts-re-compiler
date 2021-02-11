let pp_string_list ppf =
  let 
    ppl =
      Format.pp_print_list
        ~pp_sep:(fun ppf () -> Format.pp_print_text ppf "; ")
        Format.pp_print_text
  in Format.fprintf ppf "[%a]" ppl

let string_of_string_list = Format.asprintf "%a\n" pp_string_list

let print_string_list s = print_endline (string_of_string_list s)