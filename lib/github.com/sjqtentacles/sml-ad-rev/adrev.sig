signature ADREV =
sig
  type t
  val var : real -> int -> t
  val value : t -> real
  val grad : t -> int -> real
  val mul : t -> t -> t
  val add : t -> t -> t
end
