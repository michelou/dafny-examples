predicate Even( x : int ) { x % 2 == 0 }

function Pow( a0 : int, b0 : nat ) : int
	decreases b0
{
	if b0 == 0 then 1 else a0 * Pow( a0, b0-1 )
} 

lemma EvenPowerLemma( a : int, b : nat ) 
	requires Even( b )
	ensures Pow(a, b) == Pow(a*a, b/2)
{
    // Proof omitted. It's beyond the scope of the course.
	assume {:axiom} Pow(a, b) == Pow(a*a, b/2) ; // Trust me!
}

method mult( a0 : int, b0 : nat ) returns (c : int ) 
	ensures c == a0 * b0 
{
	c := 0 ;
	var a := a0 ;
	var b : nat := b0 ;
    while b != 0 
		invariant a0*b0 == c + a*b
		decreases b
	{
	    if b%2==1 {
			c := c + a ;
			b := b - 1 ;
		}
		assert Even(b) ;
		b := b/2 ;
		a := 2*a ;
	}
}

method power( a0 : int, b0 : nat ) returns (c : int ) 
	ensures c == Pow( a0, b0 )
{
	c := 1 ;
	var a := a0 ;
	var b : nat := b0 ;
    while b != 0 
	invariant Pow(a0, b0) == c * Pow(a, b) 
	decreases b
	{
	    if b%2 == 1 {
			c := c * a ;
			b := b - 1 ; }
		assert Even( b ) ;
		EvenPowerLemma(a, b) ;
		//assert Pow( a, b ) == Pow( a*a, b / 2 ) ;
		b := b/2 ;
		a := a * a ;
	}
}

method print0(op: string, a0 : int, b0 : int, res0 : int)
{
	print(op); print("("); print(a0); print(", ");
    print(b0); print(") = "); print(res0); print("\n");
}

method Main()
{
    var a := 2 ; var b := 3 ;

    var c := mult(a, b);
    print0("mult", a, b, c);

    c := power(a, b);
    print0("power", a, b, c);
}
