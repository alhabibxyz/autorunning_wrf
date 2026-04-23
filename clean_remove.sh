#!/bin/bash
echo "Cleaning large intermediate files..."

rm -f FILE:*
#rm -f geo_em.d0*
rm -f GRIBFILE.*
rm -f met_em.d0*
rm -f wrfout_d0*
rm -f wrfrst_d0*
rm -f geogrid.log.*
rm -f metgrid.log.*
