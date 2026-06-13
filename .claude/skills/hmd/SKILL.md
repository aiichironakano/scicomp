---
name: hmd
description: Build, configure, run, or modify the hybrid MPI+OpenMP parallel molecular dynamics code in hmd/ (CSCI 596). Use for tasks touching hmd/src/hmd.c, hmd.h, the makefile, hmd.in, hmd.sl, the MPI process and OpenMP thread decomposition (vproc/nproc, vthrd/nthrd), or submitting/interpreting SLURM jobs and hmd.out.
---

# Hybrid MPI+OpenMP MD (hmd)

MPI-domain-decomposed MD code where each MPI rank further subdivides its
domain across OpenMP threads (linked-cell neighbor lists, velocity-Verlet
integration). CSCI 596 course material.

## Layout
- `hmd/src/hmd.c` - main program
- `hmd/src/hmd.h` - constants, global state, decomposition (`vproc`/`nproc`, `vthrd`/`nthrd`), input field declarations
- `hmd/src/makefile` - build rule (`mpicc -O -o hmd hmd.c -fopenmp -lm`, then moved to `hmd/`)
- `hmd/hmd.in` - runtime input parameters
- `hmd/hmd.sl` - SLURM batch script
- `hmd/hmd.out` - sample output log
- `hmd/readme.md` - course notes & CARC links

## Build
```
cd hmd/src && make
```
Produces `hmd/hmd`. Requires `module load usc` on USC CARC/Discovery (provides the MPI compiler wrapper with OpenMP support).

## Decomposition - two independent invariants
`hmd.h` declares:
```c
int vproc[3] = {1,1,2}, nproc = 2;
int vthrd[3] = {2,2,1}, nthrd = 4;
```
1. `vproc[0]*vproc[1]*vproc[2] == nproc`, and `nproc` must equal `$SLURM_NTASKS` in `hmd.sl` (`--nodes * --ntasks-per-node`).
2. `vthrd[0]*vthrd[1]*vthrd[2] == nthrd`, and `nthrd` must equal `--cpus-per-task` in `hmd.sl` (OpenMP threads per MPI rank).

Changing either decomposition means: edit `vproc`/`nproc` and/or `vthrd`/`nthrd` in `hmd.h`, recompile, and update the matching `#SBATCH` directives in `hmd.sl`.

## Input file (`hmd.in`)
Same 6-value format as `pmd.in`, read by `init_params()` via `fscanf`:
1. `InitUcell[0] InitUcell[1] InitUcell[2]` - unit cells per MPI process per dimension (FCC lattice, 4 atoms/cell)
2. `Density` - reduced number density
3. `InitTemp` - initial temperature (reduced units)
4. `DeltaT` - timestep (reduced units)
5. `StepLimit` - number of MD steps
6. `StepAvg` - steps between property reports (`eval_props()` calls)

Total atom count: `nglob = 4 * InitUcell[0]*InitUcell[1]*InitUcell[2] * nproc`.

## Running
```
sbatch hmd.sl
```
Runs `mpirun -bind-to none -n <nproc> ./hmd`; output goes to `hmd.out`. `-bind-to none` lets each MPI rank's OpenMP threads spread across its `cpus-per-task`.

## Output (`hmd.out`)
SLURM banner (job id, node list, tmpdir), then:
- `al = ...` - box length per process (x y z)
- `lc = ...` - # linked-list cells per process (x y z)
- `rc = ...` - cell size (x y z)
- `thbk = ...` - # linked-list cells per OpenMP thread block (x y z) - hybrid-specific
- `nglob = ...` - total atom count
- Every `StepAvg` steps, rank 0 prints: `time  temperature  potEnergy  totEnergy`
- `CPU & COMT = <cpu time> <communication time>` (seconds)

## Reference
Verify current syntax before editing `hmd.sl`:
- https://www.carc.usc.edu/user-guides/hpc-systems/using-our-hpc-systems/running-jobs
- https://www.carc.usc.edu/user-guides/hpc-systems/discovery/getting-started-discovery

## Related
For the MPI-only variant, see the `pmd` skill (`pmd/` directory) - same input/output conventions, minus the OpenMP thread decomposition (`vthrd`/`nthrd`/`cpus-per-task`).
