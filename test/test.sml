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

  val () = section "const and gradAll"
  val c = A.const 7.0
  val () = checkRealTol 1E~9 "const value" (7.0, A.value c)
  val () = checkRealTol 1E~9 "const grad = 0" (0.0, A.grad c 0)
  (* p = x*y*z; gradient w.r.t [0,1,2] = [15,10,6] *)
  val ga = A.gradAll p [0,1,2]
  val () = checkInt "gradAll length" (3, List.length ga)
  val () = checkRealTol 1E~9 "gradAll[0]" (15.0, List.nth (ga, 0))
  val () = checkRealTol 1E~9 "gradAll[1]" (10.0, List.nth (ga, 1))
  val () = checkRealTol 1E~9 "gradAll[2]" (6.0, List.nth (ga, 2))

  val () = section "sub / neg"
  val s = A.sub x y                  (* x - y, value 2-3 = -1 *)
  val () = checkRealTol 1E~9 "value x-y = -1" (~1.0, A.value s)
  val () = checkRealTol 1E~9 "d(x-y)/dx = 1" (1.0, A.grad s 0)
  val () = checkRealTol 1E~9 "d(x-y)/dy = -1" (~1.0, A.grad s 1)
  val n = A.neg x
  val () = checkRealTol 1E~9 "value -x = -2" (~2.0, A.value n)
  val () = checkRealTol 1E~9 "d(-x)/dx = -1" (~1.0, A.grad n 0)

  val () = section "divide / recip (quotient rule)"
  (* q = x / y, value 2/3 ; dq/dx = 1/y = 1/3 ; dq/dy = -x/y^2 = -2/9 *)
  val q = A.divide x y
  val () = checkRealTol 1E~9 "value x/y" (2.0/3.0, A.value q)
  val () = checkRealTol 1E~9 "dq/dx = 1/y" (1.0/3.0, A.grad q 0)
  val () = checkRealTol 1E~9 "dq/dy = -x/y^2" (~2.0/9.0, A.grad q 1)
  val r = A.recip y                  (* 1/y, value 1/3 ; d/dy = -1/y^2 = -1/9 *)
  val () = checkRealTol 1E~9 "value 1/y" (1.0/3.0, A.value r)
  val () = checkRealTol 1E~9 "d(1/y)/dy = -1/y^2" (~1.0/9.0, A.grad r 1)

  val () = section "scale / addConst"
  val sc = A.scale 4.0 x             (* 4x, value 8 ; d/dx = 4 *)
  val () = checkRealTol 1E~9 "value 4x = 8" (8.0, A.value sc)
  val () = checkRealTol 1E~9 "d(4x)/dx = 4" (4.0, A.grad sc 0)
  val ac = A.addConst 10.0 x         (* x+10, value 12 ; d/dx = 1 *)
  val () = checkRealTol 1E~9 "value x+10 = 12" (12.0, A.value ac)
  val () = checkRealTol 1E~9 "d(x+10)/dx = 1" (1.0, A.grad ac 0)

  val () = section "transcendentals (chain rule)"
  (* exp(x), x=2 : value e^2 ; d/dx = e^2 *)
  val ex = A.exp x
  val () = checkRealTol 1E~9 "exp value" (Math.exp 2.0, A.value ex)
  val () = checkRealTol 1E~9 "d exp/dx" (Math.exp 2.0, A.grad ex 0)
  (* log(x), x=2 : d/dx = 1/2 *)
  val lg = A.log x
  val () = checkRealTol 1E~9 "log value" (Math.ln 2.0, A.value lg)
  val () = checkRealTol 1E~9 "d log/dx = 1/x" (0.5, A.grad lg 0)
  (* sin(x), x=2 : d/dx = cos 2 *)
  val sn = A.sin x
  val () = checkRealTol 1E~9 "sin value" (Math.sin 2.0, A.value sn)
  val () = checkRealTol 1E~9 "d sin/dx = cos" (Math.cos 2.0, A.grad sn 0)
  (* cos(x), x=2 : d/dx = -sin 2 *)
  val cs = A.cos x
  val () = checkRealTol 1E~9 "cos value" (Math.cos 2.0, A.value cs)
  val () = checkRealTol 1E~9 "d cos/dx = -sin" (~ (Math.sin 2.0), A.grad cs 0)
  (* tanh(x), x=2 : d/dx = 1 - tanh^2 *)
  val th = A.tanh x
  val () = checkRealTol 1E~9 "tanh value" (Math.tanh 2.0, A.value th)
  val () = checkRealTol 1E~9 "d tanh/dx" (1.0 - Math.tanh 2.0 * Math.tanh 2.0, A.grad th 0)
  (* sqrt(x), x=2 : d/dx = 1/(2 sqrt 2) *)
  val sq = A.sqrt x
  val () = checkRealTol 1E~9 "sqrt value" (Math.sqrt 2.0, A.value sq)
  val () = checkRealTol 1E~9 "d sqrt/dx" (0.5 / Math.sqrt 2.0, A.grad sq 0)
  (* pow(x,3), x=2 : value 8 ; d/dx = 3 x^2 = 12 *)
  val pw = A.pow x 3.0
  val () = checkRealTol 1E~9 "pow value 2^3 = 8" (8.0, A.value pw)
  val () = checkRealTol 1E~9 "d(x^3)/dx = 3x^2 = 12" (12.0, A.grad pw 0)

  val () = section "composition: f = sin(x*y) wrt x,y"
  (* f = sin(xy), x=2,y=3 -> value sin 6 ; df/dx = y cos(6) ; df/dy = x cos(6) *)
  val comp = A.sin (A.mul x y)
  val () = checkRealTol 1E~9 "value sin(xy)" (Math.sin 6.0, A.value comp)
  val () = checkRealTol 1E~9 "df/dx = y cos(xy)" (3.0 * Math.cos 6.0, A.grad comp 0)
  val () = checkRealTol 1E~9 "df/dy = x cos(xy)" (2.0 * Math.cos 6.0, A.grad comp 1)
in Harness.run () end end
