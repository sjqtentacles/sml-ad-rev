structure AdRev :> ADREV =
struct
  type t = { scalar : real, deriv : int -> real }

  fun var (x : real) (id : int) : t = { scalar = x, deriv = fn j => if j = id then 1.0 else 0.0 }
  fun const (c : real) : t = { scalar = c, deriv = fn _ => 0.0 }
  fun value (t : t) : real = #scalar t
  fun grad (t : t) (id : int) : real = (#deriv t) id
  fun gradAll (t : t) (ids : int list) : real list = List.map (#deriv t) ids

  fun add (tA : t) (tB : t) : t =
    let val {scalar=sa, deriv=da} = tA val {scalar=sb, deriv=db} = tB
    in { scalar = sa + sb, deriv = fn i => da i + db i } end

  fun sub (tA : t) (tB : t) : t =
    let val {scalar=sa, deriv=da} = tA val {scalar=sb, deriv=db} = tB
    in { scalar = sa - sb, deriv = fn i => da i - db i } end

  fun mul (tA : t) (tB : t) : t =
    let val {scalar=sa, deriv=da} = tA val {scalar=sb, deriv=db} = tB
    in { scalar = sa * sb, deriv = fn i => sb * (da i) + sa * (db i) } end

  fun neg (tA : t) : t =
    let val {scalar=sa, deriv=da} = tA
    in { scalar = ~sa, deriv = fn i => ~ (da i) } end

  (* d/dx (a / b) = (a' b - a b') / b^2 *)
  fun divide (tA : t) (tB : t) : t =
    let val {scalar=sa, deriv=da} = tA val {scalar=sb, deriv=db} = tB
    in { scalar = sa / sb,
         deriv = fn i => (da i * sb - sa * db i) / (sb * sb) } end

  (* d/dx (1 / a) = -a' / a^2 *)
  fun recip (tA : t) : t =
    let val {scalar=sa, deriv=da} = tA
    in { scalar = 1.0 / sa, deriv = fn i => ~ (da i) / (sa * sa) } end

  fun scale (c : real) (tA : t) : t =
    let val {scalar=sa, deriv=da} = tA
    in { scalar = c * sa, deriv = fn i => c * (da i) } end

  fun addConst (c : real) (tA : t) : t =
    let val {scalar=sa, deriv=da} = tA
    in { scalar = c + sa, deriv = da } end

  (* For a unary g with value v = g(x) and local derivative g'(x), the chain
     rule gives (g . f)'(i) = g'(x) * f'(i). *)
  fun chain (v : real) (gprime : real) (tA : t) : t =
    let val {scalar=_, deriv=da} = tA
    in { scalar = v, deriv = fn i => gprime * (da i) } end

  fun exp (tA : t) : t =
    let val sa = #scalar tA val e = Math.exp sa
    in chain e e tA end

  fun log (tA : t) : t =
    let val sa = #scalar tA
    in chain (Math.ln sa) (1.0 / sa) tA end

  fun sin (tA : t) : t =
    let val sa = #scalar tA
    in chain (Math.sin sa) (Math.cos sa) tA end

  fun cos (tA : t) : t =
    let val sa = #scalar tA
    in chain (Math.cos sa) (~ (Math.sin sa)) tA end

  fun tanh (tA : t) : t =
    let val sa = #scalar tA val th = Math.tanh sa
    in chain th (1.0 - th * th) tA end

  fun sqrt (tA : t) : t =
    let val sa = #scalar tA val r = Math.sqrt sa
    in chain r (0.5 / r) tA end

  (* d/dx (a^p) = p * a^(p-1) * a' *)
  fun pow (tA : t) (p : real) : t =
    let val sa = #scalar tA
    in chain (Math.pow (sa, p)) (p * Math.pow (sa, p - 1.0)) tA end
end
