method between( p :  int, r : int ) returns (q : int ) 
    requires r-p > 1
	ensures p < q < r
{
   q := (p+r) / 2 ;
}

method divideByBinarySearch(x : int, y : int) returns ( p : int ) 
	requires y > 0 
	requires x >= 0
	ensures  p*y <= x < (p+1)*y 
{
	p := 0 ;
    var r := x + 1 ;
	while ( p + 1 != r )
	    invariant 0 <= p < r && p*y <= x < r*y 
	{
	    var q := between(p, r) ;
		if ( x < q*y ) { r := q ; } else { p := q ; }
	}
}

method root( x : int ) returns ( p : int )
    requires x >= 0
	ensures p*p <= x < (p+1)*(p+1)
{
    p := 0 ;
	var r := x + 1 ;
	while p + 1 != r
	    invariant p*p <= x < r*r 
		//invariant p+1 <= r
		//decreases r-p 
	{
		var q := between(p, r) ;
		if q*q <= x {
			p := q ; }
		else {
			r := q ; }
	}
}

method main() 
{
    var a := 1 ; var b := 1 ;
	b:=a+b ;
	assert b % 2 == 0 ;
	a:=a+b ;
	assert a == 3 ;
}
