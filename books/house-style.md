# House style for `pauli`

This file governs exposition in the repository.

The target is not the voice of a generic undergraduate physics or chemistry textbook.

The central references are:

- [Stephanie Frank Singer](stephanie-frank-singer.md): destination-driven exposition; symmetry and linearity predict structure before calculation.
- [Michael Monastyrsky](monastyrsky.md): terse conceptual writing; history and physics used to expose what the mathematics means.
- [Gerald Folland](folland.md): explicit translation between mathematical objects and physicists' working language; mark rigor, convention, approximation, and formal manipulation honestly.
- [Jeremy Gray](jeremy-gray.md): problem and historical obstacle before modern compression; failed methods matter.
- [Jesper Lützen](jesper-lutzen.md): detailed scholarship with visible organization; distinguish historical development from modern reconstruction.
- [William L. Burke](william-l-burke.md): identify the geometric object before coordinate machinery.
- [David Hestenes](hestenes-oersted.md): do not let inherited three-dimensional notation hide the underlying geometric object.

## Primary rule

Start with the **thing, question, pattern, or obstruction**.

Then introduce the mathematics that explains it.

Do not begin with a vocabulary list.

The normal order is:

**concrete object -> question -> structure -> prediction -> representation -> calculation**

not:

**definition -> notation -> formula -> exercise -> explanation later**.

## Singer rule: make the destination visible

The reader should know why a concept is entering.

Hydrogen itself should appear before all of its prerequisites have been completed.

Good questions include:

- Why are there `2l + 1` angular states?
- Why do distinct states share an energy?
- Why do spherical harmonics occur?
- What exactly changes when an orbital is rotated?
- Why does the Coulomb problem have more degeneracy than ordinary rotations explain?
- Why is spin represented differently from orbital angular momentum?

Introduce representation theory, Hilbert spaces, tensor products, or SO(4) when they answer one of these questions.

## Monastyrsky rule: fewer equations can explain more

Do not confuse mathematical seriousness with page density.

If one geometric picture and one equation explain the point, do not add six equations because six equations look more technical.

History belongs where it explains a conceptual move.

A mathematician's name should answer “why did the subject change here?” rather than decorate a formula.

## Folland rule: translate without lying

Physics, chemistry, and mathematics often use different language for the same or closely related structures.

Make the translation explicit.

Examples:

- “p orbitals” ↔ the `l = 1` rotation space;
- “wavefunction” ↔ a coordinate realization of a quantum state;
- “angular momentum operators” ↔ infinitesimal generators of the rotation representation;
- “choose the z-axis” ↔ choose a basis adapted to one generator.

Also mark the status of claims when it matters:

- exact;
- symmetry consequence;
- coordinate choice;
- conventional notation;
- approximation;
- perturbative statement;
- numerical result;
- heuristic picture.

Never create rigor by pretending an approximation is exact.
Never create accessibility by hiding a real mathematical distinction.

## Gray rule: methods have histories because they solved problems

A named method should enter after the need for it.

Do not write:

> We now separate variables.

until the reader has seen what structural split the method is exploiting.

Do not write:

> The solutions are associated Legendre functions.

without saying what regularity/boundary problem selects them and why only certain values are allowed.

When a later theorem repairs an earlier gap, state the gap.

When modern notation compresses fifty years of development into one line, it is often worth unpacking one layer.

## Lützen rule: modern organization is not historical chronology

It is useful to say:

> In modern language this is a self-adjoint spectral problem.

It is not useful to imply that Sturm and Liouville began from modern operator theory.

Keep two views available:

1. how the problem developed;
2. how we organize it now.

The contrast is explanatory.

## Burke/Hestenes rule: preserve the geometric object

A state is not its coefficient list.

A sphere is not a `theta, phi` chart.

A rotation is not its matrix.

An orbital is not its isosurface.

An oriented area is not fundamentally a three-dimensional pseudovector.

A representation is not one chosen set of matrices.

Coordinates, matrices, plots, and conventional vector-calculus aliases are useful representations. Do not let them replace the object in the prose or architecture.

## Specific failure modes to avoid

### Definition-first writing

Bad:

> A representation of a group `G` on a vector space `V` is a homomorphism...

This may be the right formal definition, but it is usually the wrong first sentence.

Better:

> Rotating the atom should move its states without changing the physics. To keep track of how every rotation acts on the state space, we use a representation.

Then state the definition.

### Formula as explanation

Bad:

> The spherical harmonics are
> `Y_l^m(theta, phi) = ...`

Better:

> Rotations preserve finite-dimensional families of angular states. The family labelled by `l` has `2l+1` dimensions. After choosing an axis, the familiar `Y_l^m` are a convenient basis for that space.

Then show the formula.

### Label before object

Bad:

> The magnetic quantum number is `m = -l, ..., l`.

Better:

> Choosing an axis gives a basis inside the `2l+1` dimensional angular-momentum space. The basis states are conventionally labelled by `m=-l,ldots,l`.

### Special function from nowhere

Bad:

> The radial equation is solved by associated Laguerre polynomials.

Better:

> Regularity at the origin and decay at infinity leave only certain radial solutions. After extracting the known endpoint behavior, the remaining polynomial problem is the Laguerre one.

### Hamiltonian as unexplained prestige word

Bad:

> The Hamiltonian is
> `H = ...`

Better:

> Energy determines the time evolution of the quantum state. The operator representing that energy is the Hamiltonian. In position coordinates for hydrogen it has the familiar kinetic-plus-Coulomb differential form.

### Degeneracy as a table fact

Bad:

> These levels are degenerate.

Better:

> Several independent states have the same energy. That repeated energy is evidence of symmetry. Ordinary rotations explain part of the multiplicity; hydrogen's larger hidden symmetry explains more.

### Cross product hiding geometry

Bad:

> Angular momentum is `r × p`.

Better:

> Position and momentum determine an oriented plane, represented directly by `r ∧ p`. In three dimensions its Hodge-dual pseudovector is the familiar cross-product form.

Use the three-dimensional shortcut when useful, but do not let it erase the underlying object.

## Sentence-level style

Prefer concrete nouns and active verbs.

Avoid empty transition language:

- “It is important to note that...”
- “As we can clearly see...”
- “It can be shown that...”
- “We now proceed to...”
- “It is interesting to observe...”

Replace each with the actual fact.

Avoid “obvious,” “trivial,” and “simply” when they are doing social rather than mathematical work.

Do not use impressive terminology when an ordinary word is exact.

Do not repeat a formula in prose unless the prose adds meaning.

## Structure of a good `pauli` page

A strong page often has five parts:

1. **The thing:** show the orbital, spectrum, rotation, nodal set, or physical question.
2. **The puzzle:** state what needs explaining.
3. **The structure:** introduce the symmetry/geometric/spectral idea that answers it.
4. **The prediction:** say what follows before detailed calculation.
5. **The realization:** show the coordinate formula, special function, numerical computation, or rendering.

Not every page needs all five headings. The conceptual order is what matters.

## Examples should accumulate

Prefer one rich running object to a parade of disposable examples.

Hydrogen can successively teach:

- linear state spaces;
- inner products;
- rotations;
- irreducible representations;
- spherical harmonics;
- differential equations;
- spectral theory;
- hidden SO(4) symmetry;
- spin;
- tensor products;
- perturbations and symmetry breaking.

Each return should expose a new structure in the same object.

## Historical material

History should do mathematical work.

Useful historical questions:

- What problem produced this definition?
- What did an earlier method fail to prove?
- What did the original author mean by “solution”?
- When did orthogonality become a general method rather than an isolated identity?
- Which part of the modern story is retrospective?
- What physical problem forced a pure theorem?

If the history answers none of these, it may not belong on the page.

## Final check before merging prose

Before accepting explanatory prose, ask:

- Does the reader know what problem is being solved?
- Is the mathematical object named before one coordinate representation of it?
- Did symmetry make every prediction it can before brute-force calculation begins?
- Did a named special function arrive with a reason?
- Are historical claims separated from modern reinterpretation?
- Are approximations or conventions marked honestly?
- Could two paragraphs be replaced by one geometric sentence?
- Does the prose sound like someone who understands the object, or like a textbook template being filled in?

If the last answer is “textbook template,” rewrite it.
