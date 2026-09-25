# Square integrability: what condition is actually being imposed?

"Square-integrable" should never be left as unexplained vocabulary.

A wavefunction represents a state by complex amplitudes. The probability assigned to a region comes from the squared magnitude of those amplitudes.

The relevant condition is therefore:

```text
the total squared magnitude over all space is finite
```

because only then can one rescale the state so that the total probability is exactly one.

If that total is infinite, multiplying by a nonzero constant still leaves it infinite. The function cannot represent a normalized one-particle state in the Hilbert space.

## This is not the same as boundedness

A bounded function may fail to be square-integrable. The constant function on all of space never becomes large, but its total squared mass is infinite.

An unbounded function may still be square-integrable if its singular behavior is sufficiently confined.

So the issue is not claustrophobia about functions becoming large. The issue is whether the function has finite Hilbert-space norm.

## Why the square appears

The Hilbert-space inner product pairs one state with another. Pairing a state with itself gives its squared length.

For wavefunctions that squared length is the integral of squared magnitude.

Unitary time evolution preserves this norm. That is the direct connection between Hilbert-space geometry and conservation of total probability.
