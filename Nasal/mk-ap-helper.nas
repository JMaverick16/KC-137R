# Lake of Constance Hangar :: M.Kraus
# Avril 2013
# This file is licenced under the terms of the GNU General Public Licence V2 or later
#=======================================================================
# In copilot mode the value of autopilot kill all pilot - copilot action
# so pilot settings better be written to switch boolean values
#=======================================================================

setlistener("/sim/signals/fdm-initialized", func {
      setprop("/autopilot/locks/altitude", "");
      setprop("/autopilot/locks/heading", "");
      setprop("/autopilot/locks/speed", "");
      setprop("/autopilot/switches/ap", 0);
      setprop("/autopilot/switches/hdg", 0);
      setprop("/autopilot/switches/alt", 0);
      setprop("/autopilot/switches/ias", 0);
      setprop("/autopilot/switches/nav", 0);
      setprop("/autopilot/switches/appr", 0);
      setprop("/autopilot/switches/gps", 0);
      setprop("/autopilot/switches/pitch", 0);
});

setlistener("/autopilot/switches/ap", func (ap){
    var ap = ap.getBoolValue();
    if (ap == 1){
      var hdgSet = getprop("/autopilot/switches/hdg");
      var altSet = getprop("/autopilot/switches/alt");
      var iasSet = getprop("/autopilot/switches/ias");
      var navSet = getprop("/autopilot/switches/nav");
      var apprSet = getprop("/autopilot/switches/appr");
      var gpsSet = getprop("/autopilot/switches/gps");
      var pitchSet = getprop("/autopilot/switches/pitch");

      if((!hdgSet and !altSet and !iasSet and !navSet and !apprSet and !gpsSet and !pitchSet)){
        setprop("/autopilot/locks/heading", "wing-leveler");
        setprop("/autopilot/locks/altitude", "pitch-hold");
        setprop("/autopilot/settings/target-pitch-deg", 
                      getprop("/orientation/pitch-deg"));
      }

    }else{
      setprop("/autopilot/locks/altitude", "");
      setprop("/autopilot/locks/heading", "");
      setprop("/autopilot/locks/speed", "");
      setprop("/autopilot/switches/hdg", 0);
      setprop("/autopilot/switches/alt", 0);
      setprop("/autopilot/switches/ias", 0);
      setprop("/autopilot/switches/nav", 0);
      setprop("/autopilot/switches/appr", 0);
      setprop("/autopilot/switches/gps", 0);
      setprop("/autopilot/switches/pitch", 0);
      setprop("/controls/special/flightpath-switch", 0);
      
      #applyTrimWheels(0, 0);
      #applyTrimWheels(0, 1);
      #applyTrimWheels(0, 2);
    }
});

setlistener("/autopilot/switches/hdg", func (hdg){
    var hdg = hdg.getBoolValue();
    if (hdg == 1){
      setprop("/autopilot/switches/ap", 1);
      setprop("/autopilot/switches/nav", 0);
      setprop("/autopilot/switches/gps", 0);
      setprop("/autopilot/locks/heading", "dg-heading-hold");
    }else{
      setprop("/autopilot/locks/heading", "");
    }
});

setlistener("/autopilot/switches/alt", func (alt){
    var alt = alt.getBoolValue();
    if (alt == 1){
      setprop("/autopilot/switches/ap", 1);
      setprop("/autopilot/switches/appr", 0);
      setprop("/autopilot/switches/pitch", 0);
      setprop("/autopilot/locks/altitude", "altitude-hold");
    }else{
      setprop("/autopilot/locks/altitude", "");
    }
});

setlistener("/autopilot/switches/ias", func (ias){
    var ias = ias.getBoolValue();
    if (ias == 1){
      setprop("/autopilot/switches/ap", 1);
      setprop("/autopilot/locks/speed", "speed-with-throttle");
    }else{
      setprop("/autopilot/locks/speed", "");
    }
});

# befor it was pitch, so I use this switch knob called pitch, but now it maps on vertical speed 
setlistener("/autopilot/switches/pitch", func (pitch){
    var pitch = pitch.getBoolValue();
    if (pitch == 1){
      setprop("/autopilot/switches/ap", 1);
      setprop("/autopilot/switches/appr", 0);
      setprop("/autopilot/switches/alt", 0);
      setprop("/autopilot/locks/altitude", "vertical-speed-hold");
    }else{
      setprop("/autopilot/locks/altitude", "");
    }
});

setlistener("/autopilot/switches/gps", func (gps){
    var gps = gps.getBoolValue();
    var routeIsSet = getprop("/autopilot/settings/gps-driving-true-heading") or 0;
    if (gps == 1){
      if (routeIsSet == 1){
        setprop("/autopilot/switches/ap", 1);
        setprop("/autopilot/switches/hdg", 0);
        setprop("/autopilot/switches/nav", 0);
        setprop("/autopilot/locks/heading", "true-heading-hold");
      	setprop("/autopilot/locks/passive-mode", 1);
      }else{
        settimer(switchback, 0.250 );
      }
    }else{
      setprop("/autopilot/locks/heading", "");
      setprop("/autopilot/locks/passive-mode", 0);
    }
});

setlistener("/autopilot/switches/nav", func (nav){
    var nav = nav.getBoolValue();
    if (nav == 1){
      setprop("/autopilot/switches/ap", 1);
      setprop("/autopilot/switches/hdg", 0);
      setprop("/autopilot/switches/gps", 0);
      setprop("/autopilot/locks/heading", "nav1-hold");
      setprop("/controls/special/flightpath-switch", 1);
    }else{
      setprop("/autopilot/locks/heading", "");
      setprop("/controls/special/flightpath-switch", 0);
    }
});

setlistener("/autopilot/switches/appr", func (appr){
    var appr = appr.getBoolValue();
    if (appr == 1){
      setprop("/autopilot/switches/ap", 1);
      setprop("/autopilot/switches/alt", 0);
      setprop("/autopilot/switches/pitch", 0);
      setprop("/autopilot/locks/altitude", "gs1-hold");
      setprop("/controls/special/flightpath-switch", 2);
    }else{
      setprop("/autopilot/locks/altitude", "");
      if(getprop("/autopilot/switches/nav")){
      	setprop("/controls/special/flightpath-switch", 1);
      }else{
      	setprop("/controls/special/flightpath-switch", 0);
     	}
    }
});


# If trim wheels are not on 0 and you click the center of this wheel
var trimBackTime = 1.0;
var applyTrimWheels = func(v, which = 0) {
    if (which == 0) { interpolate("/controls/flight/elevator-trim", v, trimBackTime); }
    if (which == 1) { interpolate("/controls/flight/rudder-trim", v, trimBackTime); }
    if (which == 2) { interpolate("/controls/flight/aileron-trim", v, trimBackTime); }
}

var switchback = func {
  setprop("/autopilot/switches/gps", 0);
}

# if somebody set the property not in cockpit but in the menu, switch must also follow this action
setlistener("/autopilot/locks/heading", func (h){
		var h = h.getValue();
		var s = getprop("/autopilot/switches/ap", 1);
		if (h and !s) setprop("/autopilot/switches/ap", 1);
});

# if somebody set the property at the original Autopilot between Pilot and Copilot, switch must also follow this action
setlistener("/controls/special/flightpath-switch", func (fs){
		var fs = fs.getValue();
		var a  = getprop("/autopilot/switches/ap");
		var na = getprop("/autopilot/switches/nav");
		var ap = getprop("/autopilot/switches/appr");
		
		
		if (a and (na or ap) and !fs){ 
			setprop("/autopilot/switches/nav", 0);
			setprop("/autopilot/switches/appr", 0);
		}
		if (a and !na and fs == 1) setprop("/autopilot/switches/nav", 1);
		if (a and  ap and fs == 1) setprop("/autopilot/switches/appr", 0);
		if (a and !ap and fs == 2) setprop("/autopilot/switches/appr", 1);

});

setlistener("/controls/special/yoke-switch1", func (s1){
    var s1 = s1.getBoolValue();
    if (s1 == 1){
      setprop("/autopilot/switches/ap", 0);
    }
});




