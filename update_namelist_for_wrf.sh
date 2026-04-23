#!/bin/bash
set -e

RUN_DATE=$1
RUN_CYCLE=$2
RUN_HOURS=84
BASE=/home/riset_2/WRF/otomatisasi_WRFNONDA

YYYY=${RUN_DATE:0:4}
MM=${RUN_DATE:4:2}
DD=${RUN_DATE:6:2}
HH=${RUN_CYCLE}

# ================================
# START DATE (ISO, GNU/BusyBox safe)
# ================================
START_ISO="${YYYY}-${MM}-${DD} ${HH}:00:00"

START_EPOCH=$(date -u -d "${START_ISO}" +%s)
FCST_SEC=$((RUN_HOURS * 3600))
END_EPOCH=$((START_EPOCH + FCST_SEC))
END_ISO=$(date -u -d "@${END_EPOCH}" +"%Y-%m-%d %H:%M:%S")

echo "[INFO] START_DATE = ${START_ISO}"
echo "[INFO] END_DATE   = ${END_ISO}"

# ================================
# FORMAT KHUSUS WPS (WAJIB)
# ================================
START_WPS="${START_ISO/ /_}"
END_WPS="${END_ISO/ /_}"

# ================================
# COPY TEMPLATE
# ================================
cp namelist.wps.template namelist.wps
cp namelist.input.template namelist.input

# ================================
# UPDATE namelist.wps
# ================================
sed -i \
 -e "s|__START__|${START_WPS}|g" \
 -e "s|__END__|${END_WPS}|g" \
 namelist.wps

# ================================
# TIME CONTROL (WRF)
# ================================
SY=${YYYY}; SM=${MM}; SD=${DD}; SH=${HH}

EY=$(date -u -d "${END_ISO}" +%Y)
EM=$(date -u -d "${END_ISO}" +%m)
ED=$(date -u -d "${END_ISO}" +%d)
EH=$(date -u -d "${END_ISO}" +%H)

# ================================
# PARALLEL CONFIG
# ================================
NPX=30
NPY=19
NIOT=3
NIOG=2

sed -i \
 -e "s/__SY__/${SY}/g" \
 -e "s/__SM__/${SM}/g" \
 -e "s/__SD__/${SD}/g" \
 -e "s/__SH__/${SH}/g" \
 -e "s/__EY__/${EY}/g" \
 -e "s/__EM__/${EM}/g" \
 -e "s/__ED__/${ED}/g" \
 -e "s/__EH__/${EH}/g" \
 -e "s/__RUNH__/${RUN_HOURS}/g" \
 -e "s/__NPX__/${NPX}/g" \
 -e "s/__NPY__/${NPY}/g" \
 -e "s/__NIOT__/${NIOT}/g" \
 -e "s/__NIOG__/${NIOG}/g" \
 namelist.input

