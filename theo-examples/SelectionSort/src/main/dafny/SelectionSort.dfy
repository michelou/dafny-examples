predicate Sorted( s : seq<int>)
{
    forall i,j : int :: 0 <= i <= j < |s| ==> s[i] <= s[j]
}

predicate PermutationOf( s : seq<int>, t : seq<int> )
{
    multiset(s) == multiset(t) 
}

predicate Partitioned( s : seq<int>, p : int )
{
    (forall i,j : int :: 0 <= i < p <= j < |s| ==> s[i] <= s[j] ) 
}

method selectionSort( a : array<int> ) 
    modifies a 
    ensures Sorted( a[..] ) 
    ensures PermutationOf( a[..], old( a[..] ) )
{
    var p := 0 ;
	while ( p != a.Length )
		invariant 0 <= p <= a.Length 
		invariant Sorted( a[0..p] ) 
		invariant Partitioned( a[..], p ) 
		invariant PermutationOf( a[..], old( a[..] ) )
		decreases a.Length - p
	{
		// Let q be an index in a of the minimal value in a[p..]
		var q := select(a, p) ;
		assert forall i :: p <= i < a.Length ==> a[q] <= a[i] ;
		a[p], a[q] := a[q], a[p] ; // Note that p==q ==> a[q] == a[p]
		p := p+1 ;
	}
} 

predicate Least( s : seq<int>, x : int ) 
{
	forall i :: 0 <= i < |s| ==>  x <= s[i]
}

method select( a : array<int>, p : int ) returns ( q : int)	
    requires 0 <= p < a.Length 
    ensures p <= q < a.Length
    ensures Least( a[p..], a[q] ) 
{
    q := p ;
    var k := p + 1 ;
    while ( k < a.Length ) 
        invariant p <= q < k <= a.Length 
        invariant Least( a[p..k], a[q] )
		decreases a.Length - k
    {
        if ( a[k] < a[q] ) { q := k ; }
        k := k + 1 ;
    }
}

method compareAndSwap( a : array<int>, p : int, q : int ) 
requires 0 <= p <= q < a.Length 
modifies a
ensures a[p] <= a[q] 
//ensures (a[p] == old(a[p]) && a[q] == old(a[q]))
//     || (a[p] == old(a[q]) && a[q] == old(a[p]))
// ensures multiset{a[p],a[q]} == old(multiset{a[p],a[q]})
ensures (a[p],a[q])==old((a[p],a[q])) || (a[p],a[q])==old((a[q],a[p])) 
ensures forall i :: 0 <= i < a.Length && i != p && i != q ==> a[i] == old(a[i])
ensures PermutationOf( a[..], old(a[..]) )
{
	if ( a[p] > a[q] ) { a[p], a[q] := a[q], a[p] ; }
}

method printArray(a: array<int>)
{
	var i := 0;
	print "[";
    while (i < a.Length) { print (if i > 0 then ", " else ""), a[i]; i := i+1; }
    print "]\n";
}

method Main()
{
	var a := new int[5];
	a[0], a[1], a[2], a[3], a[4] := 9, 4, 6, 3, 8;
	var p, q := 2, 3;
	compareAndSwap( a, p, q );
	assert a[p] <= a[q];
	assert a[0] == 9;
	assert a[p] == 3 && a[q] == 6;
    print("Before: "); printArray(a);
	selectionSort(a);
    print("After : "); printArray(a);
}
