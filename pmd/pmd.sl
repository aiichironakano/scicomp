#!/bin/bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:00:59
#SBATCH --output=pmd.out
#SBATCH -A anakano_81

counter=0
while [ $counter -lt 3 ]; do
  mpirun -n $SLURM_NTASKS ./pmd
  let counter+=1
done
