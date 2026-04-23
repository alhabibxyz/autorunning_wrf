#!/bin/bash
#SBATCH --job-name=wrfhres_00
#SBATCH --partition=DEV1
#SBATCH --nodes=6
#SBATCH --ntasks-per-node=96
#SBATCH --time=72:00:00
#SBATCH --exclusive
#SBATCH --output=wrfhres00_%j.out
#SBATCH --error=wrfhres_%j.err

source ~/.bashrc
cd /home/riset_2/WRF/otomatisasi_WRFNONDA

#export OMP_NUM_THREADS=1
#export SLURM_CPU_BIND=NONE

set -x

date

which mpiexec
which mpirun

# set -x
env | grep SLURM

ulimit -c unlimited
ulimit -a
##limit memoryuse unlimited
##limit stacksize unlimited

# OpenMP settings
export OMP_NUM_THREADS=1
#export FI_PROVIDER=mlx
#export I_MPI_OFI_PROVIDER=mlx
#export I_MPI_FABRICS=shm:ofi
#export I_MPI_SHM=clx_avx2
#export I_MPI_FALLBACK=0
#export I_MPI_HYDRA_IFACE=ib0
#export I_MPI_HYDRA_PMI_CONNECT=alltoall
#export FI_MLX_TLS=dc,dc_x,shm,self # or replace FI_MLX_TLS by UCX_TLS
#export I_MPI_HYDRA_BRANCH_COUNT=4
#export I_MPI_MALLOC=1
#export I_MPI_SHM_HEAP=1

#export KMP_AFFINITY=verbose # do not use : ,granularity=fine,compact #

# Disable Slurm CPU binding
export SLURM_CPU_BIND=NONE
export WRF_LOG_FLUSH=1


# ===== GRID-BASED PARALLEL CONFIG =====
NPROCX=30
NPROCY=19
NIOT=3
NIOG=2

sed -i "s/nproc_x *=.*/nproc_x = ${NPROCX},/" namelist.input
sed -i "s/nproc_y *=.*/nproc_y = ${NPROCY},/" namelist.input
sed -i "s/nio_tasks_per_group *=.*/nio_tasks_per_group = ${NIOT},/" namelist.input
sed -i "s/nio_groups *=.*/nio_groups = ${NIOG},/" namelist.input

#sed -i "s/nproc_x *=-1,/nproc_x = ${NPROCX},/" namelist.input
#sed -i "s/nproc_y *=-1,/nproc_y = ${NPROCY},/" namelist.input
#sed -i "s/nio_tasks_per_group *=0,/nio_tasks_per_group = ${NIOT},/" namelist.input
#sed -i "s/nio_groups *=1,/nio_groups = ${NIOG},/" namelist.input


nodeset -e $SLURM_NODELIST | tr ' ' '\n' > hostfile.${SLURM_JOBID}

TOTAL_MPI=$((6*96))

echo "[CHECK] MPI tasks     = ${SLURM_NTASKS}"
echo "[CHECK] Compute tasks = $((NPROCX * NPROCY))"
echo "[CHECK] IO tasks      = $((NIOT * NIOG))"

#srun ./wrf.exe
# =========================
# TIMER
# =========================
start_time=$(date +%s)

time mpiexec.hydra -bootstrap slurm -np ${TOTAL_MPI} -ppn 96 -hostfile hostfile.${SLURM_JOBID} ./wrf.exe

end_time=$(date +%s)
duration=$((end_time - start_time))

hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))

echo "========================================"
echo " WRF RUN FINISHED $(date)"
echo " Durasi: ${hours} jam ${minutes} menit ${seconds} detik"
echo "========================================"

