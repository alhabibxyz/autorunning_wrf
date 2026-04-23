#!/bin/bash
set -e


# =========================================================
# KONFIGURASI PATH
# =========================================================
BASE=/home/riset_2/WRF/otomatisasi_WRFNONDA
STATE_DIR=${BASE}/.state

ARCHIVE_BASE="/scratch/riset_2/output/wrfout/forecast"

echo "========================================"
echo " AUTO WRF ARCHIVING (RUN_ID from wrfout) "
echo "========================================"

# =========================================================
# AMBIL FILE wrfout_d03 TERBARU
# =========================================================
WRFOUT_DIR="${BASE}"

#REMOVE FILE PAST WRF_RUN
rm -rvf PFILE:* FILE:* GRIBFILE.* met_em.d0* geogrid.log.* metgrid.log.* rsl.error.* rsl.out.* WRFND00_*


WRFOUT_FILE=$(ls -1t ${WRFOUT_DIR}/wrfout_d03_* 2>/dev/null | head -n 1)

#if [ -z "$WRFOUT_FILE" ]; then
#  echo "ERROR: Tidak ditemukan file wrfout_d03 di ${WRFOUT_DIR}"
#  exit 1
#fi

WRFOUT_FILE=$(ls wrfout_d03_* 2>/dev/null | tail -n 1)

if [ -z "$WRFOUT_FILE" ]; then
  echo "[INFO] Tidak ada wrfout lama, skip archive"
  exit 0
fi

echo "File wrfout digunakan:"
echo "  ${WRFOUT_FILE}"

# =========================================================
# EKSTRAK TANGGAL & JAM → RUN_ID
# wrfout_d03_YYYY-MM-DD_HH:MM:SS
# =========================================================
FILENAME=$(basename "$WRFOUT_FILE")
#rm -rvf FILE:* PFILE:* GRIBFILE.* met_em.d0* geogrid.log.* metgrid.log.*

DATE_PART=$(echo "$FILENAME" | cut -d'_' -f3)   # YYYY-MM-DD
TIME_PART=$(echo "$FILENAME" | cut -d'_' -f4)   # HH:MM:SS

YYYYMMDD=$(echo "$DATE_PART" | tr -d '-')
HH=$(echo "$TIME_PART" | cut -d':' -f1)

RUN_ID="${YYYYMMDD}${HH}"
DONE_FILE=${STATE_DIR}/DONE_${RUN_ID}

echo "========================================"
echo " RUN_ID TERDETEKSI : ${RUN_ID}"
echo "========================================"

# =========================================================
# SIAPKAN FOLDER ARSIP
# =========================================================
ARCHIVE_DIR="${ARCHIVE_BASE}/${RUN_ID}"
mkdir -p "${ARCHIVE_DIR}"

echo "Target arsip:"
echo "  ${ARCHIVE_DIR}"

# =========================================================
# PINDAHKAN FILE (BUKAN HAPUS)
# =========================================================
#rm -rv FILE:*
#rm -rv PFILE:*
#rm -rv GRIBFILE.*
#rm -rv met_em.d0*
#rm -rv geogrid.log.*
#rm -rv metgrid.log.*


#rm -rvf FILE:* PFILE:* GRIBFILE.* met_em.d0* geogrid.log.* metgrid.log.*

#mv -f FILE:*            "${ARCHIVE_DIR}/" 2>/dev/null || true
#mv -f geo_em.d0*        "${ARCHIVE_DIR}/" 2>/dev/null || true
#mv -f GRIBFILE.*        "${ARCHIVE_DIR}/" 2>/dev/null || true
#mv -f met_em.d0*        "${ARCHIVE_DIR}/" 2>/dev/null || true
mv -f wrfout_d0*        "${ARCHIVE_DIR}/" 2>/dev/null || true
mv -f wrfrst_d0*        "${ARCHIVE_DIR}/" 2>/dev/null || true
#mv -f geogrid.log.*     "${ARCHIVE_DIR}/" 2>/dev/null || true
#mv -f metgrid.log.*     "${ARCHIVE_DIR}/" 2>/dev/null || true
mv -f wrfbdy_d0*        "${ARCHIVE_DIR}/" 2>/dev/null || true
mv -f wrfinput_d0*      "${ARCHIVE_DIR}/" 2>/dev/null || true


echo "========================================"
echo " ARCHIVE SELESAI UNTUK RUN_ID ${RUN_ID}"
echo "========================================"


