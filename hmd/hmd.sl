#!/bin/bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time=00:00:59
#SBATCH --output=hmd.out
#SBATCH -A anakano_81

mpirun -bind-to none -n 2 ./hmd
