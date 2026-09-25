# What question does the Laplacian answer?

Do not begin with the surname.

Suppose a number is attached to every point in space: temperature, pressure, membrane displacement, electric potential, or something else.

At one point, ask:

> Is this value above, below, or in balance with the values immediately around it?

That is the local question behind the Laplacian.

## Start in one dimension

On a line, the second derivative measures local bending.

A point on a graph that sits above its nearby neighbors bends downward.
A point that sits below them bends upward.
A straight piece has no such local bending.

In several independent directions, ask the same question in each direction and add the answers.

In ordinary three-dimensional Cartesian coordinates,

```text
Delta f =
    second change in x
  + second change in y
  + second change in z.
```

In conventional notation,

```text
Delta f =
    d²f/dx²
  + d²f/dy²
  + d²f/dz².
```

The symbol `Delta` and the name *Laplacian* are labels for that operation.
They are not the explanation.

Another compact description is:

```text
Laplacian = divergence of gradient.
```

That is useful after gradient and divergence already mean something to the reader.
It is not a better first sentence.

## The nearby-average picture

There is a more geometric way to say the same thing.

For a smooth function, the Laplacian tells us, to second order, how the value at a point differs from the average of values on a very small sphere around it.

With the usual sign convention:

- a local peak tends to have negative Laplacian;
- a local hollow tends to have positive Laplacian;
- zero means local balance.

This is why the same operator keeps appearing in apparently different subjects.

## Heat

Imagine one spot that is hotter than everything immediately around it.

Heat flows away from that spot.

If one spot is colder than its surroundings, heat flows toward it.

The heat equation says that the rate of temperature change is controlled by exactly this local imbalance.

So the Laplacian is natural here because it asks the question heat flow needs answered:

> how different is this point from its immediate surroundings?

## A drumhead

Stretch a membrane over a frame and push one small patch upward.

Its neighbors pull it back.

The restoring force is not determined just by how high the patch is. It depends on how the membrane bends relative to the nearby patches.

That local bending is what the Laplacian measures.

A vibrating membrane therefore has an equation of the form

```text
acceleration = constant × Laplacian(displacement).
```

The special vibration patterns that reproduce their own shape while oscillating are the membrane's natural modes.

![A normal mode of a vibrating circular drumhead](https://upload.wikimedia.org/wikipedia/commons/6/6d/VibratingDrumhead4.gif)

The animation is **CC0 / public domain**, by Wikimedia Commons user LunarEclipse2014:

https://commons.wikimedia.org/wiki/File:VibratingDrumhead4.gif

It is a solution of the wave equation on a circular membrane.

## Can you hear the shape of a drum?

The shape of the drum and its boundary determine which vibration modes are possible and their frequencies.

Mark Kac made this into a memorable question:

> Can one hear the shape of a drum?

In modern language: if we know all the natural frequencies selected by the Laplacian on a region, do those frequencies determine the region's shape?

This is a good example of a surname entering after the question.
The interesting object is the relation between **shape** and **possible modes**.

See [Mark Kac](../books/mark-kac.md).

## Harmonic means local balance here

A harmonic function satisfies

```text
Delta f = 0.
```

In the nearby-average picture, that says the value at a point is exactly balanced by its surroundings.

This use of *harmonic* should not be confused with the musical use where a harmonic is an integer multiple of a fundamental frequency.

The words are historically related through vibration problems, but they name different things.

## Why this leads to spherical harmonics

Hydrogen has a point nucleus and no preferred spatial direction before we choose one.

Distance from the nucleus gives spheres.

Once the radial part is separated from the angular question, we need the same local-balance operator **on the sphere itself**.

That curved-surface version is often called the spherical Laplacian or Laplace-Beltrami operator.

Its natural angular modes are the spherical harmonics.

There is an especially concrete equivalent construction in ordinary three-space:

1. make homogeneous polynomials in `x, y, z`;
2. keep the ones whose ordinary three-dimensional Laplacian is zero;
3. restrict those harmonic polynomials to the unit sphere.

Those restrictions are spherical harmonics.

This is the route the Sage notebook should compute before introducing associated Legendre formulas.

## Sound makes the idea familiar

The same note can sound unlike itself when played by a flute, oboe, clarinet, or human voice because the fundamental pitch is only part of the sound.

Different resonant systems favor different mixtures and time envelopes of modes.

That is the bridge to timbre.

Human vowels give another familiar example. The vocal folds provide a source; the changing shape of the vocal tract favors particular resonances. Those resonances help make one vowel sound unlike another.

These examples are not claims that every detail of timbre or speech is "just the Laplacian."

They are reminders that **shape selects modes**, and that we already hear the consequences every day.

See [Eric Heller](../books/eric-heller.md) and [Kenneth N. Stevens](../books/kenneth-stevens.md).
