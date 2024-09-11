#!/bin/csh

#cd /misc/mcc21/bian/NCO
#set wrkdir = `pwd`
#echo $wrkdir


  set wrsl = p1
  set inpdir = /discover/nobackup/projects/gmao/geos_aerosols/shared/emissions/CEDS_release-v_2024_07_08 
  set outdir = /discover/nobackup/acollow/anthroemissions/CEDS_release-v_2024_07_08
  /bin/mkdir -p $outdir
echo $outdir

foreach yyyy (`seq 1980 1 2022`)
foreach EXPID (NH3 CO)

set inpfile = $inpdir/CEDS_${EXPID}_anthro_${yyyy}_0.1.nc
set outfile1 = $outdir/$EXPID-em-anthro_CMIP_CEDS_gn_${yyyy}.nc

if(-e $inpfile) then
echo $inpfile
echo $outfile1
date

if(-e $outfile1)  rm -f $outfile1

 ncks -A -v lat,lon,time $inpfile $outfile1
 ncap2 -A -s "${EXPID} = AGR+IND+TRA+RCO+SLV+WST+ENE+SHP" -v $inpfile $outfile1 
 ncatted -O -a long_name,${EXPID},o,c,"Emissions of ${EXPID} from anthrop soures, e.g., AGRICULTURE + INDUSTRIAL + TRANSPORT + RESIDENTIAL + SOLVENTS + WASTE + ENERGY + SHIPPING" $outfile1


endif

end

end



