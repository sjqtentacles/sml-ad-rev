signature ADREV =
sig
  (* A differentiable scalar: its value plus a closure giving the partial
     derivative with respect to any variable id. *)
  type t

  (* An independent variable with value `x` and id `id`. Its partial w.r.t.
     itself is 1, w.r.t. every other id is 0. *)
  val var : real -> int -> t

  (* A constant: value `c`, all partials 0. *)
  val const : real -> t

  (* The scalar value of an expression. *)
  val value : t -> real

  (* The partial derivative of an expression w.r.t. variable `id`. *)
  val grad : t -> int -> real

  (* The partials w.r.t. a list of ids, in the same order. *)
  val gradAll : t -> int list -> real list

  (* Arithmetic. *)
  val add : t -> t -> t
  val sub : t -> t -> t
  val mul : t -> t -> t
  val divide : t -> t -> t   (* quotient rule; value of b must be nonzero *)
  val neg : t -> t
  val recip : t -> t         (* 1 / a; value of a must be nonzero *)

  (* Scalar (constant) helpers. *)
  val scale : real -> t -> t   (* c * a *)
  val addConst : real -> t -> t

  (* Transcendental / power functions (chain rule applied). *)
  val exp  : t -> t
  val log  : t -> t            (* value must be positive *)
  val sin  : t -> t
  val cos  : t -> t
  val tanh : t -> t
  val sqrt : t -> t            (* value must be positive for a finite derivative *)
  val pow  : t -> real -> t    (* a raised to a constant real exponent *)
end
