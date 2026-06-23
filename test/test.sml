structure Tests = struct open Harness structure A = AdRev
fun run () = let
  val () = section "product rule (two vars)"
  val x = A.var 2.0 0
  val y = A.var 3.0 1
  val f = A.mul x y
  val () = checkRealTol 1E~9 "value xy = 6" (6.0, A.value f)
  val () = checkRealTol 1E~9 "df/dx = y" (3.0, A.grad f 0)
  val () = checkRealTol 1E~9 "df/dy = x" (2.0, A.grad f 1)

  val () = section "sum rule and unrelated variable"
  val g = A.add x y                 (* x + y *)
  val () = checkRealTol 1E~9 "value x+y = 5" (5.0, A.value g)
  val () = checkRealTol 1E~9 "d(x+y)/dx = 1" (1.0, A.grad g 0)
  val () = checkRealTol 1E~9 "grad wrt unused id = 0" (0.0, A.grad g 7)

  val () = section "chained expression  h = x*y + x"
  val h = A.add (A.mul x y) x
  val () = checkRealTol 1E~9 "value = 8" (8.0, A.value h)
  val () = checkRealTol 1E~9 "dh/dx = y + 1 = 4" (4.0, A.grad h 0)
  val () = checkRealTol 1E~9 "dh/dy = x = 2" (2.0, A.grad h 1)

  val () = section "three variables  p = x*y*z"
  val z = A.var 5.0 2
  val p = A.mul (A.mul x y) z
  val () = checkRealTol 1E~9 "value = 30" (30.0, A.value p)
  val () = checkRealTol 1E~9 "dp/dx = y*z = 15" (15.0, A.grad p 0)
  val () = checkRealTol 1E~9 "dp/dy = x*z = 10" (10.0, A.grad p 1)
  val () = checkRealTol 1E~9 "dp/dz = x*y = 6"  (6.0, A.grad p 2)
in Harness.run () end end
