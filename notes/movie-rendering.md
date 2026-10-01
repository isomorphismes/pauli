# Movie rendering

Pauli movies should use the same small downstream movie boundary as the other
visualizers: Pauli chooses a sequence of mathematical/rendering states, renders
one still for each state, and hands the ordered stills to the generic movie
writer in `tools/movie.py`.

```text
Pauli state at t
    ↓
Pauli renderer
    ↓
RGB24 still
    ↓
tools/movie.py
    ↓
MP4
```

The movie writer must not know what an orbital is.

## What Pauli varies

A movie must state what is changing. These are different operations and should
not be silently collapsed into one generic "rotation" parameter:

- **camera/view orientation** — move the observer around a fixed rendered state;
- **orbital/state rotation** — act on the quantum state by the appropriate
  rotation representation, then render the transformed state;
- **state selection or superposition** — change the coefficients/state being
  visualized;
- **observable or level-set choice** — change which real quantity or isovalue is
  rendered from the state;
- **other explicitly defined physical/model parameters** — only when the
  underlying Pauli model says they vary.

For example, a turntable movie of a fixed (2p_x) orbital should vary the
camera/view orientation and leave the orbital state fixed. A movie intended to
demonstrate the SO(3) action on an orbital should instead vary the state
rotation explicitly. Those pictures can look related, but they represent
different statements.

## Time and sequencing

The sequencer owns time. It may generate states from a trajectory
`state(t)`, from an explicit finite list, or from another well-defined
parameterization. The renderer owns only the mapping

```text
Pauli state + camera/render parameters → still image
```

and `tools/movie.py` owns only

```text
ordered RGB24 stills + width + height + fps → MP4
```

Do not put Pauli state evolution, orbital labels, camera mathematics, or
wavefunction evaluation into the movie writer.

## Current renderers

The current Idriç ray tracer emits a PPM still to standard output. That remains
a useful still-image boundary while the packed-pixel path is developed. The
Android renderer already constructs packed RGB frames internally, but Android
runtime capture and offline movie generation are separate jobs: an offline
movie producer should call a renderer through a host/offscreen boundary rather
than teach the movie writer about Android lifecycle or input.

A future Pauli movie driver can therefore be small:

```text
for each requested state/time:
    choose Pauli state and camera
    render one still
    yield its RGB pixels

write_rgb24_movie(output, frames, width, height, fps)
```

The first movie use case should determine the smallest useful state-sequence
interface. Do not freeze a larger animation API before that.
