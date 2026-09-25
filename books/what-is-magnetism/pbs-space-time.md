# PBS Space Time: magnetism path

These are not a substitute for a derivation. They are a useful conceptual path from ordinary magnetic fields to the particular reason the hydrogen label `m` is called magnetic.

## How Magnetism Shapes The Universe

PBS Space Time, Season 7 Episode 24, 21 July 2021, 13m 26s.

PBS:
https://www.pbs.org/video/how-magnetism-shapes-the-universe-gezfxo/

YouTube:
https://www.youtube.com/watch?v=_H4xrVzd65Q

### Why it belongs here

Start here.

The episode reviews the two classical facts needed for the rest of this folder:

- moving electric charges produce magnetic fields;
- moving charges in a magnetic field are deflected by a force perpendicular to their motion and the field.

It then uses current loops and dipole fields to explain why magnetic dipoles tend to align with an external magnetic field.

For `pauli`, the useful bridge is:

```text
charge + angular motion
        ↓
magnetic dipole moment
        ↓
interaction with external magnetic field
```

Do not import the current-loop picture literally into quantum orbital mechanics. Use it to motivate why charge, angular momentum, and magnetic moment belong in the same conversation.

## The Speed of Light is NOT About Light

PBS Space Time, Season 2 Episode 3, 7 October 2015, 10m 44s.

PBS:
https://www.pbs.org/video/pbs-space-time-speed-light-not-about-light/

YouTube:
https://www.youtube.com/watch?v=msVuCEs8Ydo

### Why it belongs here

This is the corrective to an overly simple slogan such as "magnetism is just electricity caused by motion."

The episode asks how two observers moving relative to one another can assign different electric and magnetic fields while agreeing on the electromagnetic force. Electric and magnetic fields trade into one another under Lorentz transformations.

For the repository, this is a reason to avoid treating magnetism as an unrelated second force glued onto electrostatics. The more durable object is the electromagnetic field; its electric/magnetic split depends on the observer.

## Electrons DO NOT Spin

PBS Space Time, Season 7 Episode 22, 7 July 2021, 14m 05s.

PBS:
https://www.pbs.org/video/electrons-do-not-spin-i249yl/

YouTube:
https://www.youtube.com/watch?v=pWlk1gLkF2Y

### Why it belongs here

This is especially relevant to the name "magnetic quantum number" because it starts from magnetic splitting of atomic energy levels.

The episode discusses:

- the Zeeman effect;
- the magnetic moment associated with orbital angular momentum;
- the additional intrinsic magnetic moment associated with electron spin;
- why literal rotation of a tiny charged electron is the wrong model;
- the Stern-Gerlach experiment and quantized outcomes.

The important distinction for `pauli` is:

```text
orbital angular momentum → orbital magnetic moment
spin                    → intrinsic magnetic moment
```

Both interact with magnetic fields. They are not the same angular momentum.

## Quantum Theory's Most Incredible Prediction

PBS Space Time, Season 4 Episode 35, 15 August 2018, 12m 36s.

PBS:
https://www.pbs.org/video/quantum-theorys-most-incredible-prediction-fziuvk/

YouTube:
https://www.youtube.com/watch?v=7UwigY4SjKY

### Why it belongs here

This episode focuses on the electron magnetic dipole moment and the `g` factor.

It is useful after *Electrons DO NOT Spin* because it pushes the magnetic moment beyond the qualitative "tiny bar magnet" analogy:

- the Dirac theory gives the leading quantum prediction;
- quantum electrodynamics shifts the result slightly;
- experiment measures that shift to extraordinary precision.

This is less directly about orbital `m`, but it is useful protection against collapsing every atomic magnetic effect into a classical orbit picture.

## Suggested viewing order

1. *How Magnetism Shapes The Universe*
2. *The Speed of Light is NOT About Light*
3. *Electrons DO NOT Spin*
4. *Quantum Theory's Most Incredible Prediction*

The order is conceptual rather than chronological:

```text
what magnetic fields do
→ why electric and magnetic fields belong together
→ why atomic angular momentum has magnetic consequences
→ why the electron's intrinsic magnetic moment is genuinely quantum
```

## Relation to the `m` label

None of these four videos by itself gives the clean mathematical statement needed by the renderer:

```text
L_z |n,l,m⟩ = m ħ |n,l,m⟩
μ_L,z |n,l,m⟩ = -m μ_B |n,l,m⟩
```

That statement belongs in the repository's own explanation.

The videos supply the physical questions that make the statement worth deriving instead of presenting `m` as another unexplained integer in a chemistry table.
