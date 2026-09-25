# What is magnetism?

This folder exists because the label **magnetic quantum number** is easy to memorize long before it means anything.

The question for `pauli` is more concrete:

> Why does the integer usually called `m` have anything to do with magnetism?

A useful route into that question starts outside quantum notation.

## First: what does a magnetic field do?

A magnetic field changes the motion of moving electric charge. In the classical Lorentz-force law,

```text
force = charge × (electric field + velocity × magnetic field)
```

the magnetic part of the force is perpendicular to both the particle's motion and the magnetic field.

Moving charge also produces magnetic field. A loop of current produces a dipole field: the familiar two-pole pattern associated with a compass needle or bar magnet.

Those two statements already connect three things that later meet inside the atom:

- electric charge;
- motion / angular momentum;
- magnetic dipole moment.

The PBS Space Time episode [*How Magnetism Shapes The Universe*](pbs-space-time.md#how-magnetism-shapes-the-universe) is the best first video in this folder for that picture.

## Electric and magnetic fields are not independent worlds

A deeper point is that the division into "electric field" and "magnetic field" depends on the observer's state of motion.

Different inertial observers can split the same electromagnetic field differently into electric and magnetic parts while agreeing on the physical force.

PBS Space Time makes this point in [*The Speed of Light is NOT About Light*](pbs-space-time.md#the-speed-of-light-is-not-about-light).

So "magnetism comes from moving charge" is useful, but it should not be mistaken for a complete definition of magnetism. Electricity and magnetism are two aspects of one electromagnetic field.

## Why does orbital angular momentum carry a magnetic moment?

For a negatively charged electron, orbital angular momentum is accompanied by an orbital magnetic dipole moment.

In the ordinary nonrelativistic hydrogen model,

```text
μ_L = - μ_B L / ħ
```

where:

- `L` is orbital angular momentum;
- `μ_L` is the associated orbital magnetic moment;
- `μ_B` is the Bohr magneton.

Choose a spatial axis, conventionally called `z`. The states normally labelled by `m` satisfy

```text
L_z = m ħ
```

on that state, so the magnetic moment along the same axis is

```text
μ_L,z = -m μ_B
```

That is the direct connection.

The integer `m` is fundamentally an **angular-momentum component label after an axis has been chosen**. It acquired the name **magnetic quantum number** because an external magnetic field couples to the corresponding magnetic moment and separates states with different `m`.

For a weak uniform field in the chosen `z` direction, ignoring spin and the finer corrections,

```text
ΔE = m μ_B B
```

for the normal orbital Zeeman effect.

So a public-facing alias such as `m_magnetism` is useful if we also preserve the more exact meaning:

```text
m_magnetism
m_axis_component
```

The first tells the reader why the historical name matters. The second says what the number is actually labelling before a magnetic field is applied.

## Spin is a separate source of magnetic moment

Do not explain the electron as a tiny charged ball literally spinning.

Electron spin is intrinsic quantum angular momentum. It also carries a magnetic moment, but its relation to magnetism is not the same classical-current-loop story as orbital angular momentum.

PBS Space Time's [*Electrons DO NOT Spin*](pbs-space-time.md#electrons-do-not-spin) starts from the Zeeman and Stern-Gerlach experiments and is useful precisely because it marks that distinction.

[*Quantum Theory's Most Incredible Prediction*](pbs-space-time.md#quantum-theorys-most-incredible-prediction) then follows the electron magnetic dipole moment into the Dirac prediction and the quantum-electrodynamic correction to the electron's `g` factor.

## What this means for the hydrogen renderer

For the orbital state labels, prefer names that expose meaning:

```text
n_energy
l_angular_degree
m_axis_component
```

and allow the pedagogical alias

```text
m_magnetism
```

where useful.

Do not imply that choosing `m` means "turning magnetism on." Hydrogen has the `m` basis label even with no external magnetic field. A magnetic field makes that label physically conspicuous because the field couples to the associated angular momentum and magnetic moment.

## Next question

A good continuation is:

> If `m` is an angular-momentum component along a chosen axis, why are the only possibilities `-l, ..., l`, and why does a magnetic field distinguish those states?

That question connects rotations, the `2l + 1` dimensional angular family, the Zeeman effect, and the pictures the renderer is supposed to show.
