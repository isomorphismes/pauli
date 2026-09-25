# Gerald B. Folland — *Quantum Field Theory: A Tourist Guide for Mathematicians*

Gerald B. Folland is a style reference for `pauli` because he writes across a real cultural boundary: mathematics and working theoretical physics.

Canonical sources:

- Google Books preview: https://books.google.com/books?id=nPEbEAAAQBAJ
- MAA review with substantial discussion of the preface and chapter route: https://old.maa.org/press/maa-reviews/quantum-field-theory-a-tourist-guide-for-mathematicians
- author's page and errata: https://sites.math.washington.edu/~folland/

The important habit is not “make physics more rigorous at all costs.” Folland is explicit that some parts of quantum field theory do not have the sort of rigorous foundation a mathematician might want. His response is to say precisely where the mathematics is solid, where physicists use a formal procedure, and what the procedure is trying to accomplish.

That honesty is a good model for `pauli`.

## Style evidence

Folland frames the reader as a tourist entering a foreign mathematical culture.

That metaphor matters because it changes the job of exposition.

A bad translation says:

> physicists write this, so memorize it.

A bad translation in the other direction says:

> this is not fully rigorous, so we cannot talk about it.

Folland instead tries to explain what physicists are doing in language a mathematically trained reader can parse, while marking the places where the mathematical status changes.

For `pauli`, use the same rule:

- say what the object is;
- say how physicists usually write it;
- say when the notation suppresses a mathematical distinction;
- say when a statement is exact, heuristic, conventional, or computational;
- then continue.

Do not fake rigor and do not fake simplicity.

## Chapter route

### Chapter 1 — Prologue

Folland begins by translating language.

The prologue covers notation and terminology, dimensions and units, particles, and enough Lie-group/Lie-algebra language to support later chapters.

This is relevant to `pauli` because notation should be introduced as translation, not as a loyalty test.

If chemistry, physics, and mathematics use three different names for related objects, say so. Then choose one house term and explain why.

Do not make the reader infer that two notations refer to the same structure.

### Chapter 2 — Review of Prequantum Physics

The book goes backward before going forward: classical mechanics, Hamiltonian mechanics, electromagnetism, and relativity are reviewed because later quantum-field constructions reuse their structures.

For `pauli`, this is a model for historical/structural prerequisites:

- introduce classical angular momentum before quantum angular momentum when the comparison clarifies the latter;
- introduce the classical Kepler problem before hidden symmetry in hydrogen;
- show what survives quantization and what changes.

The point is continuity, not chronology for its own sake.

### Chapter 3 — Basic Quantum Mechanics

The quantum-mechanical chapter gives the mathematical reader the structures physicists actually use: Hilbert spaces, observables, states, spectral ideas, and Schrödinger dynamics.

The `pauli` lesson is to identify these objects before committing to coordinate formulas.

A wavefunction is one representation of a state.
A differential expression represents an operator after choices and domain questions enter.
An eigenvalue equation describes a spectral relation, not merely an algebra exercise.

### Chapter 4 — Relativistic Quantum Mechanics

Relativity changes which equations and representations are natural.

This chapter is useful stylistically because Folland does not pretend that a new formalism has appeared from nowhere. The physical constraint changes first; the mathematical language changes in response.

Use that causal order in `pauli`.

If a new symmetry group, representation, or operator is introduced, say what physical requirement forced the change.

### Chapter 5 — Free Quantum Fields

The subject moves from one-particle quantum mechanics to fields, with Lagrangians, Hamiltonians, canonical quantization, creation and annihilation operators, and Fock-space structure.

The transferable lesson is that a ladder operator should not first appear as a clever algebraic trick.

Introduce it as an operation that moves among states in a structured state space.

For hydrogen, the analogous warning applies to angular-momentum raising and lowering operators.

Do not begin with the commutator recipe. Begin with the multiplet and the action that moves within it.

### Chapter 6 — Quantum Fields with Interactions

Interactions force the use of perturbative tools, scattering language, Feynman diagrams, and the S-matrix.

Here Folland must continually distinguish a physical procedure from a fully controlled mathematical construction.

That is an important style discipline for `pauli` whenever numerical or symbolic procedures enter:

- identify what is exact;
- identify what is an approximation;
- identify the expansion parameter;
- identify what is being truncated;
- explain what would fail if the approximation were pushed too far.

A computational result should not silently inherit the authority of an exact theorem.

### Chapter 7 — Renormalization

Renormalization is precisely the kind of topic that becomes unreadable when exposition starts from formal manipulations and assumes the reader already knows why they are being performed.

Folland's broader strategy is useful here: explain the physical calculation, the divergence problem, and the mathematical status of the repair.

For `pauli`, whenever a regularization, cutoff, normalization, or numerical stabilization is introduced, give the problem first.

### Chapter 8 — Functional Integrals

Functional integrals are another place where physicists' notation can outrun rigorous measure-theoretic foundations.

Folland does not solve this by pretending the issue is absent.

The `pauli` rule should be similar:

> when a useful formal object is not literally the same thing as the rigorously defined object nearby, say so in one plain sentence.

Do not leave mathematically sophisticated readers wondering whether the distinction was overlooked.

### Chapter 9 — Gauge Field Theories

The book closes with gauge fields, broken symmetry, and the electroweak theory.

This chapter reinforces the importance of treating symmetry as structural rather than decorative.

For `pauli`, gauge language should be introduced geometrically where possible and tied to an actual freedom of description or physical invariance.

## A Folland-style translation table for `pauli`

| physicists may say | mathematical clarification worth making |
| --- | --- |
| “the wavefunction” | a coordinate realization of a state in a Hilbert space |
| “the angular momentum operator” | a generator of the rotation representation, represented by an operator on the state space |
| “rotate the orbital” | act on the state by the rotation representation; coordinates may then change |
| “the Hamiltonian is this differential equation” | the Hamiltonian is an operator; this is its coordinate differential expression on an appropriate domain |
| “these states are degenerate” | the energy eigenspace has dimension greater than one; ask which symmetry acts inside it |
| “choose the z-axis” | choose a basis adapted to one generator; the underlying representation is not changed |
| “gauge transformation” | change of description with specified invariant physical content |
| “solve exactly” | specify whether this means analytic closed form, spectral characterization, or numerically exact within a finite representation |

## Style rules derived from Folland

These are project rules, not quotations.

### Translate cultures explicitly

If a chemist, physicist, and mathematician would use different language, do not pick one and pretend the others do not exist.

Say:

> Chemists usually call these p orbitals. Representation-theoretically, they form the `l = 1` rotation space.

That sentence connects two real practices.

### Mark the status of a statement

Useful labels in prose include:

- exact;
- definition;
- consequence of symmetry;
- coordinate choice;
- approximation;
- perturbative;
- numerical;
- conventional notation;
- heuristic picture.

Most of the time these labels can be embedded naturally rather than formatted as warnings.

### Do not confuse rigor with opacity

A mathematically careful sentence can still be readable.

Bad:

> Let `H` denote a self-adjoint operator on a separable complex Hilbert space satisfying...

Better:

> Energy is represented by a self-adjoint operator. Self-adjointness is what gives real measured energies and a spectral decomposition. In coordinates, hydrogen gives the familiar differential expression...

Then state the precise assumptions when they become relevant.

### Tell the reader when notation lies by omission

Many standard formulas are correct only after choices have been made.

Examples:

- basis;
- axis;
- coordinate chart;
- unit convention;
- gauge;
- domain;
- normalization.

The formula can stay, but the hidden choice should not.

## Why Folland belongs in a hydrogen project

The book is about quantum field theory, but the expository problem is the same one `pauli` faces:

> how do you explain physics to a mathematically literate reader without either flattening the mathematics or drowning the physics?

That is exactly the failure mode of many standard quantum-mechanics and chemistry texts. They often assume enough formal manipulation to proceed but not enough mathematical language to say what the objects are.

Folland demonstrates that the cultural translation itself can be part of the exposition.

## Source status

The AMS book is copyrighted. The author's site provides errata, not an open full-text edition. Google Books and the MAA review provide enough preview material to verify the chapter route and important features of the style, but I did not find an openly licensed full copy appropriate to store in this repository.

Keep links to the lawful previews and use brief source-checked examples rather than copying the book.
