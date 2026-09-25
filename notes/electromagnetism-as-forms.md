# Electromagnetism as one 2-form

Electricity and magnetism should not first appear as a list of unrelated three-dimensional formulas.

The electromagnetic field is one geometric object on spacetime.

Differential forms let us write that object without pretending that every oriented plane is fundamentally a three-dimensional arrow.

## The wedge product

For two 1-forms `a` and `b`,

```text
a ∧ b = - b ∧ a.
```

Swapping the order reverses orientation.

In particular,

```text
a ∧ a = 0.
```

The expression

```text
dx ∧ dy
```

represents an oriented area element in the `x-y` plane.

More generally, if `alpha` is a `p`-form and `beta` is a `q`-form,

```text
alpha ∧ beta = (-1)^(p q) beta ∧ alpha.
```

The wedge product needs no metric. It records orientation and multilinear antisymmetry before lengths or angles have been chosen.

## The electromagnetic field

Use spacetime coordinates `t, x, y, z`, units with `c = 1`, metric signature `(-,+,+,+)`, and orientation

```text
dt ∧ dx ∧ dy ∧ dz.
```

With this convention the electromagnetic field 2-form is

```text
F =
    E_x dx ∧ dt
  + E_y dy ∧ dt
  + E_z dz ∧ dt
  + B_x dy ∧ dz
  + B_y dz ∧ dx
  + B_z dx ∧ dy.
```

This is the coordinate-free electromagnetic field written in one chosen coordinate system.

The usual antisymmetric field tensor is the component table of this same 2-form:

```text
        t      x      y      z
t       0    -E_x   -E_y   -E_z
x      E_x     0     B_z   -B_y
y      E_y   -B_z     0     B_x
z      E_z    B_y   -B_x     0
```

The antisymmetry of the table is not an extra rule. It is already built into the wedge product.

## The Hodge star

The wedge product knows orientation but not length.

The Hodge star uses the metric and the chosen orientation.

In four-dimensional spacetime it sends a `k`-form to a `(4-k)`-form.

Its defining relation is

```text
alpha ∧ *beta = <alpha, beta> volume.
```

So `*beta` is the complementary oriented object determined by the metric.

For the electromagnetic 2-form, `*F` is another 2-form. It exchanges the electric and magnetic parts, with signs fixed by the spacetime convention.

In Lorentzian four-space,

```text
*(*F) = -F
```

for 2-forms.

That is one place where a quarter-turn structure is genuinely present rather than being decorative notation.

## Maxwell's equations

Let `J` be the electric current 3-form.

In rationalized units, Maxwell's equations become

```text
dF = 0
d*F = J.
```

The first equation contains Faraday induction and the absence of magnetic monopoles.

The second contains Gauss's electric law and the Ampère-Maxwell law.

Four familiar vector-calculus equations have become two equations because the geometry was allowed to remain visible.

## Potential and gauge freedom

Locally, when there are no magnetic monopoles,

```text
F = dA
```

for a 1-form `A`, the electromagnetic potential.

Changing

```text
A -> A + d chi
```

does not change the field because

```text
d(d chi) = 0.
```

That is gauge freedom in its simplest form: different potentials can describe the same electromagnetic field.

The redundant description is not a defect to be hidden. It is part of the geometry.
