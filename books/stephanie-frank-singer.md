# Stephanie Frank Singer

Stephanie Frank Singer is a **primary intellectual and stylistic reference** for `pauli`, not one bibliography item among many.

Her 2005 book *Linearity, Symmetry, and Prediction in the Hydrogen Atom* is extraordinarily close to the project this repository is trying to build: take the hydrogen atom as a concrete destination, develop the mathematics needed to reach it, and let **linearity, symmetry, and representation theory predict structure before calculation takes over**.

Primary sources:

- *Linearity, Symmetry, and Prediction in the Hydrogen Atom*: https://link.springer.com/book/10.1007/b136359
- *Symmetry in Mechanics: A Gentle, Modern Introduction*: https://link.springer.com/book/10.1007/978-1-4612-0189-2
- author page: https://symmetrysinger.com/index.php?id=math-physics

## Why Singer is unusually important here

The usual undergraduate route to hydrogen often has the explanatory order backwards:

1. write the Schrödinger equation in spherical coordinates;
2. separate variables;
3. solve differential equations;
4. introduce special functions;
5. attach the symbols `n`, `l`, and `m`;
6. draw orbitals;
7. only afterward mention that rotations, representations, conserved quantities, and degeneracies were organizing the answer all along.

Singer's hydrogen book is built around the opposite question:

> What can linearity and symmetry tell us before we solve everything?

That is almost the exact architectural question for `pauli`.

The preferred order here should therefore be:

**physical question -> visible pattern -> symmetry -> representation -> prediction -> concrete realization -> calculation**

not

**formula -> symbols -> exercises -> belated explanation**.

Springer's description says the book makes predictions about the number and kinds of basic states from two ingredients: symmetry and the linear model of quantum mechanics. It also describes the book as an “intended trek to a particularly beautiful goal.” That destination-driven structure is important. The mathematics is not dumped into a prerequisite warehouse and then retrieved hundreds of pages later.

## Style evidence from Singer herself

The preface to *Symmetry in Mechanics* is unusually explicit about pedagogy. Singer says the book is written for talented students who still want context, motivation, review, and reinforcement. She deliberately gives up density and “efficiency” in favor of a coherent story, digressions about mathematicians and physicists, simple examples worked carefully, and repeated contact with the basics.

That is a direct antidote to the style this repository should avoid.

Do **not** optimize exposition for how many standard topics fit in a chapter.

Optimize for whether the reader understands why the next idea has appeared.

In *Linearity, Symmetry, and Prediction in the Hydrogen Atom*, the same instinct becomes a route toward a single beautiful target. The reader is not told to finish a generic sequence of prerequisites first. The required mathematics is developed while walking toward hydrogen.

## *Linearity, Symmetry, and Prediction in the Hydrogen Atom*

Stephanie Frank Singer, Springer, 2005.

This is one of the closest existing statements of the purpose of `pauli`.

### Chapter 1 — Setting the Stage

The book begins by establishing the destination and the kind of prediction representation theory can make.

For `pauli`, this means the hydrogen atom should appear **before** a wall of prerequisites.

Start with questions a reader can care about:

- Why do orbitals come in families?
- Why are there exactly `2l + 1` angular states for fixed `l`?
- Why do several distinct-looking states have the same energy?
- Why do spherical harmonics appear?
- What does rotating an orbital actually do to the state?
- Why does hydrogen have more degeneracy than ordinary rotational symmetry alone explains?
- What distinguishes orbital angular momentum from spin?
- Which features are physical and which depend on a chosen basis?

The mathematics should then be introduced as answers to these questions.

### Chapter 2 — Linear Algebra over the Complex Numbers

Linearity is not housekeeping.

It is the reason superposition, eigenspaces, invariant subspaces, changes of basis, decomposition, and representation theory are available at all.

For `pauli`:

- a state is not its coefficient list;
- a linear map is not its matrix;
- an eigenspace is more informative than one displayed eigenvector;
- degeneracy is a dimension before it is a repeated number in a table;
- basis changes should be visibly distinguished from physical changes.

Whenever the software stores coordinates, the prose and type structure should remember that coordinates are a representation of the object.

### Chapter 3 — Complex Scalar Product Spaces (a.k.a. Hilbert Spaces)

The inner product supplies orthogonality, normalization, projection, and the geometry of state space.

This should inform every orbital display.

An orbital image is not merely a scalar field sampled on a grid. It is one representative of a state in a space where other states can be orthogonal, projected, decomposed, and compared.

Useful interactive consequences:

- display decomposition coefficients when a state is expanded in a basis;
- distinguish normalization from physical shape;
- show that orthogonal states may inhabit the same energy eigenspace;
- make the difference between “new coordinates” and “new state” explicit.

### Chapter 4 — Lie Groups and Lie Group Representations

This is one of the central bridges of the project.

The conceptual chain is:

1. physical space admits rotations;
2. rotations form the group SO(3);
3. the quantum state space carries an action of rotations;
4. that action is a representation;
5. irreducible pieces organize the angular states.

The user should meet `l` as a label of a rotation representation, not first as an integer that appears in a differential equation.

The application should make group action literal: rotate a state and show how a chosen basis mixes.

### Chapter 5 — New Representations from Old

Complicated state spaces are built from simpler ones.

This matters for:

- product representations;
- dual and conjugate constructions;
- restrictions;
- combined degrees of freedom;
- eventually orbital plus spin angular momentum.

Do not teach these as abstract closure operations detached from a physical need. Introduce them where a real state space has to be constructed from simpler pieces.

### Chapter 6 — Irreducible Representations and Invariant Integration

“Irreducible” answers a concrete question:

> Can the symmetry action be split into smaller invariant state spaces?

If not, that piece is irreducible.

This is the right conceptual setting for the angular multiplets that spherical harmonics realize.

Invariant integration and orthogonality explain why symmetry-adapted decomposition works. The general theory can stay behind the interface until needed, but the interface should reflect the decomposition.

### Chapter 7 — Representations and the Hydrogen Atom

Now the machinery returns to the promised physical problem.

That pacing is important. The abstraction earns its place by coming back and explaining something visible.

For `pauli`, the preferred explanatory chain is:

**symmetry -> representation -> invariant space -> labels and multiplicities -> basis -> explicit wavefunctions**

The explicit functions are important, but they are the last realization step, not the ontological beginning.

### Chapter 8 — The Algebra so(4) Symmetry of the Hydrogen Atom

This chapter is central to the repository.

SO(3) rotational symmetry does not explain the full degeneracy of the bound hydrogen spectrum.

The extra conserved Runge-Lenz structure combines with angular momentum to reveal a larger algebraic organization. For bound states this leads to the so(4) story.

The pedagogical opportunity is excellent:

1. show the observed energy degeneracy;
2. ask why SO(3) is insufficient;
3. identify the additional conserved structure;
4. show how the larger algebra organizes states that ordinary rotations leave in different `l` sectors.

This is a genuine case where symmetry predicts structure that a brute-force solution can reveal numerically without explaining.

### Chapter 9 — The Group SO(4) Symmetry of the Hydrogen Atom

Do not collapse “symmetry” into commutators alone.

Keep distinct:

1. physical transformations;
2. the group describing finite compositions;
3. the Lie algebra of infinitesimal generators;
4. the representation on the state space.

The group-level SO(4) picture explains how the infinitesimal structure belongs to a global symmetry organization.

### Chapter 10 — Projective Representations and Spin

Spin is another place where a structure-first account is much better than a stock physics-textbook metaphor.

Do not begin with a tiny ball spinning.

The better route is:

- physical rotations are described by SO(3);
- quantum states are represented only up to phase;
- projective representations of SO(3) lead naturally to ordinary representations of its double cover SU(2);
- half-integer spin then belongs to the representation theory.

This also explains why orbital angular momentum and spin share algebraic machinery without being the same physical thing.

### Chapter 11 — Independent Events and Tensor Products

Tensor products should appear when there is something to combine.

Examples:

- orbital and spin degrees of freedom;
- two independent subsystems;
- composite states;
- addition of angular momenta.

Do not make tensor products a prerequisite obstacle. Let the need for a combined state space force the construction, then use irreducible decomposition to explain angular-momentum addition.

## A direct map from Singer to `pauli`

| `pauli` topic | structural question | preferred explanation |
| --- | --- | --- |
| orbitals | what states are permitted by the symmetry? | members of representation spaces before pictures |
| spherical harmonics | how does SO(3) act on angular states? | a concrete basis for irreducible rotation representations |
| `l` | which SO(3) irreducible representation? | representation label before differential-equation parameter |
| `m` | which basis state inside the multiplet? | basis-dependent coordinate inside a `2l+1` dimensional space |
| degeneracy | why do several states share one energy? | symmetry and representation dimension, not coincidence |
| principal level `n` | why is hydrogen more degenerate than SO(3) requires? | hidden SO(4) structure |
| angular momentum | what generates rotations of states? | infinitesimal symmetry before operator recipes |
| Runge-Lenz quantity | what extra conserved structure does the Coulomb problem possess? | bridge from dynamics to hidden symmetry |
| spin | why do half-integer rotation types exist? | projective SO(3) / SU(2), not classical spinning imagery |
| coupled angular momenta | how do two symmetry actions combine? | tensor products and irreducible decomposition |
| probability amplitude | how are states compared and projected? | Hilbert-space inner product |
| basis change | what changed physically? | coordinates changed; state may not have |

## Spherical harmonics: the Singer order

A formula for `Y_l^m(theta, phi)` is not the reason spherical harmonics matter.

The better order is:

1. rotations act on angular functions;
2. ask for finite-dimensional spaces preserved by all rotations;
3. these split into irreducible pieces;
4. the piece labelled by `l` has dimension `2l+1`;
5. choose a preferred axis and a basis;
6. the familiar `Y_l^m` appear as that basis;
7. only then inspect associated Legendre functions and coordinate formulas.

This turns a special-function table into the concrete realization of a symmetry problem.

## Degeneracy should be treated as evidence

Repeated eigenvalues are not merely something to print.

They are evidence that the system has structure not yet explained.

For hydrogen, `pauli` should visibly distinguish:

- the `m` degeneracy forced by ordinary rotations;
- the larger Coulomb degeneracy relating different `l` values at fixed principal energy;
- splittings produced when a perturbation removes part of the symmetry.

A spectrum should therefore be capable of becoming a symmetry diagram, not just a list of energies.

## The Runge-Lenz structure should enter as an answer

Do not introduce the Runge-Lenz quantity as a clever conserved vector that happens to be in the syllabus.

First produce the mystery:

> the bound spectrum is more degenerate than SO(3) alone predicts.

Then ask what additional conserved structure can move among those states while preserving energy.

The Runge-Lenz quantity becomes an answer to a visible problem.

That sequence — **mystery -> conserved structure -> larger symmetry -> prediction** — is exactly the style this repository should prefer.

## *Symmetry in Mechanics: A Gentle, Modern Introduction*

Stephanie Frank Singer, Birkhäuser. Softcover first published 2001.

The chapter sequence is itself a style model:

1. **Preliminaries** — enough setup to begin;
2. **The Two-Body Problem** — the concrete problem first;
3. **Phase Spaces of Mechanical Systems are Symplectic Manifolds** — introduce the geometric object because the mechanics calls for it;
4. **Bridge to Differential Geometry** — pause and build exactly the language now needed;
5. **Total Energy Functions are Hamiltonian Functions** — reinterpret familiar energy geometrically;
6. **Symmetries are Lie Group Actions** — name the structure already present;
7. **Infinitesimal Symmetries are Lie Algebras** — pass from finite transformations to generators;
8. **Conserved Quantities are Momentum Maps** — connect symmetry to conservation in geometric language;
9. **Reduction and The Two-Body Problem** — return to the original problem with more power.

This is an unusually good model for `pauli`:

**concrete problem -> need -> mathematical structure -> return to the same problem**

Singer explicitly rejects density for its own sake. The book uses the two-body problem repeatedly rather than constantly changing examples just to cover more topics.

That is a useful software-writing rule too: one rich object examined from many mathematical directions can teach more than a gallery of disconnected examples.

## Why the mechanics book belongs beside the hydrogen book

The Kepler problem and the hydrogen atom are not unrelated examples.

Both are inverse-distance problems. Angular momentum, rotational symmetry, the Runge-Lenz structure, reduction, and hidden symmetry have classical and quantum forms.

Singer's books therefore make a useful pair:

- *Symmetry in Mechanics* shows how geometry and symmetry reorganize the classical two-body problem.
- *Linearity, Symmetry, and Prediction in the Hydrogen Atom* shows how linearity and representation theory reorganize the quantum problem.

`pauli` should make that continuity visible wherever possible.

## House rules derived from Singer

These are project rules inferred from the architecture of the books, not quotations.

### Do not build a prerequisite wall

Introduce a concept at the first point where it answers a live question.

Do not demand that the reader finish abstract algebra, functional analysis, differential equations, and quantum mechanics before being allowed to understand why a p-state has three angular basis states.

### Prediction before calculation

Before solving an equation, ask what symmetry already determines:

- possible multiplicities;
- invariant subspaces;
- permitted couplings;
- protected degeneracies;
- transformation laws;
- dimensions of representation spaces.

Then calculate only what remains.

### Separate objects from coordinates

A state is not its coefficient list.

A rotation is not its matrix.

An orbital is not its isosurface.

A spherical harmonic space is not one formula in `theta` and `phi`.

A representation is not one chosen family of matrices.

These distinctions should be reflected in code as well as prose.

### Make transformations visible

If the subject is symmetry, the application must eventually let things transform.

A static orbital gallery is insufficient.

Rotate states.
Show basis components mix.
Show invariant spaces remain invariant.
Distinguish active rotation from passive coordinate change.

### Let labels arrive after the structure

Symbols such as `n`, `l`, `m`, `j`, and `m_j` should name structures the reader has already met.

A label should answer a question, not create one.

### Treat worked examples as explanations

Singer's mechanics book deliberately works simple examples in detail.

For `pauli`, a small exact computation that exposes the structure is preferable to a large formal derivation whose purpose is unclear.

## Source / mirror status

Both books remain copyrighted Springer/Birkhäuser works. The publisher pages expose substantial tables of contents and preview material, but I have not found an openly licensed full-text edition that is appropriate to copy wholesale into this repository.

Keep the links above as the canonical source pointers. If a lawful author-posted or openly licensed full text appears later, it would be worth mirroring or indexing locally for exact-text style checks.
