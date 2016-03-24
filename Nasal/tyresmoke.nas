# Lake of Constance Hangar :: M.Kraus
# Avril 2013
# This file is licenced under the terms of the GNU General Public Licence V2 or later
# ===================================================================================

###################### from the brakesystem.nas #####################

setlistener("gear/brake-smoke", func (brakesmoke){
	var brakesmoke = brakesmoke.getValue() or 0;
	if(brakesmoke){
		setprop("/controls/special/tyresmoke", 2);
	}else{
		setprop("/controls/special/tyresmoke", 0);
	}
},1,0);

setlistener("gear/gear[0]/wow", func (wow_0){
	setprop("/autopilot/switches/ap", 0);
	var wow_0 = wow_0.getValue() or 0;
	var state = props.globals.getNode("/controls/special/tyresmoke");
	var ias = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") or 0;
	if(wow_0 and ias > 100){
		setprop("/controls/special/tyresmoke", 3);
		settimer( func { setprop("/controls/special/tyresmoke",0); }, 2);
	}
},1,0);

setlistener("gear/gear[1]/wow", func (wow_1){
	setprop("/autopilot/switches/ap", 0);
	var wow_1 = wow_1.getValue() or 0;
	var state = props.globals.getNode("/controls/special/tyresmoke");
	var ias = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") or 0;
	if(wow_1 and ias > 100){
	  var state_nr = (state.getValue() > 2) ? 3 : 2;
	  state.setValue(state_nr);
		settimer( func { setprop("/controls/special/tyresmoke",0); }, 2);
	}
},1,0);


