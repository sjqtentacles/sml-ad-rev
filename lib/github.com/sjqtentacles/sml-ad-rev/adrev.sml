structure AdRev :> ADREV =
struct
  type t = { scalar : real, deriv : int -> real }
  fun var (x : real) (id : int) : t = { scalar = x, deriv = fn j => if j = id then 1.0 else 0.0 }
  fun value (t : t) : real = #scalar t
  fun grad (t : t) (id : int) : real = (#deriv t) id
  fun add (tA : t) (tB : t) : t =
    let val {scalar=sa, deriv=da} = tA val {scalar=sb, deriv=db} = tB
    in { scalar = sa + sb, deriv = fn i => da i + db i } end
  fun mul (tA : t) (tB : t) : t =
    let val {scalar=sa, deriv=da} = tA val {scalar=sb, deriv=db} = tB
    in { scalar = sa * sb, deriv = fn i => sb * (da i) + sa * (db i) } end
end
