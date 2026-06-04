#!/usr/bin/env python3
import numpy as np
from calendar import monthrange
import datetime
import matplotlib.pyplot as plt

def read_volc_table(dir="/home/pcolarco/silo/fvInput/sfc/volcano17/volcanic_CARN_1978-2026_v202606",yyyymmdd="19780101"):
    try:
        fname = f"{dir}/so2_volcanic_emissions_Carn.{yyyymmdd}.rc"
        with open(fname) as f:
            data = f.readlines()
    except:
        fname = f"{dir}/so2_volcanic_emissions_Carns.{yyyymmdd}.rc"
        with open(fname) as f:
            data = f.readlines()
    print(fname)
    f.close()

    lat    = []
    lon    = []
    sulfur = []
    elev   = []
    height = []
    startread = False
    for line in data:
        items = line.split()
#       Omit headers
        if(items[0][0] == "#"):
            continue
        if(items[0][0:9] == "volcano::"):
            startread = True
            continue
        if(startread):
            if(items[0][0:2] == "::"):
                # Exit
                lat    = np.array(lat)
                lon    = np.array(lon)
                sulfur = np.array(sulfur)
                height = np.array(height)
                elev   = np.array(elev)
                return lon, lat, sulfur, elev, height
            else:
                # Read line
                lat.append(items[0])
                lon.append(items[1])
                sulfur.append(items[2])
                elev.append(items[3])
                height.append(items[4])
    return

def parse_day(yyyymmdd, dir="/home/pcolarco/silo/fvInput/sfc/volcano17/volcanic_CARN_1978-2026_v202606"):
    # Read a day file and return the total of degassing emissions
    # and the list of individual explosive eruptions
    lon, lat, sulfur, elev, height = read_volc_table(dir=dir,yyyymmdd=yyyymmdd)
    n = len(lat)
    s_degas = 0.
    n_degas = 0
    n_explo = 0
    s_explo = []
    lat_ex = []
    lon_ex = []
    h_ex   = []
    for i in np.arange(0,n):
        # If degassing just sum sulfur
        if(height[i] == elev[i]):
            n_degas += 1
            s_degas += float(sulfur[i])*86400./1.e9  # to Tg day-1
        else:
            n_explo += 1
            s_explo.append(float(sulfur[i])*86400./1.e9)
            lat_ex.append(lat[i])
            lon_ex.append(lon[i])
            h_ex.append(height[i])
    s_explo = np.array(s_explo)
    return n_degas, s_degas, n_explo, s_explo, lat_ex, lon_ex, h_ex


def plot_time(date0, date1, dir="/home/pcolarco/silo/fvInput/sfc/volcano17/volcanic_CARN_1978-2026_v202606",label="volcano17"):
    start = datetime.datetime.strptime(date0, "%Y%m%d")
    end   = datetime.datetime.strptime(date1, "%Y%m%d")
    dates = [start + datetime.timedelta(days=x) for x in range(0, (end-start).days)]
    tyme  = dates
    s_degas = []
    n_explo = []
    s_explo = []
    for date in dates:
        yyyymmdd = date.strftime("%Y%m%d")
        nd, sd, ne, se, late, lone, he = parse_day(yyyymmdd,dir=dir)
        s_degas.append(sd)
        if ne == 0:
            n_explo.append(0)
            s_explo.append(0)
        else:
            n_explo.append(ne)
            s_explo.append(se)
    fig, ax = plt.subplots(1, 1, figsize=(14, 6))
    im = ax.plot(tyme,s_degas)
    nt = len(dates)
    for i in np.arange(0,nt):
        if(n_explo[i] > 0):
            for j in np.arange(0,n_explo[i]):
                plt.plot(tyme[i],s_explo[i][j],marker=".",color="k")
    ax.set_yscale("log")
    ax.set_ylim(1.e-3,100)
    ax.set_ylabel("Daily volcanic emissions [Tg s]")
    plt.savefig(f"{label}.{date0}_{date1}.png")
    return


def sum_month(yyyy, mm, dir="/home/pcolarco/silo/fvInput/sfc/volcano17/volcanic_CARN_1978-2026_v202606"):
    vals = monthrange(yyyy,mm)
    nd = vals[1]
    for dd in np.arange(1,nd+1):
        yyyymmdd = "%04d%02d%02d"%(yyyy,mm,dd)
    return

if __name__ == "__main__":
#    plot_time("19800101","20260501")
#    plot_time("20000101","20260501")
#    plot_time("20000101","20260101",dir="/home/pcolarco/ExtData/chemistry/CARN/v202401/sfc", label="MERRA21C")
    plot_time("20200101","20260501")
    plot_time("20200101","20260101",dir="/home/pcolarco/ExtData/chemistry/CARN/v202401/sfc", label="MERRA21C")
