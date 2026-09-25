# What is angular momentum?

This folder exists because the notation `l`, `m`, "spin up", and "spin down" should not appear before the reader has any idea what **angular momentum** is.

## Start with an ordinary rotating object

PBS Space Time's [*Can A Starfox Barrel Roll Work in Space?*](videos.md#can-a-starfox-barrel-roll-work-in-space) is a good first stop.

The episode uses a flywheel in a spacecraft to show the important facts without beginning from quantum mechanics:

- a rotating object can carry angular momentum;
- angular momentum has a magnitude and an axis;
- changing one part of an isolated system's angular momentum forces another part to compensate;
- that is why reaction wheels and control-moment gyroscopes can turn a spacecraft without throwing mass away.

For an ordinary point mass,

```text
angular momentum = position ∧ momentum
```

The usual three-dimensional textbook notation replaces this oriented plane by its Hodge-dual arrow,

```text
L = r × p
```

but `pauli` should not let the cross product hide the underlying geometric object.

## What does the arrow mean?

For a rigid object rotating around a fixed axis, the familiar angular-momentum arrow points along the rotation axis according to the right-hand convention.

That does **not** mean that angular momentum is fundamentally an arrow. In three dimensions an oriented plane can be represented by a perpendicular arrow, which is convenient.

This distinction matters later, because quantum angular momentum is not best understood as a tiny object literally spinning around an axis.

## Then move to an electron in an atom

The hydrogen orbital state has orbital angular momentum.

For a state with angular degree `l`,

```text
L² = l(l + 1) ħ²
```

after choosing one axis, conventionally called `z`,

```text
L_z = m ħ
```

with

```text
m = -l, -l+1, ..., l-1, l
```

This is the clean meaning of `m`:

> choose an axis first; `m` says which allowed component of orbital angular momentum the state has along that axis.

The axis is **not** chosen by `m`.

This is why the public names should expose both levels:

```text
l_angular_degree
m_axis_component
```

and, where the magnetic consequence is the point,

```text
m_magnetism
```

can be an explanatory alias.

## Why only certain components?

Classically, a rotating object's angular-momentum component can vary continuously.

Quantum mechanically, a state with fixed `l` has only `2l + 1` possible component values along a chosen axis.

That is the fact the usual integer `m` is recording.

For example:

```text
l = 0  →  m = 0
l = 1  →  m = -1, 0, 1
l = 2  →  m = -2, -1, 0, 1, 2
l = 3  →  m = -3, ..., 3
l = 4  →  m = -4, ..., 4
```

So `m = 4` first becomes possible when `l = 4`, the `g` angular family, which first occurs for hydrogen at `n = 5`.

## Spin is angular momentum too, but not orbital motion

PBS Space Time's [*Electrons DO NOT Spin*](videos.md#electrons-do-not-spin) is the next step.

Electron spin is **intrinsic angular momentum**. It is not adequately modeled as a tiny charged ball rotating in space.

For an electron, measuring the spin component along a chosen axis gives only

```text
+ħ/2
-ħ/2
```

Those are the two outcomes usually called **spin up** and **spin down** relative to that measurement axis.

So "up" and "down" do not mean that the electron has a little north pole permanently pointing up or down in ordinary space. They are names for the two possible component outcomes when spin is measured along a chosen axis.

## The visual spinor material

The Jason Hise and Alexander Holroyd animations in [videos.md](videos.md#spinors-360-degrees-and-720-degrees) answer a different but related question:

> Why do spin-½ states have the strange 360°/720° rotation behavior?

The belt trick and spinor linkage make the double-cover geometry visible.

Do **not** use them as the first explanation of angular momentum. They are the next layer after the reader understands:

1. ordinary angular momentum;
2. choosing an axis and measuring a component;
3. intrinsic spin as a quantum angular momentum.

## Suggested path

```text
rotating flywheel
→ angular momentum and conservation
→ orbital angular momentum in hydrogen
→ choose an axis
→ m is the allowed component along that axis
→ intrinsic spin
→ spin up / spin down
→ spinor 360° / 720° geometry
```

That order keeps `m` and "spin up" from arriving as unexplained vocabulary.
