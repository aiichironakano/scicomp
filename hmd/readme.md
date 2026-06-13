# Hybrid MPI+OpenMP parallel molecular dynamics

## Requirement
C compiler, message passing interface (MPI) library, and OpenMP library. The only necessary module is:
module load usc

## Codes

hmd.c: Hybrid parallel molecular dynamics using message passing (MPI) and multithreading (OpenMP)
hmd.h: Header file including the description of input file, hmd.in

## Running jobs

hmd.in: Input file
hmd.sl: Slurm script to run hmd

## Notes

In hmd.h, the equality, vproc[0]*vproc[1]*vproc[2] = nproc, needs be satisfied, where nproc is the number of MPI ranks. In addition, $SLURM_NTASKS in hmd.sl must be equal to nproc. Furthermore, in hmd.h, the equality, vthrd[0]*vthrd[1]*vthrd[2] = nthrd, needs be satisfied, where nthrd is the number of OpenMP threads, which in turn must be equal to cpus-per-task in hmd.sl.

Make sure it's up to date by checking the following URLs:
https://www.carc.usc.edu/user-guides/hpc-systems/using-our-hpc-systems/running-jobs
https://www.carc.usc.edu/user-guides/hpc-systems/discovery/getting-started-discovery
