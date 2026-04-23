#!/bin/bash
set -e
#source /etc/profile
#source ~/.bashrc

BASE=/home/riset_2/WRF/otomatisasi_WRFNONDA
IFS_BASE=/scratch/cawofcst_prod/data/ecmwf3
STATE_DIR=${BASE}/state
mkdir -p ${STATE_DIR}

echo "========================================"
echo " AUTO WRF DISCOVERY $(date -u)"
echo "========================================"

run_date=""
run_cycle=""
IFS_DIR=""

# =========================================================
# AUTO DISCOVERY IFS (hari ini & kemarin, prioritas 12 → 00)
# =========================================================
for day_offset in 0 1; do
  check_date=$(date -u -d "-${day_offset} day" +"%Y%m%d")

  for cycle in 12 00; do
    candidate_dir=${IFS_BASE}/${check_date}${cycle}/converted
    if [ -d "$candidate_dir" ] && ls ${candidate_dir}/ecmwf* >/dev/null 2>&1; then
      run_date=$check_date
      run_cycle=$cycle
      IFS_DIR=$candidate_dir
      break 2
    fi
  done
done

if [ -z "$run_cycle" ]; then
  echo "Tidak ada data IFS valid"
  exit 0
fi

RUN_ID=${run_date}${run_cycle}
DONE_FILE=${STATE_DIR}/DONE_${RUN_ID}

if [ -f "${DONE_FILE}" ]; then
  echo "RUN ${RUN_ID} sudah pernah dijalankan, skip"
  exit 0
fi

echo "RUN TERPILIH : ${RUN_ID}"
echo "IFS DIR      : ${IFS_DIR}"

cd ${BASE}

# =========================================================
# CLEAN & UPDATE NAMELIST (ringan → boleh di node ini)
# =========================================================
#./clean_move.sh
#./clean_move.sh
#./update_namelist.sh ${run_date} ${run_cycle}

export IFS_DIR

# =========================
# TIMER
# =========================
start_time=$(date +%s)
./clean_remove.sh
./update_namelist_for_wps.sh ${run_date} ${run_cycle}

#echo "[INFO] Linking GRIB"
./link_grib.csh ${IFS_DIR}/ecmwf* . \
|| { echo "[ERROR] link_grib failed"; exit 1; }

echo "[INFO] Running ungrib.exe"
./ungrib.exe \
|| { echo "[ERROR] ungrib failed"; exit 1; }

echo "[INFO] Running metgrid.exe"
time mpiexec.hydra -np 20 ./metgrid.exe \
|| { echo "[ERROR] metgrid failed"; exit 1; }

echo "[INFO] Running real.exe"
#srun ./real.exe \
#ml load mpi compiler
time mpiexec.hydra -np 20 ./real.exe \
|| { echo "[ERROR] real failed"; exit 1; }

./update_namelist_for_wrf.sh ${run_date} ${run_cycle}

# =========================
# SUBMIT WRF (6 NODE)
# =========================
echo "[INFO] Submitting wrf.sh"
sbatch wrf.sh

end_time=$(date +%s)
duration=$((end_time - start_time))

hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))

echo "========================================"
echo " WPS RUN FINISHED $(date)"
echo " Durasi: ${hours} jam ${minutes} menit ${seconds} detik"
echo "========================================"

touch ${DONE_FILE}
