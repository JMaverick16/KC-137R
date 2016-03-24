#######################################################################################
#		Lake of Constance Hangar :: M.Kraus
#		Boeing 707 for Flightgear Septemper 2013
#		This file is licenced under the terms of the GNU General Public Licence V2 or later
#######################################################################################

Doors = {};

Doors.new = func {
   obj = { parents : [Doors],
           pilotwin : aircraft.door.new("instrumentation/doors/pilotwin", 2.0, 0),
		   		 copilotwin : aircraft.door.new("instrumentation/doors/copilotwin", 2.0, 0),
		   		 pasfront : aircraft.door.new("instrumentation/doors/pasfront", 4.0, 0),
		   		 pasrear : aircraft.door.new("instrumentation/doors/pasrear", 4.0, 0),
		   		 cargo : aircraft.door.new("instrumentation/doors/cargo", 12.0, 0),
		   		 belly : aircraft.door.new("instrumentation/doors/belly", 4.0, 0),
		   		 nose : aircraft.door.new("instrumentation/doors/nose", 2.0, 0),
		   		 refuel : aircraft.door.new("instrumentation/doors/refuel-boom", 14.0, 0),
         };
   return obj;
};

Doors.pilotwinexport = func {
   me.pilotwin.toggle();	
   
   # if sombody open the cockpit windows in flight
   var speed = getprop("/velocities/groundspeed-kt") or 0;
	 if(speed > 200){	 	 
	 	 setprop("b707/pressurization/safety-valve", 0);
	 	 b707.safety_valv_pos();
	 }
}

Doors.copilotwinexport = func {
   me.copilotwin.toggle();   
   # if sombody open the cockpit windows in flight
   var speed = getprop("/velocities/groundspeed-kt") or 0;
	 if(speed > 200){
	 	 setprop("b707/pressurization/safety-valve", 0);
	 	 b707.safety_valv_pos();
	 }
}

Doors.pasfrontexport = func {
	var alt = getprop("/position/altitude-agl-ft") or 0;
	if(alt < 7.0){
   	me.pasfront.toggle();
   	setprop("/b707/ground-service/enabled", 1);
  }else{
  	setprop("/instrumentation/doors/pasfront/position-norm", 0);
  }
}

Doors.pasrearexport = func {
	var alt = getprop("/position/altitude-agl-ft") or 0;
	if(alt < 7.0){
   	me.pasrear.toggle();
   	setprop("/b707/ground-service/enabled", 1);
  }else{
  	setprop("/instrumentation/doors/pasrear/position-norm", 0);
  }
}

Doors.cargoexport = func {
	var alt = getprop("/position/altitude-agl-ft") or 0;
	var cargoliner = getprop("sim/multiplay/generic/int[9]") or 0;
	if(alt < 7.0 and cargoliner){
   	me.cargo.toggle();
   	setprop("/b707/ground-service/enabled", 1);
  }else{
  	setprop("/instrumentation/doors/cargo/position-norm", 0);
  }
}

Doors.noseexport = func {
	var alt = getprop("/position/altitude-agl-ft") or 0;
	var inside = getprop("sim/current-view/internal") or 0;
	if(alt < 7.0 and !inside){
   	me.nose.toggle();
   	setprop("/b707/ground-service/enabled", 1);
  }else{
  	setprop("/instrumentation/doors/nose/position-norm", 0);
  }
}

Doors.bellyexport = func {
	var alt = getprop("/position/altitude-agl-ft") or 0;
	if(alt < 7.0){
   	me.belly.toggle();
   	setprop("/b707/ground-service/enabled", 1);
  }else{
  	setprop("/instrumentation/doors/belly/position-norm", 0);
  }
}

Doors.refuelexport = func {
  me.refuel.toggle();
	var rh = getprop("/instrumentation/doors/refuel-boom/position-norm") or 0;
	if(rh){
		setprop("/b707/refuelling/boom-telescope-lever",0);
   	interpolate("/b707/refuelling/boom-telescope-lever", -17.0, 0.5);
  }else{
		setprop("/b707/refuelling/boom-telescope-lever",0);
   	interpolate("/b707/refuelling/boom-telescope-lever",  17.0, 0.5);
  }
  
  var the_boom_state = setlistener("/instrumentation/doors/refuel-boom/position-norm", func(bstate)
	{
	if (bstate.getValue() < 0.02 or bstate.getValue() > 0.98)
	 {
		setprop("/b707/refuelling/boom-telescope-lever",0);
	 }
	}, 0, 0);

}


# ==============
# Initialization
# ==============

# objects must be here, otherwise local to init()
doorsystem = Doors.new();
