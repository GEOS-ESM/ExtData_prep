from pathlib import Path
import numpy as np
from dateutil import rrule
from datetime import datetime, timedelta

# convert Simon Carn's volcanic databse in files to be used in GEOS-5
# SC has two files, one for explosive and one for degassing.
# the one for degassing is only from 2005 to 2019. I extend it
# with the 2005-2019 average before (1979-2004) and after (2020-)
#
# This version creates one directory, combining degassing and
# explosive volcanoes in a single directory.

################################################################
# Configuration:
################################################################
explosive_file = './data/MSVOLSO2L4_20240108.txt'
degassing_file = './data/so2_passive_degassing_2005-2019_20210715.txt'
savepath = './volcanic_CARN_1978-2023_v202401/'

################################################################
# Explosive volcanoes
################################################################
with open(explosive_file,'r') as f:
    data = f.readlines()
    f.close()

name = []
lat = []
lon = []
v_alt= []
dayEx = []
type = []
vei = []
p_alt_obs = []
p_alt_est = []
so2 = []
for line in data[1:]:
    #values[8] is VEI
    values = line.split()
    vei1 = int(values[8])
    name.append(values[0])
    lat.append(float(values[1]))
    lon.append(float(values[2]))
    v_alt.append(float(values[3]))
    dayEx.append(int(values[4]+values[5].zfill(2)+values[6].zfill(2)))
    type.append(values[7])
    vei.append(int(values[8]))
    p_alt_obs.append(float(values[9]))
    p_alt_est.append(float(values[10]))
    #transform kt SO2/day into kg S/s
    s = float(values[11])*1e6/2./86400.
    so2.append(s)

################################################################
# Degassing volcanoes
################################################################
with open(degassing_file,'r') as f:
    data = f.readlines()
    f.close()
    nameD = []
    latD = []
    lonD = []
    elevD = []
    annualEmD = []
    for nl,line in enumerate(data[2:-1]):
        values = line.split("\t")
        nameD.append(values[0])
        latD.append(float(values[1]))
        lonD.append(float(values[2]))
        elevD.append(float(values[3]))
        tmp = [float(v) for v in values[4:19]]
        annualEmD.append(tmp)

latD = np.array(latD)
lonD = np.array(lonD)
elevD = np.array(elevD)
#transform ktSO2/year into kgS/sec
EmD = np.array(annualEmD)*1e6/2./31536000. #shape (#volc, timesteps)
#make time average of emissions
avgEmD = np.mean(annualEmD,axis=-1)*1e6/2./31536000. #shape (#volc)

################################################################
# write
################################################################
dStart = datetime(1978,1,1)
dEnd = datetime(2024,1,1)

dayExStr = np.array([str(d) for d in dayEx])
#write out files as Thomas database
Path(savepath).mkdir(exist_ok=True)
for nd,dt in enumerate(rrule.rrule(rrule.DAILY, dtstart=dStart, until=dEnd)):
    dayString = str(dt.year)+str(dt.month).zfill(2)+str(dt.day).zfill(2)
    #find volcanoes on that day
    indexDay = np.where(dayExStr == dayString)
    f = open(savepath+'so2_volcanic_emissions_Carns.'+dayString+'.rc','w')
    if ((dt < datetime(2005,1,1) or (dt >= datetime(2020,1,1)))):
        f.write('###  LAT (-90,90), LON (-180,180), SULFUR [kg S/s], ELEVATION [m], CLOUD_COLUMN_HEIGHT [m]\n')
        f.write('### If elevation=cloud_column_height, emit in layer of elevation\n')
        f.write('### else, emit in top 1/3 of cloud_column_height\n')
        f.write('volcano::\n')
        string = '{:.3f} {:.3f} {:e} {:.0f} {:.0f} {:06.0f} {:06.0f} \n'
        for nv,vv in enumerate(nameD):
            f.write(string.format(latD[nv], lonD[nv], avgEmD[nv], elevD[nv], elevD[nv], 0, 240000))
    else:
        f.write('###  LAT (-90,90), LON (-180,180), SULFUR [kg S/s], ELEVATION [m], CLOUD_COLUMN_HEIGHT [m]\n')
        f.write('### If elevation=cloud_column_height, emit in layer of elevation\n')
        f.write('### else, emit in top 1/3 of cloud_column_height\n')
        f.write('volcano::\n')
        string = '{:.3f} {:.3f} {:e} {:.0f} {:.0f} {:06.0f} {:06.0f} \n'
        for nv,vv in enumerate(nameD):
            f.write(string.format(latD[nv], lonD[nv],EmD[nv,dt.year-2005],elevD[nv], elevD[nv], 0, 240000))
    if (len(indexDay[0]) > 0):
        for v in indexDay[0]:
            print(dayString)
            print('---> found explosive volcanoes')
            print('---> '+name[v])
            #check if there is observed height. If not use estimated
            if (p_alt_obs[v] < 0):
                if (p_alt_est[v] >=0):
                    alt = p_alt_est[v]
                else:
                    print('NO REASONABLE ALTITUDE DEFINED!')
            else:
                alt = p_alt_obs[v]
            string = '{:.3f} {:.3f} {:e} {:.0f} {:.0f} {:06.0f} {:06.0f} \n'
            f.write(string.format(lat[v], lon[v], so2[v], v_alt[v]*1000, alt*1000, 0, 240000))
    f.write('::\n')
    f.close()




