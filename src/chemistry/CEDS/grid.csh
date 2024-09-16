#!/bin/csh
# Regrid the CEDS emissions to a GEOS style grid and shave

  source /discover/nobackup/acollow/geos_aerosols/pcolarco/Krok/v11.5.2/GEOSgcm/@env/g5_modules
  set ncks = $BASEDIR/Linux/bin/ncks
  set ncatted = $BASEDIR/Linux/bin/ncatted

  set indir = '/discover/nobackup/acollow/anthroemissions/CEDS_release-v_2024_07_08/'
  set outdir =  '/discover/nobackup/acollow/anthroemissions/CEDS_release-v_2024_07_08/processed/'

  set varn = (bc_energy \
              bc_nonenergy \
              bc_shipping \
              co \
#              co_energy \
#              co_nonenergy \
#              co_shipping \
              nh3 \
#              nh3_energy \
#              nh3_nonenergy \
#              nh3_shipping \
              oc_energy \
              oc_nonenergy \
              oc_shipping \
              so2_energy \
              so2_nonenergy \
              so2_shipping \
              so4_shipping \
)


  set lname = ("Emissions of BC from energy sector" \
               "Emissions of BC from nonenergy soures, e.g., AGRICULTURE + INDUSTRIAL + TRANSPORT + RESIDENTIAL + SOLVENTS + WASTE" \
               "Emissions of BC from shipping sector" \
               "Emissions of CO from anthrop soures, e.g., AGRICULTURE + INDUSTRIAL + TRANSPORT + RESIDENTIAL + SOLVENTS + WASTE + ENERGY + SHIPPING" \
#               "Emissions of CO from energy sector" \
#               "Emissions of CO from nonenergy soures, e.g., AGRICULTURE + INDUSTRIAL + TRANSPORT + RESIDENTIAL + SOLVENTS + WASTE" \
#               "Emissions of CO from shipping sector" \
               "Emissions of NH3 from anthrop soures, e.g., AGRICULTURE + INDUSTRIAL + TRANSPORT + RESIDENTIAL + SOLVENTS + WASTE + ENERGY + SHIPPING" \
#               "Emissions of NH3 from energy sector" \
#               "Emissions of NH3 from nonenergy soures, e.g., AGRICULTURE + INDUSTRIAL + TRANSPORT + RESIDENTIAL + SOLVENTS + WASTE" \
#               "Emissions of NH3 from shipping sector" \
               "Emissions of OC from energy sector" \
               "Emissions of OC from nonenergy soures, e.g., AGRICULTURE + INDUSTRIAL + TRANSPORT + RESIDENTIAL + SOLVENTS + WASTE" \
               "Emissions of OC from shipping sector" \
               "Emissions of SO2 from energy sector" \
               "Emissions of SO2 from nonenergy soures, e.g., AGRICULTURE + INDUSTRIAL + TRANSPORT + RESIDENTIAL + SOLVENTS + WASTE" \
               "Emissions of SO2 from shipping sector" \
               "Emissions of SO4 from shipping sector" \
)               

  set collect = (   BC-em-anthro_CMIP_CEDS_gn_energy \
                    BC-em-anthro_CMIP_CEDS_gn_nonenergy \
                    BC-em-anthro_CMIP_CEDS_gn_shipping \
                    CO-em-anthro_CMIP_CEDS_gn \
#                    CO-em-anthro_CMIP_CEDS_gn_energy \
#                    CO-em-anthro_CMIP_CEDS_gn_nonenergy \
#                    CO-em-anthro_CMIP_CEDS_gn_shipping \
                    NH3-em-anthro_CMIP_CEDS_gn \
#                    NH3-em-anthro_CMIP_CEDS_gn_energy \
#                    NH3-em-anthro_CMIP_CEDS_gn_nonenergy \
#                    NH3-em-anthro_CMIP_CEDS_gn_shipping \
                    OC-em-anthro_CMIP_CEDS_gn_energy \
                    OC-em-anthro_CMIP_CEDS_gn_nonenergy \
                    OC-em-anthro_CMIP_CEDS_gn_shipping \
                    SO2-em-anthro_CMIP_CEDS_gn_energy \
                    SO2-em-anthro_CMIP_CEDS_gn_nonenergy \
                    SO2-em-anthro_CMIP_CEDS_gn_shipping \
                    SO4-em-anthro_CMIP_CEDS_gn_shipping )


  set yyyy = 1980

  while ($yyyy < 2023)
echo $yyyy
  cat > out.ddf <<EOF
dset out.nc
options template
tdef time 12 linear 12z15jan$yyyy 732hr
EOF


#  foreach n ( 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18)
#  foreach n ( 1 2 3 4 5 6 7 8 9 10 11 12 )
  foreach n ( 1 2 3 4 6 7 8 9 10 11 12 )
  echo $yyyy $indir${collect[$n]}_$yyyy.nc
  /usr/local/other/cdo/1.9.10/bin/cdo setreftime,$yyyy-01-15 $indir${collect[$n]}_$yyyy.nc newtime.nc
  /usr/local/other/cdo/1.9.10/bin/cdo setcalendar,standard newtime.nc newtimeandcal.nc
  /discover/nobackup/projects/gmao/share/dasilva/opengrads/Contents/lats4d.sh -i newtimeandcal.nc -geos0.125a -o out
  /discover/nobackup/projects/gmao/share/dasilva/opengrads/Contents/lats4d.sh -i out.ddf -ftype xdf -o out -shave
  \mv -f out.nc4 $outdir${collect[$n]}.x2304_y1441_t12.$yyyy.nc4
  \rm -f out.nc
  \rm -f newtime.nc
  \rm -f newtimeandcal.nc
  echo  ${collect[$n]}.x2304_y1441_t12.$yyyy.nc4
  echo $varn[$n]
  echo $lname[$n]
  $ncatted -a units,$varn[$n],m,c,'kg m-2 s-1' \
           -a long_name,$varn[$n],m,c,"$lname[$n]" \
           $outdir${collect[$n]}.x2304_y1441_t12.$yyyy.nc4
  end

  @ yyyy = $yyyy + 1

  end

