# Videos: angular momentum, spin, and spinors

## Can A Starfox Barrel Roll Work in Space?

PBS Space Time, 18 March 2015, 6m 21s.

PBS:
https://www.pbs.org/video/pbs-space-time-can-starfox-barrel-roll-work-space/

YouTube:
https://www.youtube.com/watch?v=EtExl3sm-1E

### What to watch for

This is the ordinary-mechanics starting point.

The episode introduces angular momentum through spacecraft rotation and flywheels. In particular, it makes visible:

- an angular-momentum direction along the rotation axis;
- transfer of angular momentum between a flywheel and the rest of a spacecraft;
- conservation of total angular momentum;
- why a spacecraft can reorient itself without continuously firing thrusters.

Use this before introducing `l`, `m`, or electron spin.

## Electrons DO NOT Spin

PBS Space Time, 7 July 2021, 14m 05s.

PBS:
https://www.pbs.org/video/electrons-do-not-spin-i249yl/

YouTube:
https://www.youtube.com/watch?v=pWlk1gLkF2Y

### What to watch for

This is the bridge from ordinary angular momentum to intrinsic quantum spin.

The episode explicitly asks what the variable paired with angular momentum is, discusses orientation, and explains that an electron's spin component can be observed as plus or minus one half of `ħ` projected onto whichever direction is measured.

It also emphasizes that electron spin should not be read as literal rotation of a tiny sphere.

## Anti-Matter and Quantum Relativity

PBS Space Time, 21 June 2017.

PBS:
https://www.pbs.org/video/anti-matter-and-quantum-relativity-snezsi/

### What to watch for

This episode is useful after *Electrons DO NOT Spin*.

It explains why Pauli needed an additional two-valued degree of freedom for the electron and describes "up" and "down" as two states associated with the direction of the angular-momentum axis.

The later Dirac story explains why spin belongs naturally in a relativistic quantum description rather than being bolted onto the Schrödinger equation as a classical rotation.

## Spin of an Electron: Why "Spin Up" and "Spin Down"?

Parth G, 10 December 2019.

YouTube:
https://www.youtube.com/watch?v=EfH8XuYbRQ0

### Why keep it

The title asks exactly the vocabulary question that otherwise causes trouble in `pauli`:

> why are the two outcomes called "up" and "down"?

Keep it as a secondary explainer. The repository's own prose should still say explicitly that "up" and "down" are relative to the chosen measurement axis.

## Demonstration of Spin 1/2 for an Electron Wavefunction

YouTube:
https://youtu.be/gTdIvG1FVxc

Author: lloydwatts60.

### Why keep it

This is one of the user's explicit visual references.

It shows a complex wave wrapped around a loop and compares:

- an integer number of phase cycles;
- a spin +1/2 construction with a half-integer number of cycles;
- a spin -1/2 construction with the opposite half-cycle sense;
- the fact that the depicted spin-1/2 construction needs two trips around the loop before returning to the same displayed state.

Keep it as a **visual model of the sign change / double-valued behavior**, not as the derivation or definition of electron spin.

## Dirac's Belt Trick for a Spin 1/2 Particle

YouTube:
https://youtu.be/ICEIgznuHmg

Uploader: Jake Remmert; the description credits Antonio Martos de la Torre for the original Vimeo upload.

### Why keep it

This is another user-supplied visual reference.

The belt trick makes the 360° / 720° distinction tangible:

- a single 360° rotation leaves a twist that cannot be removed while the ends remain constrained;
- after 720°, the twist can be continuously untangled.

Use it as a picture of the topology behind spin-1/2 rotation behavior, not as a picture of a little electron physically spinning.

# Spinors: 360 degrees and 720 degrees

These videos are visually important, but they are **not** introductory explanations of angular momentum.

They belong after the distinction between orbital angular momentum and intrinsic spin.

## Jason Hise — Belt Trick

YouTube:
https://www.youtube.com/watch?v=JaIR-cWk_-o

A compact visual version of the belt / plate trick associated with the double cover of three-dimensional rotations.

## Jason Hise animations

The user previously identified Jason Hise's visual work as material to keep close.

YouTube:

- https://www.youtube.com/watch?v=LLw3BaliDUQ
- https://www.youtube.com/watch?v=6Ul_-ABYaYU
- https://www.youtube.com/watch?v=aYVt1UiERIQ

These are useful because the topology is much easier to see moving than to infer from a static diagram.

Do not describe them as showing an electron literally moving this way. They visualize the rotation/spinor geometry.

## Alexander E. Holroyd — Spinor linkage

YouTube:
https://www.youtube.com/watch?v=oRPCoEq05Zk

Paper:
https://doi.org/10.1080/17513472.2022.2045049

A mechanical implementation of the plate trick. The linkage makes the spinor double-cover behavior into an actual one-degree-of-freedom mechanism.

## Alexander E. Holroyd — LEGO anti-twist mechanism

YouTube:
https://www.youtube.com/watch?v=1x_oQv_qj_U

A particularly useful mechanical visualization because the anti-twist behavior is embodied in a linkage rather than hidden in an abstract quaternion calculation.

## Alexander E. Holroyd — larger spinor linkage

YouTube:
https://www.youtube.com/watch?v=byi5Gzjc04Q

Another view of the same family of mechanisms, useful when the compact linkage is hard to parse.

# What each group answers

```text
Starfox / flywheel
    What is ordinary angular momentum and why is it conserved?

Hydrogen orbital discussion
    What does m measure after I choose an axis?

Electrons DO NOT Spin / Anti-Matter and Quantum Relativity
    What is intrinsic spin and what do up/down mean?

Hise / Holroyd
    Why does spin-½ rotation have 360°/720° spinor behavior?
```

Keeping these questions separate is more useful than putting every video under a generic "quantum spin" heading.
