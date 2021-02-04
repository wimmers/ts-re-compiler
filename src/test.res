let rec fib = n => {
  switch n {
  | 0 | 1 => 1
  | n => fib(n - 1) + fib(n - 2)
  }
}

export doIt = n => {
  Js.log("Hey, here is a number!")
  Js.log(fib(n))
}

export pprintExpr = Pprint.print_expr
