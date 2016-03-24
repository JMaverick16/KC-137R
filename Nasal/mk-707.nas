# Lake of Constance Hangar :: M.Kraus
# Avril 2013
# This file is licenced under the terms of the GNU General Public Licence V2 or later

############################ init ENGINE START AIR PRESSURE ##################################
# used in the autostarts.nas  var starter()
var stAirRight = props.globals.initNode("b707/start-air-bottle-press[0]",2810,"DOUBLE");
var stAirLeft  = props.globals.initNode("b707/start-air-bottle-press[1]",2960,"DOUBLE");

var oT1 = props.globals.initNode("b707/oil/oil-temp[0]",0,"DOUBLE");
var oT2 = props.globals.initNode("b707/oil/oil-temp[1]",0,"DOUBLE");
var oT3 = props.globals.initNode("b707/oil/oil-temp[2]",0,"DOUBLE");
var oT4 = props.globals.initNode("b707/oil/oil-temp[3]",0,"DOUBLE");

var oil1 = props.globals.initNode("b707/oil/quantity[0]",6400,"DOUBLE");
var oil2 = props.globals.initNode("b707/oil/quantity[1]",6400,"DOUBLE");
var oil3 = props.globals.initNode("b707/oil/quantity[2]",6400,"DOUBLE");
var oil4 = props.globals.initNode("b707/oil/quantity[3]",6400,"DOUBLE");

var acc = props.globals.initNode("/b707/air-conditioning/air-cond-unit-cover",0,"DOUBLE");
var comrpm1 = props.globals.initNode("/b707/air-conditioning/compressor-rpm[0]",0,"DOUBLE");
var comrpm2 = props.globals.initNode("/b707/air-conditioning/compressor-rpm[1]",0,"DOUBLE");
var comrpm3 = props.globals.initNode("/b707/air-conditioning/compressor-rpm[2]",0,"DOUBLE");

var inchWater = props.globals.initNode("/b707/air-conditioning/inches-water",11.7,"DOUBLE");

var windowHeatAlphaCapt = props.globals.initNode("/b707/anti-ice/window-alpha-capt",1.0,"DOUBLE");
var windowHeatAlphaFO = props.globals.initNode("/b707/anti-ice/window-alpha-fo",1.0,"DOUBLE");

var lastTrimValue  = props.globals.initNode("/b707/trim/last-elev-trim-turn", 0,"DOUBLE");

var airplaneCrashed  = props.globals.initNode("/b707/crashed", 0,"BOOL");

################################ Reverser ####################################

var togglereverser = func {
	r1 = "/fdm/jsbsim/propulsion/engine";
	r2 = "/fdm/jsbsim/propulsion/engine[1]";
	r3 = "/fdm/jsbsim/propulsion/engine[2]";
	r4 = "/fdm/jsbsim/propulsion/engine[3]";

	rc1 = "/controls/engines/engine";
	rc2 = "/controls/engines/engine[1]";
	rc3 = "/controls/engines/engine[2]";
	rc4 = "/controls/engines/engine[3]"; 

	r5 = "/sim/input/selected";

	rv1 = "/engines/engine/reverser-pos-norm"; 
	rv2 = "/engines/engine[1]/reverser-pos-norm";
	rv3 = "/engines/engine[2]/reverser-pos-norm"; 
	rv4 = "/engines/engine[3]/reverser-pos-norm"; 

	val1 = getprop(rv1) or 0;
	
	t1 = getprop("/controls/engines/engine[0]/throttle") or 0;

	if ((val1 == 0 or val1 == nil) and t1 < 0.25) {
		interpolate(rv1, 1.0, 1.4); 
		interpolate(rv2, 1.0, 1.4);
		interpolate(rv3, 1.0, 1.4); 
		interpolate(rv4, 1.0, 1.4);   
		setprop(r1,"reverser-angle-rad",2);
		setprop(r2,"reverser-angle-rad",2);   
		setprop(r3,"reverser-angle-rad",2);
		setprop(r4,"reverser-angle-rad",2);
		setprop(rc1,"reverser", "true");
		setprop(rc2,"reverser", "true");
		setprop(rc3,"reverser", "true");
		setprop(rc4,"reverser", "true");
		setprop(r5,"engine", "true");
		setprop(r5,"engine[1]", "true");
		setprop(r5,"engine[2]", "true");
		setprop(r5,"engine[3]", "true");
	} else {
		if (val1 == 1.0 and t1 == 0){
		interpolate(rv1, 0.0, 1.4);
		interpolate(rv2, 0.0, 1.4); 
		interpolate(rv3, 0.0, 1.4);
		interpolate(rv4, 0.0, 1.4);  
		setprop(r1,"reverser-angle-rad",0);
		setprop(r2,"reverser-angle-rad",0); 
		setprop(r3,"reverser-angle-rad",0);
		setprop(r4,"reverser-angle-rad",0);
		setprop(rc1,"reverser",0);
		setprop(rc2,"reverser",0);
		setprop(rc3,"reverser",0);
		setprop(rc4,"reverser",0);
		setprop(r5,"engine", "true");
		setprop(r5,"engine[1]", "true");
		setprop(r5,"engine[2]", "true");
		setprop(r5,"engine[3]", "true");
		}
	}
}

var toggleLandingLights = func {

  if(!getprop("/controls/lighting/switches/landing-light")){
  	setprop("/controls/lighting/switches/landing-light",1); 
  }else{
		setprop("/controls/lighting/switches/landing-light",0);  
  }

  if(!getprop("/controls/lighting/switches/landing-light[1]")){
  	setprop("/controls/lighting/switches/landing-light[1]",1); 
  }else{
		setprop("/controls/lighting/switches/landing-light[1]",0);  
  }

  if(!getprop("/controls/lighting/switches/landing-light[2]")){
  	setprop("/controls/lighting/switches/landing-light[2]",1); 
  }else{
		setprop("/controls/lighting/switches/landing-light[2]",0);  
  }
  
  if(!getprop("/controls/lighting/switches/landing-light[3]")){
  	setprop("/controls/lighting/switches/landing-light[3]",1); 
  }else{
		setprop("/controls/lighting/switches/landing-light[3]",0);  
  }
}

################## Little Help Window on bottom of screen #################
var help_win = screen.window.new( 0, 0, 1, 5 );
help_win.fg = [1,1,1,1];

var messenger = func{
help_win.write(arg[0]);
}
print("Help infosystem started");

var h_altimeter = func {
	var press_inhg = getprop("/instrumentation/altimeter/setting-inhg");
	var press_qnh = getprop("/instrumentation/altimeter/setting-hpa");
	if(  press_inhg == nil ) press_inhg = 0.0;
	if(  press_qnh == nil ) press_qnh = 0.0;
	help_win.write(sprintf("Baro alt pressure: %.0f hpa %.2f inhg ", press_qnh, press_inhg) );
}

var h_heading = func {
	var press_hdg = getprop("/autopilot/settings/heading-bug-deg");
	if(  press_hdg == nil ) press_hdg = 0.0;
	help_win.write(sprintf("Heading bug: %.0f ", press_hdg) );
}

var h_course = func {
	var press_course = getprop("/instrumentation/nav/radials/selected-deg");
	if(  press_course == nil ) press_course = 0.0;
	help_win.write(sprintf("Selected course is: %.0f ", press_course) );
}

var h_course_two = func {
	var press_course_two = getprop("/instrumentation/nav[1]/radials/selected-deg");
	if(  press_course_two == nil ) press_course_two = 0.0;
	help_win.write(sprintf("Selected course on copilot HSI is: %.0f ", press_course_two) );
}

var h_tas = func {
	var press_tas = getprop("/autopilot/settings/target-speed-kt");
	if(  press_tas == nil ) press_tas = 0.0;
	help_win.write(sprintf("Target speed: %.0f ", press_tas) );
}

var h_vs = func {
	var press_vs = getprop("/autopilot/settings/vertical-speed-fpm");
	if(  press_vs == nil ) press_vs = 0.0;
	help_win.write(sprintf("Vertical speed: %.0f ", press_vs) );
}

var h_mis = func {
	var press_mis = getprop("/instrumentation/rmi/face-offset");
	if(  press_mis == nil ) press_mis = 0.0;
	help_win.write(sprintf("%.0f degrees", press_mis) );
}

var h_set_target_alt = func{
	var set_alt = getprop("/autopilot/settings/target-altitude-ft");
	if(  set_alt == nil ) set_alt = 0.0;
	help_win.write(sprintf("Target altitude: %.0f ", set_alt) );

}

setlistener( "/instrumentation/aglradar/alt-offset-ft", func(v){
	var v = v.getValue() or 0;
	help_win.write(sprintf("Preselected offset altitude: %.0f ft", v) );
},0,1);

setlistener( "/instrumentation/altimeter/setting-inhg", h_altimeter );
setlistener( "/autopilot/settings/heading-bug-deg", h_heading );
setlistener( "/instrumentation/nav/radials/selected-deg", h_course );
setlistener( "/instrumentation/nav[1]/radials/selected-deg", h_course_two );
setlistener( "/autopilot/settings/target-speed-kt", h_tas );
setlistener( "/autopilot/settings/vertical-speed-fpm", h_vs);
setlistener( "/autopilot/settings/target-altitude-ft", h_set_target_alt );
setlistener( "/instrumentation/rmi/face-offset", h_mis);


var show_alti = func {
	var press_inhg = getprop("/instrumentation/altimeter/setting-inhg");
	if(  press_inhg == nil ) press_inhg = 0.0;
	var alt_ft = getprop("/instrumentation/aglradar/alt-ft");
	if(  alt_ft == nil ) alt_ft = 0.0;
	var alt_on = getprop("/instrumentation/aglradar/power-btn");
	if(  alt_on == nil ) alt_on = 0;	
  var s_alti = getprop("/instrumentation/altimeter/indicated-altitude-ft") or 0;
  if(alt_on){
  	help_win.write(sprintf("With %.2f inhg the actual altitude is: %.0f ft. AGL is %.0f ft", press_inhg, s_alti, alt_ft) );
  }else{
   	help_win.write(sprintf("With %.2f inhg the actual altitude is: %.0f ft. Groundradar is off.", press_inhg, s_alti, alt_ft) ); 
  }
}

var show_lat_lon = func {
	var lat = getprop("/position/latitude-string");
	var lon = getprop("/position/longitude-string");
	var mv = getprop("/environment/magnetic-variation-deg") or 0;
	var f1 = getprop("/instrumentation/compass-control[0]/lat-knob") or 0;
	var f2 = getprop("/instrumentation/compass-control[1]/lat-knob") or 0;
	f1 = (!f1)? 1 : -1;
	f2 = (!f2)? 1 : -1;
	var dgc1 = getprop("/instrumentation/compass-control[0]/lat-turn") or 0;
	var dgc2 = getprop("/instrumentation/compass-control[1]/lat-turn") or 0;
	dgc1 = dgc1*f1;
	dgc2 = dgc2*f2;
	mv = int(mv);
	help_win.write(sprintf("lat: "~lat~" lon: "~lon~" / Magnetic variation is "~mv~" / Compass Controller 1 lat: "~dgc1~" / Compass Controller 2 lat: "~dgc2)); 
}

var show_tat = func {
	var tat = getprop("/b707/anti-ice/total-air-temperature");
	help_win.write(sprintf("Total-Air-Temperature: %.2f Celsius", tat)); 
}

var show_dme = func {
  var dme = getprop("/controls/switches/dme") or 0;
  var tacan_miles = getprop("/instrumentation/tacan/indicated-distance-nm") or 0;
  var dme_miles1 = getprop("/instrumentation/dme/indicated-distance-nm") or 0;
  var dme_miles2 = getprop("/instrumentation/dme[1]/indicated-distance-nm") or 0;

  var decToString = func(x){
    var d = int(math.mod((x*100),100));

    return (int(x)~"."~d);  
  }

  if (dme == 2){
    var x = decToString(tacan_miles);
    var freq = getprop("/instrumentation/tacan/frequencies/selected-channel") or 0;
    var frex = getprop("/instrumentation/tacan/frequencies/selected-channel[4]");
    help_win.write(sprintf("Distance to TACAN \""~freq ~ frex~"\" %.2f nm", x) );
  }
  
  if (dme == 1){
    var x = decToString(dme_miles2);
    var id = getprop("/instrumentation/nav[1]/nav-id") or 0.0;
    help_win.write(sprintf("Distance to VOR-DME \""~id~"\" %.2f nm", x) );
  }

  if (!dme){
    var x = decToString(dme_miles1);
    var id = getprop("/instrumentation/nav/nav-id") or 0.0;             
    help_win.write(sprintf("Distance to VOR-DME \""~id~"\" %.2f nm", x) );
  }
}

var show_tacan = func {
	var tacan_freq = getprop("/instrumentation/tacan/display/channel");
	help_win.write("Tacan: "~tacan_freq); 
}

var show_tacan_dme = func {
    var tacan_miles = getprop("/instrumentation/tacan/indicated-distance-nm") or 0;
    var tacan_in_range = getprop("/instrumentation/tacan/in-range") or 0;
    var tacan_is_on = getprop("/instrumentation/tacan/switch-position") or 0;

    var decToString = func(x){
      var d = int(math.mod((x*100),100));

      return (int(x)~"."~d);  
    }

      var x = decToString(tacan_miles);
      var freq = getprop("/instrumentation/tacan/frequencies/selected-channel") or 0;
      var frex = getprop("/instrumentation/tacan/frequencies/selected-channel[4]");
	  if(tacan_is_on){
		  if(tacan_in_range){
		     help_win.write("Distance to TACAN \""~freq ~ frex~"\" " ~ x ~" nm");
		  }else{
		     help_win.write("TACAN \""~freq ~ frex~"\" not in range!");
		  }
      }else{
     	help_win.write("Switch on TACAN first and select an active frequency!");
	  }
}

var show_fuel_consumption = func {
  var engineType = getprop("sim/multiplay/generic/int[8]") or 0;
	var used = getprop("/b707/fuel/fuel-per-hour-lbs") or 0;
	var fueltotal = getprop("/consumables/fuel/total-fuel-lbs") or 0;
	var kg = (!engineType) ? used * 0.45359237 : ((used * 0.45359237) - (used * 0.45359237 * 0.08)); # JT4 engines minus 8 percent
	var totalkg = fueltotal * 0.45359237;
	var rt = 0;
	
	# how long we can fly
	if(used){
		var rt = fueltotal / used * 3600;
	  var hours = int(rt/3600);
		var minutes = int(math.mod(rt / 60, 60));
	}
	
	if(kg > 0){
		help_win.write(sprintf("Total Fuel: %.2fkg - fuel consumption/hour: %.2fkg expected flighttime %3dh %02dmin", totalkg, kg, hours, minutes));
	}else{
		help_win.write(sprintf("NO FUEL CONSUMPTION - Total fuel: %.2fkg", fueltotal));
	}
} 

# real cabin altitude in pressurisatiion cabin alt instrument
var show_cabin_alt = func {
	var calt = getprop("/b707/pressurization/cabin-altitude") or 0;
	help_win.write(sprintf("Cabin Altitude: %.0fft", calt)); 
}
 
# show the mp or ai aircraft information on the radar

var show_mp_info = func (i){
	var cs  = getprop("instrumentation/mptcas/mp[" ~ i ~ "]/callsign") or "";
	var al  = getprop("instrumentation/mptcas/mp[" ~ i ~ "]/altitude-ft") or 0;
	var as  = getprop("instrumentation/mptcas/mp[" ~ i ~ "]/tas-kt") or 0;
	var dis = getprop("instrumentation/mptcas/mp[" ~ i ~ "]/distance-nm") or 0;
	var code = getprop("instrumentation/mptcas/mp[" ~ i ~ "]/id-code") or "----";

  help_win.write(sprintf(cs~" / %.0fft / %.0fkts / %.2fnm / Transponder-Code: "~code~" ", al, as, dis) ); 
} 

var show_ai_info = func (i){
	var cs  = getprop("instrumentation/mptcas/ai[" ~ i ~ "]/callsign") or "";
	var al  = getprop("instrumentation/mptcas/ai[" ~ i ~ "]/altitude-ft") or 0;
	var as  = getprop("instrumentation/mptcas/ai[" ~ i ~ "]/tas-kt") or 0;
	var dis = getprop("instrumentation/mptcas/ai[" ~ i ~ "]/distance-nm") or 0;

  help_win.write(sprintf(cs~" / %.0fft / %.0fkts / %.2fnm", al, as, dis) );
}

var show_ta_info = func (i){
	var cs  = getprop("instrumentation/mptcas/ta[" ~ i ~ "]/callsign") or "";
	var al  = getprop("instrumentation/mptcas/ta[" ~ i ~ "]/altitude-ft") or 0;
	var as  = getprop("instrumentation/mptcas/ta[" ~ i ~ "]/tas-kt") or 0;
	var dis = getprop("instrumentation/mptcas/ta[" ~ i ~ "]/distance-nm") or 0;

  help_win.write(sprintf(cs~" / %.0fft / %.0fkts / %.2fnm", al, as, dis) );
}

var show_mp_awacs_info = func (i){
	var cs  = getprop("instrumentation/mptcas/mp[" ~ i ~ "]/callsign") or "";
	var al  = getprop("instrumentation/mptcas/mp[" ~ i ~ "]/altitude-ft") or 0;
	var as  = getprop("instrumentation/mptcas/mp[" ~ i ~ "]/tas-kt") or 0;
	var dis = getprop("instrumentation/mptcas/mp[" ~ i ~ "]/distance-nm") or 0;
	var bg = getprop("instrumentation/mptcas/mp[" ~ i ~ "]/bearing-deg") or 0;
	var ct = getprop("instrumentation/mptcas/mp[" ~ i ~ "]/course-to-mp") or 0;
	var code = getprop("instrumentation/mptcas/mp[" ~ i ~ "]/id-code") or "----";

  help_win.write(sprintf(cs~" / %.0fhdg / course to %.0fdeg /  %.0fft / %.0fkts / %.2fnm / Transponder-Code: "~code~" ", bg, ct, al, as, dis) ); 
} 

var show_ai_awacs_info = func (i){
	var cs  = getprop("instrumentation/mptcas/ai[" ~ i ~ "]/callsign") or "";
	var al  = getprop("instrumentation/mptcas/ai[" ~ i ~ "]/altitude-ft") or 0;
	var as  = getprop("instrumentation/mptcas/ai[" ~ i ~ "]/tas-kt") or 0;
	var bg = getprop("instrumentation/mptcas/ai[" ~ i ~ "]/bearing-deg") or 0;
	var ct = getprop("instrumentation/mptcas/ai[" ~ i ~ "]/course-to-mp") or 0;
	var dis = getprop("instrumentation/mptcas/ai[" ~ i ~ "]/distance-nm") or 0;

  help_win.write(sprintf(cs~" / %.0fhdg / course to %.0fdeg / %.0fft / %.0fkts / %.2fnm", bg, ct, al, as, dis) );
}

var show_ta_awacs_info = func (i){
	var cs  = getprop("instrumentation/mptcas/ta[" ~ i ~ "]/callsign") or "";
	var al  = getprop("instrumentation/mptcas/ta[" ~ i ~ "]/altitude-ft") or 0;
	var as  = getprop("instrumentation/mptcas/ta[" ~ i ~ "]/tas-kt") or 0;
	var bg = getprop("instrumentation/mptcas/ta[" ~ i ~ "]/bearing-deg") or 0;
	var ct = getprop("instrumentation/mptcas/ta[" ~ i ~ "]/course-to-mp") or 0;
	var dis = getprop("instrumentation/mptcas/ta[" ~ i ~ "]/distance-nm") or 0;

  help_win.write(sprintf(cs~" / %.0fhdg / course to %.0fdeg / %.0fft / %.0fkts / %.2fnm", bg, ct, al, as, dis) );
}

#################################### helper for the standby ADI ############################################
var gauge_erec = func {
  setprop("/instrumentation/vertical-speed-indicator/serviceable",0);
  var tmp_vs = getprop("/instrumentation/vertical-speed-indicator/indicated-speed-fpm") or 0;
  var tmp_vs_target_max = 4000;
  var tmp_vs_target_min = -3000;
  interpolate("/instrumentation/adi/knob-pos",1,0.2);
  interpolate("/instrumentation/vertical-speed-indicator/indicated-speed-fpm",tmp_vs_target_max,0.3); 
	settimer( func{ interpolate("/instrumentation/vertical-speed-indicator/indicated-speed-fpm",tmp_vs_target_min,0.7); }, 0.3);
	settimer( func{ interpolate("/instrumentation/vertical-speed-indicator/indicated-speed-fpm",tmp_vs,0.5); }, 1.0);
	settimer( func{   setprop("/instrumentation/vertical-speed-indicator/serviceable", 1);
										setprop("/instrumentation/adi/knob-pos", 0); }, 1.5);

}

####################################### total operating time ###################################
var operating_time_counter = func {
	#print("operating time counter works");
  var act_time    	= props.globals.getNode("/sim/time/elapsed-sec");
  var start_time  	= props.globals.getNode("/instrumentation/operating-time/start-time");
  var old_total   	= props.globals.getNode("/instrumentation/operating-time/total");
  var old_total_h   = props.globals.getNode("/instrumentation/operating-time/total-h");
  var old_total_m   = props.globals.getNode("/instrumentation/operating-time/total-m");
  
  var new_total   = old_total.getValue() + (act_time.getValue() - start_time.getValue());
  
  var hours = new_total / 3600;
  var minutes = int(math.mod(new_total / 60, 60));
  
  start_time.setValue(act_time.getValue());
  old_total.setValue(new_total);
  old_total_h.setValue(hours);
  old_total_m.setValue(minutes);
  
	settimer( operating_time_counter, 60);
}

operating_time_counter();

####################################### speedbrake helper #######################################
var stepSpeedbrakes = func(step) {
    # Hard-coded speedbrakes movement in 4 equal steps:
    var val = 0.25 * step + getprop("/controls/flight/spoilers");
    setprop("/controls/flight/spoilers", val > 1 ? 1 : val < 0 ? 0 : val);
}
var fullSpeedbrakes = func {
    var val = getprop("/controls/flight/spoilers");
    setprop("/controls/flight/spoilers", val > 0 ? 0 : 1);
}

################# compass controllers and the magnetic compass up or down #####################################

props.globals.initNode("/instrumentation/compass-control[0]/justify",0,"BOOL");
props.globals.initNode("/instrumentation/compass-control[1]/justify",0,"BOOL");

setlistener( "/instrumentation/compass-control[0]/mag", func(state){ 
	var value = state.getValue();
	var nIndicatedHeading = props.globals.initNode("b707/hsi[0]/indicated-heading-deg",0.0,"DOUBLE");
	nIndicatedHeading.unalias();
	if(value){
		nIndicatedHeading.alias("instrumentation/magnetic-compass/indicated-heading-deg");
	}else{
		nIndicatedHeading.alias("instrumentation/heading-indicator-fg/indicated-heading-deg");
	}
},1,0);

setlistener( "/instrumentation/compass-control[1]/mag", func(state){ 
	var value = state.getValue();
	var nIndicatedHeading = props.globals.initNode("b707/hsi[1]/indicated-heading-deg",0.0,"DOUBLE");
	nIndicatedHeading.unalias();
	if(value){
		nIndicatedHeading.alias("instrumentation/magnetic-compass/indicated-heading-deg");
	}else{
		nIndicatedHeading.alias("instrumentation/heading-indicator-fg/indicated-heading-deg");
	}
},1,0);


setlistener( "/instrumentation/compass-control[0]/lat-turn", func(state){ 
	var latCorr = state.getValue() or 0;
	var latPos = getprop("/position/latitude-deg") or 0;
	var magVar = getprop("/environment/magnetic-variation-deg") or 0;
	var nS = getprop("/instrumentation/compass-control[0]/lat-knob") or 0;
	var f = (nS) ? -1 : 1;
	#offset = magnetische Abweichung + ((Knob adjust error percent) * N/S * max error)
	var latJustify = latPos - latCorr * f;
	if (latJustify >= -1 and latJustify <= 1) {
		setprop("instrumentation/compass-control[0]/justify",1);
	}else{
		setprop("instrumentation/compass-control[0]/justify",0);
	}
	var offset = -magVar + (latJustify/90.0) * 40.0;
	setprop("/instrumentation/heading-indicator-fg/offset-deg", offset);
	show_lat_lon();
},1,0);

setlistener( "/instrumentation/compass-control[1]/lat-turn", func(state){ 
	var latCorr = state.getValue() or 0;
	var latPos = getprop("/position/latitude-deg") or 0;
	var magVar = getprop("/environment/magnetic-variation-deg") or 0;
	var nS = getprop("/instrumentation/compass-control[1]/lat-knob") or 0;
	var f = (nS) ? -1 : 1;
	#offset = magnetische Abweichung + ((Knob adjust error percent) * N/S * max error)
	var latJustify = latPos - latCorr * f;
	if (latJustify >= -1 and latJustify <= 1) {
		setprop("instrumentation/compass-control[1]/justify",1);
	}else{
		setprop("instrumentation/compass-control[1]/justify",0);
	}
	var offset = -magVar + (latJustify/90.0) * 40.0;
	setprop("/instrumentation/heading-indicator-fg[1]/offset-deg", offset);
	show_lat_lon();
},1,0);

setlistener( "/instrumentation/compass-control[0]/lat-knob", func(state){ 
	var nS = state.getBoolValue() or 0;
	var latPos = getprop("/position/latitude-deg") or 0;
	var magVar = getprop("/environment/magnetic-variation-deg") or 0;
	var latCorr = getprop("/instrumentation/compass-control[0]/lat-turn") or 0;
	var f = (nS) ? -1 : 1;	
	var latJustify = latPos - latCorr * f;
	if (latJustify >= -1 and latJustify <= 1) {
		setprop("instrumentation/compass-control[0]/justify",1);
	}else{
		setprop("instrumentation/compass-control[0]/justify",0);
	}
	var offset = -magVar + (latJustify/90.0) * 40.0;
	setprop("/instrumentation/heading-indicator-fg/offset-deg", offset);
	show_lat_lon();
},1,0);

setlistener( "/instrumentation/compass-control[1]/lat-knob", func(state){ 
	var nS = state.getBoolValue() or 0;
	var latPos = getprop("/position/latitude-deg") or 0;
	var magVar = getprop("/environment/magnetic-variation-deg") or 0;
	var latCorr = getprop("/instrumentation/compass-control[1]/lat-turn") or 0;
	var f = (nS) ? -1 : 1;	
	var latJustify = latPos - latCorr * f;
	if (latJustify >= -1 and latJustify <= 1) {
		setprop("instrumentation/compass-control[1]/justify",1);
	}else{
		setprop("instrumentation/compass-control[1]/justify",0);
	}
	var offset = -magVar + (latJustify/90.0) * 40.0;
	setprop("/instrumentation/heading-indicator-fg[1]/offset-deg", offset);
	show_lat_lon();
},1,0);

var compass_swing = func{
	var state = getprop("/b707/compass-pos") or 0;
	if(!state){
		interpolate("/b707/compass-pos", 1, 0.8);
	}else{
		interpolate("/b707/compass-pos", 0, 0.8);
	}
}


######################################## engine vibrations #######################################
var my_mini_rand = func(min,max) {
		  var min = min;
		  var max = max;
		  var r = 0;

			while( r < min or r > max ){
					r = rand();
			}
			
		  return r;
}

var eng_vib = func {

	var evib1 = getprop("/engines/engine[0]/n2") or 0;
	var evib2 = getprop("/engines/engine[1]/n2") or 0;
	var evib3 = getprop("/engines/engine[2]/n2") or 0;
	var evib4 = getprop("/engines/engine[3]/n2") or 0;
	var dc = getprop("/b707/ess-bus") or 0;
	var vibte = getprop("/b707/vibrations/vib-test") or 0;	
	var state = getprop("/b707/vibrations/vib-sel") or 0;
	
	var a1 = 0;
	var a2 = 0;
	var a3 = 0;
	var a4 = 0;

	if(state == 1 and !vibte) {
		if(evib1 > 10 and dc > 20) a1 = my_mini_rand(0.46, 0.54);
		if(evib2 > 10 and dc > 20) a2 = my_mini_rand(0.42, 0.58);
		if(evib3 > 10 and dc > 20) a3 = my_mini_rand(0.43, 0.57);
		if(evib4 > 10 and dc > 20) a4 = my_mini_rand(0.46, 0.54);
		interpolate("/b707/vibrations/vib[0]", a1, 2.5);
		interpolate("/b707/vibrations/vib[1]", a2, 2.5);
		interpolate("/b707/vibrations/vib[2]", a3, 2.5);
		interpolate("/b707/vibrations/vib[3]", a4, 3.5);
		settimer( eng_vib, 2.5);
		
	}elsif(state == 2 and !vibte) {
		if(evib1 > 10 and dc > 20) a1 = my_mini_rand(0.25, 0.35);
		if(evib2 > 10 and dc > 20) a2 = my_mini_rand(0.25, 0.35);
		if(evib3 > 10 and dc > 20) a3 = my_mini_rand(0.25, 0.35);
		if(evib4 > 10 and dc > 20) a4 = my_mini_rand(0.25, 0.35);
		interpolate("/b707/vibrations/vib[0]", a1, 2.5);
		interpolate("/b707/vibrations/vib[1]", a2, 2.5);
		interpolate("/b707/vibrations/vib[2]", a3, 2.5);
		interpolate("/b707/vibrations/vib[3]", a4, 2.5);
		settimer( eng_vib, 2.5);
		
	}else{
		interpolate("/b707/vibrations/vib[0]", a1, 0.5);
		interpolate("/b707/vibrations/vib[1]", a2, 0.5);
		interpolate("/b707/vibrations/vib[2]", a3, 0.5);
		interpolate("/b707/vibrations/vib[3]", a4, 0.5);
	}

}

setlistener("/b707/vibrations/vib-sel", eng_vib,1,0);

############################## view helper ###############################
var changeView = func (n){
  setprop("/b707/shake-effect/effect",0);
  var actualView = props.globals.getNode("/sim/current-view/view-number", 1);
  if (actualView.getValue() == n){
    actualView.setValue(0);
  }else{
    actualView.setValue(n);
  }
  setprop("/b707/shake-effect/effect",1);
}

################## hydraulic system and auxilliary pumps #################
var HydQuant = props.globals.initNode("b707/hydraulic/quantity",5400,"DOUBLE");
var rud = props.globals.initNode("/b707/hydraulic/rudder",0,"DOUBLE");
var sys = props.globals.initNode("/b707/hydraulic/system",0,"DOUBLE");
var shut1 = props.globals.getNode("/b707/hydraulic/hyd-fluid-shutoff[0]", 1);
var shut2 = props.globals.getNode("/b707/hydraulic/hyd-fluid-shutoff[1]", 1);
var pump1 = props.globals.getNode("/b707/hydraulic/hyd-fluid-pump[0]", 1);
var pump2 = props.globals.getNode("/b707/hydraulic/hyd-fluid-pump[1]", 1);
var acAux1 = props.globals.getNode("/b707/hydraulic/ac-aux-pump[0]", 1);
var acAux2 = props.globals.getNode("/b707/hydraulic/ac-aux-pump[1]", 1);
var eb = props.globals.getNode("/b707/ess-bus", 1);

setlistener("/b707/hydraulic/hyd-fluid-shutoff[0]", func{
	if(shut1.getBoolValue() and eb.getValue() > 23){
		 if (sys.getValue() <= 1 and pump1.getBoolValue()){ 
		 		interpolate("/b707/hydraulic/system", 2210, 12); # <=1 interpolation did not started before
		 		var q = (HydQuant.getValue() >= 5400) ? 4400 : HydQuant.getValue() - 1000;
		 		interpolate("/b707/hydraulic/quantity", q, 12);
		 }
	}else{
		 pump1.setBoolValue(0);
		 if (!shut2.getBoolValue() or !pump2.getBoolValue(0) or eb.getValue() < 23) { 
		 		interpolate("/b707/hydraulic/system", 0, 7);
		 		var q = (HydQuant.getValue() >= 4400) ? 5400 : HydQuant.getValue() + 1000;
		 		interpolate("/b707/hydraulic/quantity", q, 7);
		 }	
	}
},0,0);

setlistener("/b707/hydraulic/hyd-fluid-shutoff[1]", func{
	if(shut2.getBoolValue() and eb.getValue() > 23){
		 if (sys.getValue() <= 1 and pump2.getBoolValue()){ 
		 		interpolate("/b707/hydraulic/system", 2210, 12); # <=1 interpolation did not started before
		 		var q = (HydQuant.getValue() >= 5400) ? 4400 : HydQuant.getValue() - 1000;
		 		interpolate("/b707/hydraulic/quantity", q, 12);
		 }
	}else{
		 pump2.setBoolValue(0);
		 if (!shut1.getBoolValue() or !pump1.getBoolValue(0) or eb.getValue() < 23) { 
		 		interpolate("/b707/hydraulic/system", 0, 7);
		 		var q = (HydQuant.getValue() >= 4400) ? 5400 : HydQuant.getValue() + 1000;
		 		interpolate("/b707/hydraulic/quantity", q, 7);
		 }	
	}
},0,0);

setlistener("/b707/hydraulic/hyd-fluid-pump[0]", func{
	if(pump1.getBoolValue() and eb.getValue() > 23){
		 if (sys.getValue() <= 1 and shut1.getBoolValue()){ 
		 		interpolate("/b707/hydraulic/system", 2210, 12); # <=1 interpolation did not started before
		 		var q = (HydQuant.getValue() >= 5400) ? 4400 : HydQuant.getValue() - 1000;
		 		interpolate("/b707/hydraulic/quantity", q, 12);
		 }
	}else{
		 if (!shut2.getBoolValue() or !pump2.getBoolValue()) { 
		 		interpolate("/b707/hydraulic/system", 0, 7);
		 		var q = (HydQuant.getValue() >= 4400) ? 5400 : HydQuant.getValue() + 1000;
		 		interpolate("/b707/hydraulic/quantity", q, 7);
		 }	
	}
},0,0);

setlistener("/b707/hydraulic/hyd-fluid-pump[1]", func{
	if(pump2.getBoolValue() and eb.getValue() > 23){
		 if (sys.getValue() <= 1 and shut2.getBoolValue()) { 
		 		interpolate("/b707/hydraulic/system", 2210, 12); # <=1 interpolation did not started before
		 		var q = (HydQuant.getValue() >= 5400) ? 4400 : HydQuant.getValue() - 1000;
		 		interpolate("/b707/hydraulic/quantity", q, 12);
		 }
	}else{
		 if (!shut1.getBoolValue() or !pump1.getBoolValue()) { 
		 		interpolate("/b707/hydraulic/system", 0, 7);
		 		var q = (HydQuant.getValue() >= 4400) ? 5400 : HydQuant.getValue() + 1000;
		 		interpolate("/b707/hydraulic/quantity", q, 7);
		 }	
	}
},0,0);

setlistener("/b707/hydraulic/ac-aux-pump[0]", func{
	if(acAux1.getBoolValue() and eb.getValue() > 23){
		 if (rud.getValue() <= 1){ 
		 		interpolate("/b707/hydraulic/rudder", 3010, 14); # <=1 interpolation did not started before
		 		var q = (HydQuant.getValue() >= 5400) ? 4200 : HydQuant.getValue() - 1200;
		 		interpolate("/b707/hydraulic/quantity", q, 14);
		 }
	}else{
		 if (!acAux2.getBoolValue()) { 
		 		 	interpolate("/b707/hydraulic/rudder", 0, 8);
		 			var q = (HydQuant.getValue() >= 4200) ? 5400 : HydQuant.getValue() + 1200;
			 		interpolate("/b707/hydraulic/quantity", q, 8);
		 }	
	}
},0,0);

setlistener("/b707/hydraulic/ac-aux-pump[1]", func{
	if(acAux2.getBoolValue() and eb.getValue() > 23){
		 if (rud.getValue() <= 1){ 
		 		interpolate("/b707/hydraulic/rudder", 3010, 14); # <=1 interpolation did not started before
		 		var q = (HydQuant.getValue() >= 5400) ? 4200 : HydQuant.getValue() - 1200;
		 		interpolate("/b707/hydraulic/quantity", q, 14);
		 }
	}else{
		 if (!acAux1.getBoolValue()) { 
		 		 	interpolate("/b707/hydraulic/rudder", 0, 8);
		 			var q = (HydQuant.getValue() >= 4200) ? 5400 : HydQuant.getValue() + 1200;
			 		interpolate("/b707/hydraulic/quantity", q, 8);
		 }	
	}
},0,0);

############################################ Fire #####################################################
# see in fuel-and-payload.nas engines_alive();

setlistener("/b707/warning/fire-button[0]", func(state){
	var state = state.getValue() or 0;
	if(state){
		 settimer( func { setprop("/controls/engines/engine[0]/fire", 0); }, 3);
	}
},0,0);
setlistener("/b707/warning/fire-button[1]", func(state){
	var state = state.getValue() or 0;
	if(state){
		 settimer( func { setprop("/controls/engines/engine[1]/fire", 0); }, 3);
	}
},0,0);
setlistener("/b707/warning/fire-button[2]", func(state){
	var state = state.getValue() or 0;
	if(state){
		 settimer( func { setprop("/controls/engines/engine[2]/fire", 0); }, 3);
	}
},0,0);
setlistener("/b707/warning/fire-button[3]", func(state){
	var state = state.getValue() or 0;
	if(state){
		 settimer( func { setprop("/controls/engines/engine[3]/fire", 0); }, 3);
	}
},0,0);

# if gen-drive is set to on in flight, engines crashed
setlistener("/b707/generator/gen-drive[0]", func(state){
	var state = state.getBoolValue() or 0;
	var a = getprop("/position/altitude-agl-ft") or 0;
	if(a > 20 and state){
		 settimer( func { setprop("/controls/engines/engine[0]/fire", 1) }, 2);
	}
},0,0);
setlistener("/b707/generator/gen-drive[1]", func(state){
	var state = state.getBoolValue() or 0;
	var a = getprop("/position/altitude-agl-ft") or 0;
	if(a > 20 and state){
		 settimer( func { setprop("/controls/engines/engine[1]/fire", 1) }, 2);
	}
},0,0);
setlistener("/b707/generator/gen-drive[2]", func(state){
	var state = state.getBoolValue() or 0;
	var a = getprop("/position/altitude-agl-ft") or 0;
	if(a > 20 and state){
		 settimer( func { setprop("/controls/engines/engine[2]/fire", 1) }, 2);
	}
},0,0);
setlistener("/b707/generator/gen-drive[3]", func(state){
	var state = state.getBoolValue() or 0;
	var a = getprop("/position/altitude-agl-ft") or 0;
	if(a > 20 and state){
		 settimer( func { setprop("/controls/engines/engine[3]/fire", 1) }, 2);
	}
},0,0);

################# OIL System  AND WINDSHIELD EFFECT also TAT independence Loop 32sec ################
var calc_oil_temp = func{

	var atemp  =  getprop("/environment/temperature-degc") or 0;
	var vmach  =  getprop("/velocities/mach") or 0;
	
	# without any engine and no support what happens to the wingTemperature
  # Calculate TAT Value (TAT = static temp (1 +((1.4 - 1) / 2) Mach^2) )
	var tat = atemp * (1 + (0.2 * vmach * vmach));
	interpolate("/b707/anti-ice/total-air-temperature", tat, 32); # show it on instrument
	var digittat = abs(tat);
	interpolate("/b707/anti-ice/total-air-temperature-digit", digittat, 32); # show it on instrument
	#print("TAT ist: "~tat);
	#print("TAT ist: "~digittat);
	
	# calculate the windows alpha for ice effect - use this loop only for the 32 sec
	var capH = getprop("/b707/anti-ice/window-heat-cap-switch") or 0;
	var FoH = getprop("/b707/anti-ice/window-heat-fo-switch") or 0;
	if(tat < 1){    # temperature lower than 1 degree Celsius
		var newAlpha = 1 - (abs(tat)/10); # total icing at -10 tat
		newAlpha = (newAlpha > 1) ? 1 : (newAlpha < 0) ? 0 : newAlpha;
		if(capH){
			var newAlphaC = windowHeatAlphaCapt.getValue() + (0.2 * capH);
			newAlphaC = (newAlphaC > 1) ? 1 : (newAlphaC < 0) ? 0 : newAlphaC;
			interpolate("/b707/anti-ice/window-alpha-capt", newAlphaC, 20);
		}else{
			interpolate("/b707/anti-ice/window-alpha-capt", newAlpha, 30);
		}
		if(FoH){
			var newAlphaF = windowHeatAlphaFO.getValue() + (0.2 * FoH);
			newAlphaF = (newAlphaF > 1) ? 1 : (newAlphaF < 0) ? 0 : newAlphaF;
			interpolate("/b707/anti-ice/window-alpha-fo", newAlphaF, 20);
		}else{
			interpolate("/b707/anti-ice/window-alpha-fo", newAlpha, 30);
		}	
	
	}else{
		if(windowHeatAlphaCapt.getValue() < 1.0){
			interpolate("/b707/anti-ice/window-alpha-capt", 1.0, 15);
		}
		if(windowHeatAlphaFO.getValue() < 1.0){
			interpolate("/b707/anti-ice/window-alpha-fo", 1.0, 15);
		}
	}

	foreach(var e; props.globals.getNode("/engines").getChildren("engine")) {
	  var n = 0;
	  if(e.getNode("oil-pressure-psi")!= nil and e.getNode("oil-pressure-psi").getValue()){
			n = e.getNode("oil-pressure-psi").getValue();
		}
		var r = 0;
		if(e.getNode("running") != nil){
			r = e.getNode("running").getValue();
		}
		
		var t = n * 2.148;
		if(r){
			# the oil temp calculation
			interpolate("/b707/oil/oil-temp["~e.getIndex()~"]", t, 32);				
		}else{
			interpolate("/b707/oil/oil-temp["~e.getIndex()~"]", atemp, 32);
		}
	}
	
	settimer( calc_oil_temp, 32);
}

settimer( calc_oil_temp, 10); # start first after 10 sec


############ diff loop for the DEICING of WINGS and ENGINES Loop 15 sec #############

var nacelle_deicing = func {

	var atemp  =  getprop("/environment/temperature-degc") or 0;
	var tat = getprop("/b707/anti-ice/total-air-temperature") or 0;
	var coef = getprop("/b707/anti-ice/drag-coefficient") or 0; # standard is 1, worst case is wc
	var wc = 7; # the max Drag factor for our aircraft - over this value, the behavior in simulation is unrealistic
	
	# without any engine and no support what happens to the wingTemperature
  var wingTempOutL = tat;  
  var wingTempOutR = tat;  
  var wingTempInL = tat;  
  var wingTempInR = tat;
  var wingAntiIce = getprop("/b707/anti-ice/switch") or 0;
  var iceAlertEngines = 0;
  var iceAlertWings = 0;
  var iceAlertFuel = 0;
  
	# if engines running show me the temperature near the wing anti ice valve
	foreach(var e; props.globals.getNode("/engines").getChildren("engine")) {
		var r = 0;
	  if(e.getNode("running") != nil and e.getNode("running").getValue()){
			r = e.getNode("running").getValue();
		}
		var deg = 0;
	  if(e.getNode("egt-degf") != nil and e.getNode("egt-degf").getValue()){
			deg = e.getNode("egt-degf").getValue();
		}		
		var engineInlet = getprop("/b707/anti-ice/engine-inlet["~e.getIndex()~"]") or 0;
		
		if (!engineInlet and e.getIndex() < 4) {
		  var n = e.getIndex() + 1;
		  if(tat <= -10) iceAlertEngines = 1;
		  if(tat <= -30) setprop("/controls/engines/engine["~e.getIndex()~"]/cutoff", 1);
		}
		
		var temperature = deg * 110/1400; # engines have 1400 degree f max temperature
		
		if(r){
			# the wing Ice
			if(e.getIndex() == 0 and wingAntiIce){
				var wingTempOutL = temperature + 5;  # + 5 only for difference on instruments :-)
			}
			if(e.getIndex() == 1 and wingAntiIce){
				var wingTempInL = temperature - 4; 
			}
			if(e.getIndex() == 2 and wingAntiIce){
				var wingTempInR = temperature - 6; 
			}
			if(e.getIndex() == 3 and wingAntiIce){
				var wingTempOutR = temperature + 7; 
			}		
		}
		
	}
	
	# and turn the needles in the wing anti ice instruments (overhead panel)
	interpolate("/b707/anti-ice/temp-out-l", wingTempOutL, 15);
	interpolate("/b707/anti-ice/temp-in-l", wingTempInL, 15);
	interpolate("/b707/anti-ice/temp-out-r", wingTempOutR, 15);
	interpolate("/b707/anti-ice/temp-in-r", wingTempInR, 15);
	
	# calculate the drag-coefficient of our aircraft with ice - no ice/  1 is perfect, wc is the worst case
	if(tat < 1){
	    # overwrite the variable from real temperature to factor 1 to wc for coefficent calc
			wingTempOutL = (wingTempOutL < -4) ? abs(wingTempOutL)/4 : 1;
			wingTempInL = (wingTempInL < -4) ? abs(wingTempInL)/4 : 1;
			wingTempOutR = (wingTempOutR < -4) ? abs(wingTempOutR)/4 : 1;
			wingTempInR = (wingTempInR < -4) ? abs(wingTempInR)/4 : 1;

			var newcoef = (wingTempOutL + wingTempInL + wingTempInR + wingTempOutR)/4;
			# print("Coeff: " ~newcoef);
			newcoef = (newcoef > wc) ? wc : newcoef;
			newcoef = ((coef - newcoef) > 1) ? newcoef + 1 : newcoef;   # go back after switch on heating max 1 point/15 sec
			
			if(coef != newcoef) interpolate("/b707/anti-ice/drag-coefficient", newcoef, 15);
			
			if(coef < newcoef) iceAlertWings = 1; # only message, if value rise up
			
	}else{
		if(coef > 1){
			interpolate("/b707/anti-ice/drag-coefficient", 1, 15);
		}
	}
	
	### Fuel temperature
	var sel = getprop("/b707/fuel/temperatur-selector") or 0; 
  # 0 = Main Tank 1, 1 = Engine 1, 2 = Engine 2 ... Main Tank has no heater
  var fuelTempMain = (tat < -10) ? -10 : tat;
  setprop("/b707/fuel/temp[0]", fuelTempMain);
  
  if (sel == 0) setprop("/b707/fuel/temperature", fuelTempMain);
  
	foreach(var h; props.globals.getNode("/b707/fuel").getChildren("heater")) {
	  var state = h.getValue();
	  var hnr = h.getIndex();
	  var tnr = hnr + 1;
	  var oldfuelTemp = getprop("/b707/fuel/temp["~tnr~"]") or 0;
	  var newfuelTemp = tat;
	  
	  if(state){
	  		newfuelTemp = oldfuelTemp + 5;
	  		newfuelTemp = (newfuelTemp > 20) ? 20 : newfuelTemp;
	  }
	  
	  if(newfuelTemp <  -8)  iceAlertFuel = 1;
	  if(newfuelTemp < -20)  setprop("/controls/engines/engine["~hnr~"]/cutoff", 1);
	  
		setprop("/b707/fuel/temp["~tnr~"]", newfuelTemp);
  	if (sel == tnr) interpolate("/b707/fuel/temperature", newfuelTemp, 15);
	}
	
	if(iceAlertWings) {
		screen.log.write("WINGS - ICE ALERT: Switch on the WING ANTI-ICE System", 1, 0, 0);
		iceAlertWings = 0;
		setprop("/b707/warning/ice", 1);
		settimer(func{ setprop("/b707/warning/ice", 0)}, 14.5);
	}
	if(iceAlertEngines) {
		screen.log.write("ENGINES - ICE ALERT: Switch on the NACELLE ANTI-ICE System", 1, 0, 0);
		iceAlertEngines = 0;
		setprop("/b707/warning/ice", 1);
		settimer(func{ setprop("/b707/warning/ice", 0)}, 14.5);
	}
	if(iceAlertFuel) {
		screen.log.write("FUEL - ICE ALERT: Switch on the FUEL HEATER System", 1, 0, 0);
		iceAlertFuel = 0;
		setprop("/b707/warning/ice", 1);
		settimer(func{ setprop("/b707/warning/ice", 0)}, 14.5);
	}

	settimer( nacelle_deicing, 15);
}

settimer( nacelle_deicing, 12); # start first after 12 sec

####################### COOLING AND PRESSURIZATION LOOP ###########################
var safety_valv_pos = func {
	setprop("b707/pressurization/safety-valve-pos", 0);
	setprop("/b707/pressurization/manual-mode-switch", 0);
	var svs = getprop("b707/pressurization/safety-valve") or 0;
	if(svs){ 
		settimer( func { setprop("b707/pressurization/safety-valve-pos", 1) }, 2.1 );
	}
}

var calc_pressurization	= func{
	# loop time
	var t = 3;
	# if pressurization is on automatic and safety-valve is closed
	var svp = getprop("/b707/pressurization/safety-valve-pos") or 0;
	var ms  = getprop("/b707/pressurization/manual-mode-switch") or 0;
	var rate = getprop("/b707/pressurization/incr-decr-rate") or 0; # never divide to zero
	var mcs = getprop("/b707/pressurization/manual-control-selector") or 0; # never divide to zero
	var vs = getprop("/instrumentation/vertical-speed-indicator/indicated-speed-fpm") or 0;
	var alt = getprop("/instrumentation/altimeter/indicated-altitude-ft") or 0; # never divide to zero
	var agl = getprop("/position/altitude-agl-ft") or 0;
	var calt = getprop("/b707/pressurization/cabin-altitude") or 0;
	var max = getprop("/b707/pressurization/cabin-max") or 0;
	var mode = getprop("/b707/pressurization/mode-switch") or 0; # true is take off / false for landing
	var engBleedAir1 = getprop("/b707/air-conditioning/eng-bleed-air[0]") or 0;
	var engBleedAir2 = getprop("/b707/air-conditioning/eng-bleed-air[1]") or 0;
	var engBleedAir3 = getprop("/b707/air-conditioning/eng-bleed-air[2]") or 0;
	var engBleedAir4 = getprop("/b707/air-conditioning/eng-bleed-air[3]") or 0;
	engBleedAir1 = (engBleedAir1) ? getprop("engines/engine[0]/n1") : 0;
	engBleedAir2 = (engBleedAir2) ? getprop("engines/engine[1]/n1") : 0;
	engBleedAir3 = (engBleedAir3) ? getprop("engines/engine[2]/n1") : 0;
	engBleedAir4 = (engBleedAir4) ? getprop("engines/engine[3]/n1") : 0;
	
	# this is a fake calculation for psi in air supply and the control for the overheat of the compressors
	var overspeedMach = getprop("/velocities/mach") or 0;
	if(comrpm1.getValue() > 115 or overspeedMach > 0.93) settimer(func{air_compressor(0)}, 0);
	if(comrpm2.getValue() > 115 or overspeedMach > 0.93) settimer(func{air_compressor(1)}, 0);
	if(comrpm3.getValue() > 115 or overspeedMach > 0.93) settimer(func{air_compressor(2)}, 0);
	
	var airSupplyDuct = (engBleedAir1 + engBleedAir2 + engBleedAir3 + engBleedAir4 + comrpm1.getValue() + comrpm2.getValue() + comrpm3.getValue()) / 30 * 6;
	airSupplyDuct = (airSupplyDuct >= 0) ? airSupplyDuct : 0;
	interpolate("/b707/air-conditioning/air-supply-psi", airSupplyDuct, t);
	
	if(svp and airSupplyDuct > 18){
	
		if(ms){
		
			var autorate = vs/6.32;

			if(mode){ 					# in takeoff or flight mode
				if(calt < max){
					rate = (rate > 0) ? rate : autorate;
					calt = calt + (t*rate/60);
				}else{
					rate = 0;
				}

			}else{							# in landing mode
				if(calt > max){
					rate = (rate < 0) ? rate : autorate;
					calt = calt + (t*rate/60);
				}else{
					rate = 0;
				}

			}
			
			max = alt/6.3;
			max = (agl < 100) ? alt - 200 : max;
			
			interpolate("/b707/pressurization/cabin-max", max, t);  # the white scale is set automatically
			interpolate("/b707/pressurization/cabin-altitude", calt, t); # the alt needles 
			interpolate("/b707/pressurization/climb-rate", rate, t); # the climb rate
			#print("calc_pressurization is running in auto mode");
		}else{
			
			if((mcs > 0 and calt < max) or (mcs < 0 and calt > max)){
				calt = calt + (t*mcs/60);
			}else{
				calt = calt;
				mcs = 0;
			}	
			
			interpolate("/b707/pressurization/cabin-altitude", calt, t); # the alt needles as result of white scale and manual control 
			interpolate("/b707/pressurization/climb-rate", mcs, t);		# the climb rate as result of manual control
			#print("calc_pressurization is working on manual mode");
		}
		
	}else{
		calt = alt;
		#print("calc_pressurization is not working");
		interpolate("/b707/pressurization/cabin-altitude", alt, t);
		interpolate("/b707/pressurization/climb-rate", vs, t);
		var ra = getprop("position/altitude-agl-ft") or 0;
		if(ra > 2000) screen.log.write(sprintf("ATTENTION! No pressurization!"), 1.0, 0.0, 0.0);
	}
	
	# cabin differential pressure
	var diff = alt - calt;
	var psi = diff * 8.6/40000;
	psi = (psi > 10) ? 10 : psi;
	psi = (psi < 0) ? 0 : psi;
	interpolate("/b707/pressurization/cabin-differential-pressure", psi, t);
	
	if(calt > 8000){
		 screen.log.write(sprintf("ATTENTION! Increase cabin pressure expressly!"), 1.0, 0.0, 0.0);
	}else{
		if(svp) setprop("/b707/pressurization/alt-cutout-horn", 0); # reset if it was pushed during depressurization
	}
	
	settimer(calc_pressurization, t);
	
}

settimer( calc_pressurization, 9); # start first after 10 sec.

############################### Air Conditioning and Temperature #######################################
var air_cond_cover = func {
	var state = getprop("/b707/air-conditioning/air-cond-unit-cover") or 0;
	if(!state){
		interpolate("/b707/air-conditioning/air-cond-unit-cover", 1, 0.4);
	}else{
		interpolate("/b707/air-conditioning/air-cond-unit-cover", 0, 0.4);
	}
}

var air_compressor = func(nr){
  	var bt = getprop("/b707/air-conditioning/compressor-start["~nr~"]") or 0;
  	var engNr = nr + 1;
  	var engRun = getprop("/engines/engine["~engNr~"]/n2") or 0;
  	var ram = getprop("/b707/air-conditioning/ram-air-switch") or 0;
  	var pwr = getprop("/b707/ess-bus") or 0;

  	if(ram and pwr and engRun > 25){
			if(bt > 0){
				setprop("/b707/air-conditioning/compressor-start["~nr~"]", 0);
				interpolate("/b707/air-conditioning/compressor-rpm["~nr~"]", 0, 5);
			}else{
				setprop("/b707/air-conditioning/compressor-start["~nr~"]", 2);
				settimer( func { setprop("/b707/air-conditioning/compressor-start["~nr~"]", 1) }, 8);
				var rpm = my_mini_rand(0.8,1.0) * 120;
				interpolate("/b707/air-conditioning/compressor-rpm["~nr~"]", rpm, 7.8);
			}
		}else{
			setprop("/b707/air-conditioning/compressor-start["~nr~"]", 2);
			settimer( func { setprop("/b707/air-conditioning/compressor-start["~nr~"]", 0) }, 0.2);
			
			if(getprop("/sim/sound/switch2") == 1){
				 setprop("/sim/sound/switch2", 0); 
			}else{
				 setprop("/sim/sound/switch2", 1);
			}
		}
}

setlistener("/b707/pressurization/cabin-air-temp-selector", func(state){
	var state = state.getValue() or 0;
	if(state == 1){
		 interpolate("/b707/air-conditioning/cabin-temp", 19, 2);
	}elsif(state == 2){
		 interpolate("/b707/air-conditioning/cabin-temp", 22, 2);
	}elsif(state == 3){
		 interpolate("/b707/air-conditioning/cabin-temp", 18, 2);
	}else{
		 interpolate("/b707/air-conditioning/cabin-temp", getprop("/environment/temperature-degc"), 2);
	}
},1,0);

################################  funny sound action for the old elevator trim wheel #################### 

setlistener("/controls/flight/elevator-trim", func(et){
	var et = et.getValue();
	var ap = getprop("/autopilot/Bendix-PB-20/controls/active") or 0;
	if (!ap) {
		setprop("/b707/trim/elevator-trim-turn", et);
		lastTrimValue.setValue(et);
	}
},0,0);

var trim_loop = func{
	var et = getprop("/controls/flight/elevator-trim") or 0;
	var ap = getprop("/autopilot/Bendix-PB-20/controls/active") or 0;
	var diff = abs(lastTrimValue.getValue() - et);
	#print("Differenz: "~diff);
	if(ap and diff > 0.002){
			if(diff < 0.05 ){
				interpolate("/b707/trim/elevator-trim-turn", et, 2); 
			}elsif(diff >= 0.05 and diff < 0.3){
				interpolate("/b707/trim/elevator-trim-turn", et, 4); 			
			}else{
				interpolate("/b707/trim/elevator-trim-turn", et, 6); 			
			}
			lastTrimValue.setValue(et); # but we need the correct value
	}
	
	settimer(trim_loop, 8.2);
}

trim_loop();  # fire it up

##################### rudder and spoiler hydraulic switches in overhead panel ###################

setlistener("/b707/hydraulic/spoiler-switch[0]", func(state){
	var state = state.getValue() or 0;
	if(!state){
		 interpolate("/b707/trim/spoiler-nose-up", 1, 3);
	}else{
		 interpolate("/b707/trim/spoiler-nose-up", 0, 3);
	}
},0,0);


setlistener("/b707/hydraulic/spoiler-switch[1]", func(state){
	var state = state.getValue() or 0;
	if(!state){
		 interpolate("/b707/trim/spoiler-nose-down", 1, 3);
	}else{
		 interpolate("/b707/trim/spoiler-nose-down", 0, 3);
	}
},0,0);

##############################  Emergency flaps #################################################

var emerMain  = props.globals.getNode("/b707/emergency/emer-flap-switch");
var emerInbd  = props.globals.getNode("/b707/emergency/emer-flap-inbd");
var emerOutbd = props.globals.getNode("/b707/emergency/emer-flap-outbd");
 
setlistener("/b707/emergency/emer-flap-switch", func(state){
	var state = state.getValue() or 0;
	if(state){
		if(emerInbd.getValue()) controls.flapsDown(2);
		if(emerOutbd.getValue()) controls.flapsDown(2);
	}else{
		 controls.flapsDown(-4);
		 emerInbd.setValue(0);
		 emerOutbd.setValue(0);
	}
},0,1);

setlistener("/b707/emergency/emer-flap-inbd", func(state){
	var state = state.getValue() or 0;
	if(state == 1 and emerMain.getValue()){
		 controls.flapsDown(2);
		 settimer(func{emerInbd.setValue(0)},8);
	}elsif(state == 2 and emerMain.getValue()){
		 controls.flapsDown(-2);
		 settimer(func{emerInbd.setValue(0)},8);
	}
},0,1);

setlistener("/b707/emergency/emer-flap-outbd", func(state){
	var state = state.getValue() or 0;
	if(state == 1 and emerMain.getValue()){
		 controls.flapsDown(2);
		 settimer(func{emerOutbd.setValue(0)},8);
	}elsif(state == 2 and emerMain.getValue()){
		 controls.flapsDown(-2);
		 settimer(func{emerOutbd.setValue(0)},8);
	}
},0,1);

#########################  control to the rudder ############################################

var rudder_hyd_negativ_control = func{
	#overwrite the rudder control since I will found a better solution
	var control = getprop("/b707/hydraulic/rudder-switch") or 0;
	if(!control){
	  setprop("/controls/flight/rudder", 0);
		settimer(rudder_hyd_negativ_control, 0);
	}
}

setlistener("/b707/hydraulic/rudder-switch", func(state){
	var state = state.getValue() or 0;
	if(!state){
		 rudder_hyd_negativ_control();
	}
},1,0);

#################### If trim wheels are not on 0 and you click the center of this wheel #############
var trimBackTime = 1.0;
var applyTrimWheels = func(v, which = 0) {
    if (which == 0) { interpolate("/controls/flight/elevator-trim", v, trimBackTime); }
    if (which == 1) { interpolate("/controls/flight/rudder-trim", v, trimBackTime); }
    if (which == 2) { interpolate("/controls/flight/aileron-trim", v, trimBackTime); }
}

setlistener("/fdm/jsbsim/systems/crash-detect/crash-on-ground", func(state){
	var state = state.getValue() or 0;
	if(state == 1){
		 setprop("/b707/crashed", 1);
		 setprop("/controls/engines/engine[1]/fire", 1);
  	 props.globals.getNode("controls/gear/gear-down").setBoolValue(0);
  	 setprop("/controls/gear/brake-parking", 0);
  	 setprop("/b707/refuelling/probe-right", 0);
  	 setprop("/b707/refuelling/probe-left", 0);
	}
},0,1);

## GEAR
#######

# prevent retraction of the landing gear when any of the wheels are compressed
setlistener("controls/gear/gear-down", func
 {
 var down = props.globals.getNode("controls/gear/gear-down").getBoolValue();
 var crashed = getprop("/b707/crashed") or 0;
 if (!down and (getprop("gear/gear[0]/wow") or getprop("gear/gear[1]/wow") or getprop("gear/gear[2]/wow")))
  {
    if(!crashed){
  		props.globals.getNode("controls/gear/gear-down").setBoolValue(1);
    }else{
  		props.globals.getNode("controls/gear/gear-down").setBoolValue(0);
    }
  }
 });
 
# only for Tanker but don't worry if its no Tanker aircraft
var toggleProbeLeft = func(){
		var hose = getprop("/b707/refuelling/probe-left") or 0;
		if(!hose){
			setprop("/b707/refuelling/probe-left", 1);
			interpolate("/b707/refuelling/probe-left-lever", 1, 1);
		}else{
			setprop("/b707/refuelling/probe-left", 0);
			interpolate("/b707/refuelling/probe-left-lever", 0, 1);
		}
}
var toggleProbeRight = func(){
		var hose = getprop("/b707/refuelling/probe-right") or 0;
		if(!hose){
			setprop("/b707/refuelling/probe-right", 1);
			interpolate("/b707/refuelling/probe-right-lever", 1, 1);
		}else{
			setprop("/b707/refuelling/probe-right", 0);
			interpolate("/b707/refuelling/probe-right-lever", 0, 1);
		}
}
var toggleRefuelling = func{
  var somethingOut = 0;
  var lD = getprop("/b707/refuelling/probe-left") or 0;
  var rD = getprop("/b707/refuelling/probe-right") or 0;
  var bo = getprop("/instrumentation/doors/refuel-boom/position-norm") or 0;
  
  if(lD){
  	somethingOut = 1;
  } 
  if(rD){
  	somethingOut = 1;
  }
  if(bo > 0){
  	somethingOut = 1;
  }
  
  if(somethingOut){
  	setprop("/tanker", 0);
  	if(rD) toggleProbeRight();
  	if(lD) toggleProbeLeft();
		if(bo) b707.doorsystem.refuelexport();  
  }else{
  	setprop("/tanker", 1);
  	if(!rD) toggleProbeRight();
  	if(!lD) toggleProbeLeft();
		if(!bo) b707.doorsystem.refuelexport();
  }
}



