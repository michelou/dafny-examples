// Source: https://dafny.org/latest/OnlineTutorial/guide

//////////////////////////////////////////////////////////////////////////////
// Methods

function Abs(x: int): int {
  if x < 0 then -x else x
}

method MultipleReturns(x: int, y: int) returns (more: int, less: int)
{
  more := x + y;
  less := x - y;
  // comments: are not strictly necessary.
}

//////////////////////////////////////////////////////////////////////////////
// Pre- and Postconditions

method ComputeAbs(x: int) returns (y: int)
  ensures 0 <= y
{
  if x < 0 {
    return -x;
  } else {
    return x;
  }
}


method {:main} Main() {
  print "GettingStarted: Abs(-3)=", Abs(-3), "\n";
}