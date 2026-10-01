# Agent instructions

## Movie assembly

For generated Pauli movies, this repository owns the physical/mathematical state
trajectory, camera trajectory, observable/level-set choices, and still
rendering. Write a numbered still sequence beginning at frame zero, such as
`frame-000000.png` or `frame-000000.ppm`.

Use `isomorphisms/kitchen/tasks/movie-from-stills/build.sh` to assemble those stills into MP4. Do not add or copy a
project-local `movie.py`, raw-RGB-to-FFmpeg wrapper, or custom movie encoder.
If movie assembly needs another ordinary media feature, change and test the
canonical Kitchen task instead.

Keeping the still sequence, the finished movie, or both in this repository is
allowed according to the artifact being documented. The distinction between
camera/view motion and an SO(3) action on the orbital state remains Pauli's
responsibility; Kitchen knows only the numbered stills, frame rate, and optional
audio.
