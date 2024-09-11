#!/bin/csh

#cd /misc/mcc21/bian/NCO
#set wrkdir = `pwd`
#echo $wrkdir


  set wrsl = p1
  set inpdir = /discover/nobackup/projects/gmao/geos_aerosols/shared/emissions/CEDS_release-v_2024_07_08 
  set outdir = /discover/nobackup/acollow/anthroemissions/CEDS_release-v_2024_07_08
  /bin/mkdir -p $outdir
echo $outdir

foreach yyyy (`seq 2005 1 2022`)
foreach EXPID (SO2)

set inpfile = $inpdir/CEDS_${EXPID}_anthro_${yyyy}_0.1.nc
set outfile1 = $outdir/$EXPID-em-anthro_CMIP_CEDS_gn_nonenergy_${yyyy}.nc
set outfile2 = $outdir/$EXPID-em-anthro_CMIP_CEDS_gn_energy_${yyyy}.nc
if(-e $inpfile) then
echo $inpfile
echo $outfile1
echo $outfile2
date

if(-e $outfile1)  rm -f $outfile1
if(-e $outfile2)  rm -f $outfile2


ncks -A -v lat,lon,time $inpfile $outfile1
 ncap2 -A -s "${EXPID}_nonenergy = AGR+IND+TRA+RCO+SLV+WST" -v $inpfile $outfile1 
 ncatted -O -a long_name,${EXPID}_nonenergy,o,c,"Emissions of ${EXPID} from nonenergy soures, e.g., AGRICULTURE + INDUSTRIAL + TRANSPORT + RESIDENTIAL + SOLVENTS + WASTE" $outfile1

ncks -A -v lat,lon,time $inpfile $outfile2
 ncap2 -A -s "${EXPID}_energy = ENE" -v $inpfile $outfile2
 ncatted -O -a long_name,${EXPID}_energy,o,c,"Emissions of ${EXPID} from energy sector" $outfile2


endif

end

end



