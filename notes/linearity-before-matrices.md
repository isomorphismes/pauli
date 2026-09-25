# Linearity before matrices

A matrix should not be the first reason to care about a linear map.

Start with a change that preserves the origin and preserves addition.

A ruler marked in inches and centimeters is a simple example. Zero stays zero, and doubling a length doubles both readings. Changing from one scale to the other is multiplication by a constant.

Temperature scales show why the fixed zero matters. Celsius and Fahrenheit are related by

```text
new reading = scale × old reading + offset
```

That is affine rather than linear. The extra offset is exactly what disappears when the origin is fixed.

This distinction is small, but it explains a large amount of later language.

## Two quantities at once

Suppose two controls determine a state.

Call them hot and cold.

Instead of recording them separately, one can record

```text
total = hot + cold
difference = hot - cold
```

Nothing mystical happened. We chose new coordinates for the same two-dimensional space because those coordinates may answer the physical question more directly.

The familiar `A + B`, `A - B` change of variables should enter this way: as a useful re-description of two coupled quantities, not as an algebra trick from nowhere.

## Why matrices appear

A linear map is the change itself.

A matrix is what that change looks like after bases have been chosen.

Matrices are useful because composition becomes mechanical bookkeeping: perform one linear change, then another, and matrix multiplication records the combined effect.

The object comes first.
The matrix is its coordinate record.

## Multilinear is the same idea with several inputs

A multilinear quantity is linear in each input separately.

Oriented area is the basic example.

If one side is doubled while the other is held fixed, the area doubles.
If the two sides are exchanged, the orientation reverses.

The wedge product records exactly this structure:

```text
u ∧ v = -v ∧ u
```

and therefore

```text
u ∧ u = 0.
```

That is the bridge from ordinary linear algebra to differential forms and the electromagnetic field.

## Why keep the temperature story nearby?

Don S. Lemons's *Thermodynamic Weirdness* and Hasok Chang's *Inventing Temperature* are useful reminders that even a familiar numerical scale has a history.

Scientists had to decide what quantity a thermometer was measuring, how different instruments could be compared, what should count as a fixed point, and which transformations between scales preserved the physical relations they cared about.

That is a better starting point for linear and affine structure than presenting `Ax+b` as notation with no problem attached.
