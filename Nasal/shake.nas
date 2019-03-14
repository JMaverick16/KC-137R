#######################################################################################
#		Lake of Constance Hangar :: M.Kraus
#		Boeing 707 for Flightgear February 2014
#		This file is licenced under the terms of the GNU General Public Licence V2 or later
#######################################################################################

############################ roll out and shake effect ##################################
var shakeEffect707 = props.globals.initNode("b707/shake-effect/effect",0,"BOOL");
var shake707	   = props.globals.initNode("b707/shake-effect/shaking",0,"DOUBLE");
var rSpeed = 0;
var sf = 0;
var ge_a_r  = 0;

var theShakeEffect = func{
		ge_a_r = getprop("sim/multiplay/generic/float[1]") or 0;
		rSpeed = getprop("sim/multiplay/generic/float[2]") or 0;
		sf = rSpeed / 94000;
		# print("sf .... : " ~ sf);
	    
		if(shakeEffect707.getBoolValue() and ge_a_r > 0){
		  interpolate("b707/shake-effect/shaking", sf, 0.03);
		  settimer(func{
		  	 interpolate("b707/shake-effect/shaking", -sf*2, 0.03); 
		  }, 0.03);
		  settimer(func{
		  	interpolate("b707/shake-effect/shaking", sf, 0.03);
		  }, 0.06);
			settimer(theShakeEffect, 0.09);	
		}else{
		  	setprop("b707/shake-effect/shaking", 0);	
			setprop("b707/shake-effect/effect",0);		
		}	    
}
# INFORMATION: script will be startet in brakesystem.nas line 81 dependend the groundspeed ############
setlistener("b707/shake-effect/effect", func(state){
	if(state.getBoolValue()){
		theShakeEffect();
	}
},1,0);

