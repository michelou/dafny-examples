function Fib(n: nat): nat {
  if n <= 1 then n else Fib(n - 1) + Fib(n - 2)
}

method ComputeFib(n: nat) returns (b: nat)
  ensures b == Fib(n)
{
  var c := 1;
  b := 0;
  for i := 0 to n
    invariant b == Fib(i) && c == Fib(i + 1)
  {
    b, c := c, b + c;
  }
}

method {:main} Main() {
  var n := 10;
  print "fib(", n, ")=", Fib(n), "\n";
}