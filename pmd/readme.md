# Parallel molecular dynamics

## Requirement
C compiler and message passing interface (MPI) library. The only necessary module is:
module load usc

## Codes

pmd.c: Parallel molecular dynamics using MPI
pmd.h: Header file including the description of input file, pmd.in

## Running jobs

pmd.in: Input file
pmd.sl: Slurm script to run pmd

## Notes

In pmd.h, the equality, vproc[0]*vproc[1]*vproc[2] = nproc, needs be satisfied, where nproc is the number of MPI ranks. In addition, $SLURM_NTASKS in pmd.sl must be equal to nproc. 

Make sure it's up to date by checking the following URLs:
https://www.carc.usc.edu/user-guides/hpc-systems/using-our-hpc-systems/running-jobs
https://www.carc.usc.edu/user-guides/hpc-systems/discovery/getting-started-discovery
