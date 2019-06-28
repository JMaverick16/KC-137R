# Lake of Constance Hangar :: M.Kraus
# Avril 2013
# This file is licenced under the terms of the GNU General Public Licence V2 or later
# Modified for KC-137R as needed by Joshua Davidson (Octal450)


var agl_radar_control = func {
  #var state = props.globals.getNode("/instrumentation/aglradar/power-btn");
  #if(state.getBoolValue()){
    #print("AGL Radar running ... ok");
    var agl = getprop("/position/altitude-agl-ft") or 0;
    var aglft = agl - 6.02;  # is the position from the Boeing 707 above ground
    var aglm = aglft * 0.3048;
    setprop("/position/gear-agl-ft", aglft);
    setprop("/position/gear-agl-m", aglm);

    settimer(agl_radar_control, 0.01);
  #}
}

agl_radar_control();
