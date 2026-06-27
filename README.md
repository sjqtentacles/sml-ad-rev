# sml-ad-rev

[![CI](https://github.com/sjqtentacles/sml-ad-rev/actions/workflows/ci.yml/badge.svg)](https://github.com/sjqtentacles/sml-ad-rev/actions/workflows/ci.yml)

Automatic differentiation for Standard ML that exposes a **gradient** interface:
each value carries both its scalar and a derivative function keyed by variable
id, so you can read `∂f/∂xᵢ` for every input after building an expression.

> **Implementation note (honest):** despite the `-rev` name, this is implemented
> as **forward-mode** AD — every value carries a derivative closure
> `int -> real` mapping a variable id to its partial. It is not a reverse-mode
> tape with a backward pass. For a small number of input variables the gradients
> are identical; for many inputs a true reverse-mode tape would be more
> efficient.

## API

```sml
type t   (* a differentiable scalar *)

AdRev.var x id     (* an independent variable with value x and id `id` *)
AdRev.const c      (* a constant; all partials 0 *)
AdRev.value t      (* the scalar value *)
AdRev.grad t id    (* the partial derivative w.r.t. variable `id` *)
AdRev.gradAll t ids (* the partials w.r.t. a list of ids, in order *)

(* arithmetic *)
AdRev.add a b
AdRev.sub a b
AdRev.mul a b
AdRev.divide a b   (* quotient rule *)
AdRev.neg a
AdRev.recip a      (* 1 / a *)

(* scalar helpers *)
AdRev.scale c a    (* c * a *)
AdRev.addConst c a (* c + a *)

(* transcendental / power (chain rule applied) *)
AdRev.exp a
AdRev.log a
AdRev.sin a
AdRev.cos a
AdRev.tanh a
AdRev.sqrt a
AdRev.pow a p      (* a raised to a constant real exponent p *)
```

```sml
val x = AdRev.var 2.0 0
val y = AdRev.var 3.0 1
val f = AdRev.add (AdRev.mul x y) x   (* x*y + x *)
AdRev.value f      (* 8.0 *)
AdRev.grad f 0     (* d/dx = y + 1 = 4.0 *)
AdRev.grad f 1     (* d/dy = x     = 2.0 *)

(* composition follows the chain rule automatically *)
val g = AdRev.sin (AdRev.mul x y)     (* sin(x*y) *)
AdRev.grad g 0     (* d/dx = y*cos(x*y) *)
```

## Scope and limitations

- Operations provided: `var`/`const`, `add`/`sub`/`mul`/`divide`/`neg`/`recip`,
  scalar `scale`/`addConst`, and the transcendental/power functions
  `exp`/`log`/`sin`/`cos`/`tanh`/`sqrt`/`pow`. Higher-order derivatives are not
  included (the derivative is a plain `real`, not another `t`).
- `log`/`sqrt` require a positive value and `divide`/`recip` a nonzero
  denominator for a finite derivative; no domain checking is performed.
- Forward-mode (see note above): cost scales with the number of variables you
  query.
- Variable ids are caller-managed integers; there is no symbol table.

## Installing with smlpkg

```sh
smlpkg add github.com/sjqtentacles/sml-ad-rev
smlpkg sync
```

Reference from your `.mlb`:

```
lib/github.com/sjqtentacles/sml-ad-rev/adrev.mlb
```

## Building and testing

```sh
make test        # MLton
make test-poly   # Poly/ML
make all-tests   # both
make clean
```

## Project layout

```
sml.pkg
Makefile
lib/github.com/sjqtentacles/sml-ad-rev/
  adrev.sig
  adrev.sml    dual-number AD with a gradient interface
  adrev.mlb
test/
  test.sml     product/sum rules, chained + multi-variable gradients
```

## License

MIT. See [LICENSE](LICENSE).
