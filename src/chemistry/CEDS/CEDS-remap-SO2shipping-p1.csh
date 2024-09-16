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
foreach EXPID (SO2)

set inpfile = $inpdir/CEDS_${EXPID}_anthro_${yyyy}_0.1.nc
set outfile1 = $outdir/$EXPID-em-anthro_CMIP_CEDS_gn_shipping_${yyyy}.nc
set outfile2 = $outdir/SO4-em-anthro_CMIP_CEDS_gn_shipping_${yyyy}.nc
if(-e $inpfile) then
echo $inpfile
echo $outfile1
echo $outfile2
date

if(-e $outfile1)  rm -f $outfile1
if(-e $outfile2)  rm -f $outfile2

ncks -A -v lat,lon,time $inpfile $outfile1
 ncap2 -A -s "${EXPID}_shipping = SHP*0.97" -v $inpfile $outfile1 
 ncatted -O -a long_name,${EXPID}_shipping,o,c,"Emissions of ${EXPID} from shipping sector" $outfile1

ncks -A -v lat,lon,time $inpfile $outfile2
 ncap2 -A -s "SO4_shipping = SHP*0.03*96./64." -v $inpfile $outfile2
 ncatted -O -a long_name,SO4_shipping,o,c,"Emissions of SO4 from shipping sector" $outfile2


endif

end

end



