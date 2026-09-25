# Bob Coecke and Aleks Kissinger — *Picturing Quantum Processes*

Full title: *Picturing Quantum Processes: A First Course in Quantum Theory and Diagrammatic Reasoning*.

Cambridge University Press, 2017.

Canonical source:

https://www.cambridge.org/core/books/picturing-quantum-processes/1119568B3101F3A685BE832FEEC53E52

This is the book usually referred to in our discussions as **the spiders book**.

It belongs in the main `pauli` references because it takes diagrams seriously as mathematical notation rather than treating pictures as informal illustrations added after the algebra.

## Why it belongs here

The book's chapter route is unusually relevant:

1. Introduction
2. Guide to Reading This Textbook
3. Processes as Diagrams
4. String Diagrams
5. Hilbert Space from Diagrams
6. Quantum Processes
7. Quantum Measurement
8. Picturing Classical-Quantum Processes
9. Picturing Phases and Complementarity
10. Quantum Theory: The Full Picture
11. Quantum Foundations
12. Quantum Computation
13. Quantum Resources
14. Quantomatic

The important move is visible very early:

> composition can be drawn.

A diagram is not merely a cartoon of an equation. Its topology can encode which processes are connected, which systems are inputs and outputs, and how compositions factor.

For `pauli`, this suggests a strong visual standard:

- if a relationship is fundamentally compositional, try to show the composition;
- if an index contraction is fundamentally connectivity, try to show connectivity;
- if a transformation acts on one part of a compound object, make that locality visible;
- if two algebraic expressions are equal because of a structural deformation, show the deformation rather than making the reader chase indices.

## Spiders

The “spiders” are compact graphical nodes representing families of related maps with multiple inputs and outputs.

Their exact ZX-calculus role is not the important point for this repository.

What matters is the representational idea:

> many algebraic facts that look complicated in indexed notation become obvious when the wiring is visible.

`pauli` should borrow that habit without turning itself into a ZX-calculus course.

Useful applications include:

- tensor products;
- contractions;
- change of basis;
- decomposition and recombination of angular-momentum spaces;
- coupling orbital and spin degrees of freedom;
- showing which parts of a state transform together;
- making projection and decomposition operations visible.

## Processes before coordinates

Coecke and Kissinger organize quantum theory around processes and their composition.

That supports several existing house rules:

- a state is not its coordinate list;
- an operator is not its matrix;
- a tensor is not an array of components;
- a composite process is not fundamentally a nested formula.

Coordinates remain useful, but they are one realization of a compositional structure that can often be seen more directly.

## Diagrams should compute, not decorate

A useful `pauli` diagram should carry mathematical information.

Bad use of a picture:

> draw a decorative atom next to a tensor equation.

Better use:

> draw the actual decomposition or contraction represented by the tensor equation, so that changing the diagram changes the mathematics.

Birdtracks and spider diagrams are especially valuable because the pictures participate in the calculation.

## Relation to Birdtracks

Coecke/Kissinger spiders and Cvitanović's birdtracks come from different mathematical traditions, but they share an important discipline:

**wires, vertices, and connectivity should mean something exact.**

See [Predrag Cvitanović](predrag-cvitanovic.md).

Birdtracks are especially good for invariant tensors, group representations, and projection operators. The Coecke/Kissinger language is especially good for compositional quantum processes.

`pauli` does not need to collapse them into one formalism. It should learn from both.

## House use

Consult this book when a page is becoming index-heavy or when a transformation is easier to understand as composition than as a formula.

Before accepting a large tensor expression, ask:

- What are the inputs?
- What are the outputs?
- Which pieces are being composed?
- Which indices represent genuine geometric structure and which merely record a chosen basis?
- Could the equality be understood by moving or reconnecting parts of a diagram?

If the answer is yes, draw it.

## Source status

The Cambridge book is copyrighted. Cambridge exposes the table of contents and chapter previews. Keep the canonical link rather than copying the text into the repository.
