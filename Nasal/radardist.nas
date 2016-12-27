### Radar Visibility Calculator

# Jettoo (glazmax) and xiii (Alexis)

# my_maxrange(myaircraft): finds our own aircraft max radar range in a table.
# Returns my_radarcorr in kilometers, should be called from your own aircraft
# radar stuff.

# radis(i, my_radarcorr): find multiplayer[i], its Radar Cross Section (RCS),
# applies factor upon our altitude, shorter radar detection distance (due to air
# turbulence), then factor upon its altitude above ground, and finaly computes if
# it is detectable given our radar range.
# Returns 1 if detectable, 0 if not. Should be called from your own aircraft
# radar stuff too.

var data_path = getprop("/sim/fg-root") ~ "/Aircraft/KC-137R/Nasal/radardist.xml";
var aircraftData = {};
var radarData = [];

mpnode_string = nil;
var cutname   = nil;
var mpnode    = nil;
var mpname_node_string = nil;
var mpname_node = nil;
var mpname    = nil;
var splitname = nil;
var acname    = nil;
var rcs_4r    = nil; 
var radartype = nil; 
var alt_corr  = nil; 
var alt_ac    = nil; 
var agl_corr  = nil; 
var mp_lon    = nil; 
var mp_lat    = nil; 
var pos_elev  = nil; 
var mp_agl    = nil; 
var det_range = nil; 
var act_range = nil;
var max_range = nil;
var radar_range = nil;
var radar_area = nil;
var have_radar = nil;

var FT2M = 0.3048;
var NM2KM = 1.852;

var my_maxrange = func(a) {
  max_range = 0;
  radar_range = 0;
  radar_area = 0;
  acname = aircraftData[a] or 0;
  if ( acname ) {
    have_radar = radarData[acname][4];
    if ( have_radar != "none" and  have_radar != "unknown") {
      radar_area = radarData[acname][7];
      radar_range = radarData[acname][5];
      if ( radar_area > 0 ) { max_range = radar_range / radar_area }
    }
  }
  return( max_range );
}

var get_ecm_type_num = func(a) {
  acname = aircraftData[a] or 0;
  var num = 0;
  if ( acname ) {
    num = radarData[acname][8];
  }
  return( num );
} 

var get_aircraft_name = func( t ) {
  # Get the multiplayer aircraft name.
  mpnode_string = t;
  mpnode =  props.globals.getNode(mpnode_string);
  if ( find("tanker", mpnode_string) > 0 ) {
    cutname = "KC135";
  } else {
    mpname_node_string = mpnode_string ~ "/sim/model/path";
    mpname_node = props.globals.getNode(mpname_node_string);
    if (mpname_node == nil) { return(0) }

    var mpname = mpname_node.getValue();
    if (mpname == nil) { return(0) }

    splitname = split("/", mpname);
    #
    # cutname = splitname[1];
    #
    # **** by 5H1N0B1 05/01/2014
    # Fixed a problem onboard radar happens automatically when you are in range of an mp gamer that uses "OpenRadar"
    #
    cutname = splitname[size(splitname)-1];
    
  }
  return( cutname );
}


var radis = func(t, my_radarcorr) {
  cutname = get_aircraft_name(t);
  # Calculate the rcs detection range,
  # if aircraft is not found in list, 0 (generic) will be used.
  acname = aircraftData[cutname];
  if ( acname == nil ) { acname = 0 }
  rcs_4r = radarData[acname][3];

  # Add a correction factor for altitude, as lower alt means
  # shorter radar distance (due to air turbulence).
  alt_corr = 1;
  alt_ac = mpnode.getNode("position/altitude-ft").getValue();
  if (alt_ac <= 1000) {
    alt_corr = 0.6;
  } elsif ((alt_ac > 1000) and (alt_ac <= 5000)) {
    alt_corr = 0.8;
  }
  # Add a correction factor for altitude AGL. Skip if AI tanker.
  agl_corr = 1;
  if ( find("tanker", t) == 0 ) {
    mp_lon = mpnode.getNode("position/longitude-deg").getValue();
    pos_elev = geo.elevation(mp_lat, mp_lon);
    if (pos_elev != nil) {
      mp_agl = alt_ac - ( pos_elev / FT2M );
      if (mp_agl <= 40) {
        agl_corr = 0.03;
      } elsif ((mp_agl > 40) and (mp_agl <= 80)) {
        agl_corr = 0.07;
      } elsif ((mp_agl > 80) and (mp_agl <= 120)) {
        agl_corr = 0.25;
      } elsif ((mp_agl > 120) and (mp_agl <= 300)) {
        agl_corr = 0.4;
      } elsif ((mp_agl > 300) and (mp_agl <= 600)) {
        agl_corr = 0.7;
      } elsif ((mp_agl > 600) and (mp_agl <= 1000)) {
        agl_corr = 0.85;
      }
    }
  }
  # Calculate the detection distance for this multiplayer.
  det_range = my_radarcorr * rcs_4r * alt_corr * agl_corr / NM2KM;

  # Compare if aircraft is in detection range and return.
  act_range = mpnode.getNode("radar/range-nm").getValue() or 500;
  if (det_range >= act_range) {
    return(1);
  }
  return(0);
}

var radar_horizon = func(our_alt_ft, target_alt_ft) {
  if (our_alt_ft < 0 or our_alt_ft == nil) { our_alt_ft = 0 }
  if (target_alt_ft < 0 or target_alt_ft == nil) { target_alt_ft = 0 }
  return( 2.2 * ( math.sqrt(our_alt_ft * FT2M) + math.sqrt(target_alt_ft * FT2M) ) );
}


var load_data = func {
  # a) converts aircraft model name to lookup (index) number in aircraftData{}.
  # b) appends ordered list of data into radarData[],
  # data is:
  # - acname (the index number)
  # - the first (if several) aircraft model name corresponding to this type,
  # - RCS(m2),
  # - 4th root of RCS,
  # - radar type,
  # - max. radar range(km),
  # - max. radar range target seize(RCS)m2,
  # - 4th root of radar RCS.
  var data_node = props.globals.getNode("instrumentation/radar-performance/data");
  var aircraft_types = data_node.getChildren();
  foreach( var t; aircraft_types ) {
    var index = t.getIndex();
    var aircraft_names = t.getChildren();
    foreach( var n; aircraft_names) {
      if ( n.getName() == "name") {
        aircraftData[n.getValue()] = index;
      }
    }
    var t_list = [
      index,
      t.getNode("name[0]").getValue(),
      t.getNode("rcs-sq-meter").getValue(),
      t.getNode("rcs-4th-root").getValue(),
      t.getNode("radar-type").getValue(),
      t.getNode("max-radar-rng-km").getValue(),
      t.getNode("max-target-sq-meter").getValue(),
      t.getNode("max-target-4th-root").getValue(),
      t.getNode("ecm-type-num").getValue()
    ];
    append(radarData, t_list);
  }
}

var launched = 0;

var init = func {
  if (! launched) {
    print("Initializing Radar Data");
    io.read_properties(data_path, props.globals);
    load_data();
    launched = 1;
  }
}
