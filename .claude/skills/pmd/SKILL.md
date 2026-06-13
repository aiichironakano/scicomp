---
name: pmd
description: Build, configure, run, or modify the MPI-based parallel molecular dynamics code in pmd/ (CSCI 596). Use for tasks touching pmd/src/pmd.c, pmd.h, the makefile, pmd.in, pmd.sl, the MPI process decomposition (vproc/nproc), or submitting/interpreting SLURM jobs and pmd.out.
---

# Parallel MD (pmd)

MPI-only domain-decomposed MD code (linked-cell neighbor lists, velocity-Verlet
integration) from the CSCI 596 course.

## Layout
- `pmd/src/pmd.c` - main program
- `pmd/src/pmd.h` - constants, global state, decomposition (`vproc`, `nproc`), input field declarations
- `pmd/src/makefile` - build rule (`mpicc -O -o pmd pmd.c -lm`, then moved to `pmd/`)
- `pmd/pmd.in` - runtime input parameters
- `pmd/pmd.sl` - SLURM batch script
- `pmd/pmd.out` - sample output log
- `pmd/readme.md` - course notes & CARC links

## Build
```
cd pmd/src && make
```
Produces `pmd/pmd`. Requires `module load usc` on USC CARC/Discovery (provides the MPI compiler wrapper).

## Domain decomposition - critical invariant
`pmd.h` declares:
```c
int vproc[3] = {1,1,2}, nproc = 2;
```
- `vproc[0]*vproc[1]*vproc[2] == nproc` must hold.
- `nproc` must equal `$SLURM_NTASKS` in `pmd.sl` (i.e. `--nodes * --ntasks-per-node`).

Changing the decomposition means: edit `vproc`/`nproc` in `pmd.h`, recompile, and update the matching `#SBATCH --nodes` / `--ntasks-per-node` in `pmd.sl`.

## Input file (`pmd.in`)
Six whitespace-separated values, read by `init_params()` via `fscanf`:
1. `InitUcell[0] InitUcell[1] InitUcell[2]` - unit cells per MPI process per dimension (FCC lattice, 4 atoms/cell)
2. `Density` - reduced number density
3. `InitTemp` - initial temperature (reduced units)
4. `DeltaT` - timestep (reduced units)
5. `StepLimit` - number of MD steps
6. `StepAvg` - steps between property reports (`eval_props()` calls)

Total atom count: `nglob = 4 * InitUcell[0]*InitUcell[1]*InitUcell[2] * nproc`.

## Running
```
sbatch pmd.sl
```
Runs `mpirun -n $SLURM_NTASKS ./pmd` (looped 3x in the current script); output goes to `pmd.out`.

## Output (`pmd.out`)
SLURM banner (job id, node list, tmpdir), then per run:
- `al = ...` - box length per process (x y z)
- `lc = ...` - # linked-list cells per process (x y z)
- `rc = ...` - cell size (x y z)
- `nglob = ...` - total atom count
- Every `StepAvg` steps, rank 0 prints: `time  temperature  potEnergy  totEnergy`
- `CPU & COMT = <cpu time> <communication time>` (seconds)

## Reference
Verify current syntax before editing `pmd.sl`:
- https://www.carc.usc.edu/user-guides/hpc-systems/using-our-hpc-systems/running-jobs
- https://www.carc.usc.edu/user-guides/hpc-systems/discovery/getting-started-discovery

## Related
For the MPI+OpenMP hybrid variant, see the `hmd` skill (`hmd/` directory) - same input/output conventions plus an additional OpenMP thread decomposition.
