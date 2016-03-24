#######################################################################################
#		Lake of Constance Hangar :: M.Kraus
#		Boeing 707 for Flightgear Septemper 2013
#		This file is licenced under the terms of the GNU General Public Licence V2 or later
#######################################################################################

var run1 = props.globals.getNode("engines/engine[0]/running");
var run2 = props.globals.getNode("engines/engine[1]/running");
var run3 = props.globals.getNode("engines/engine[2]/running");
var run4 = props.globals.getNode("engines/engine[3]/running");
var auto_procedure = props.globals.initNode("b707/autoprocedure",0,"BOOL");
var step = 0;

# startup/shutdown functions
var startup = func
 {
  if(!auto_procedure.getValue()){
	 	auto_procedure.setValue(1);
	 	step = 1;
	 	t = 0.0;
	 	
	 	screen.log.write("Have a look on engineers panel - External power pluged-in ", 1, 1, 1);
		setprop("controls/engines/engine[0]/cutoff", 1);
		setprop("controls/engines/engine[1]/cutoff", 1);
		setprop("controls/engines/engine[2]/cutoff", 1);
		setprop("controls/engines/engine[3]/cutoff", 1);
	 	setprop("b707/generator/gen-bus-tie[0]", 0);
		setprop("b707/generator/gen-bus-tie[1]", 0);
		setprop("b707/generator/gen-bus-tie[2]", 0);
		setprop("b707/generator/gen-bus-tie[3]", 0);
	 	toggle_switch2();
	 	
	 	t += 1.0;
	 	
		# External Power Unit / see green lights
	 	settimer( func{
	 	  if(step == 1 and auto_procedure.getValue()){
		 		setprop("b707/external-power-connected", 1);
				toggle_switch3();
				step = 2;
			}else{
				step = 0;
				screen.log.write(" Problems with cutoff/bus-tie or fuel system - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 0.5;
		 	
	 	# Battery
	 	settimer( func{
			if(step == 2 and auto_procedure.getValue()){
				setprop("b707/batt-cover", 1);
				toggle_switch3();
				step = 3;
			}else{
				step = 0;
				screen.log.write(" External power problem - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 0.5;
		
		t += 0.5;
	 	settimer( func{
			if(step == 3 and auto_procedure.getValue()){
		 		setprop("b707/battery-switch", 1);
				toggle_switch3();
				step = 4;
			}else{
				step = 0;
				screen.log.write(" Battery cover is broken - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 0.5;
	 	settimer( func{
			if(step == 4 and auto_procedure.getValue()){
				setprop("b707/batt-cover", 0);
				setprop("b707/apu/off-start-run", 0);
				setprop("b707/generator/gen-drive[4]", 0);
				toggle_switch3();
				step = 4;
			}else{
				step = 0;
				screen.log.write(" Battery switch INOP - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 0.5;
		
		# Volt-Loads-Selector
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/load-volt-selector", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/load-volt-selector", 2);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/load-volt-selector", 3);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/load-volt-selector", 4);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/load-volt-selector", 5);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()){ 
		 		setprop("b707/load-volt-selector", 0);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/load-volt-selector", 1);
				toggle_switch3();
			}
		}, t); t += 0.5;
	
		# Essential-Power-Selector
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/ess-power-switch", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/ess-power-switch", 2);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/ess-power-switch", 3);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/ess-power-switch", 4);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/ess-power-switch", 5);
				toggle_switch3();
			}
		}, t); t += 0.5;

		# AC-Paralleling-Selector
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/ac/ac-para-select", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/ac/ac-para-select", 2);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/ac/ac-para-select", 3);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/ac/ac-para-select", 4);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/ac/ac-para-select", 5);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
		 	if(step == 4 and auto_procedure.getValue()) {
		 		setprop("b707/ac/ac-para-select", 6);
				toggle_switch3();
			}
		}, t); t += 0.5;
		
		# Auxilliary Pumps and Hydraulic Pumps Engine 2 and 3
		settimer( func{
			if(step == 4 and auto_procedure.getValue()){
				setprop("/b707/hydraulic/ac-aux-pump[0]", 1);
				toggle_switch3();
			}else{
				step = 0;
				screen.log.write(" Auxilliary 1 Pump INOP - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 4;
		
		settimer( func{
			if(step == 4 and auto_procedure.getValue()){
				setprop("/b707/hydraulic/ac-aux-pump[1]", 1);
				toggle_switch3();
			}else{
				step = 0;
				screen.log.write(" Auxilliary 2 Pump INOP - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 10;
		
		settimer( func{
			if(step == 4 and auto_procedure.getValue()){
				setprop("/b707/hydraulic/brake-valve", 2);
				toggle_switch3();
			}else{
				step = 0;
				screen.log.write(" Auxilliary Connect Valve INOP - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 0.5;

		settimer( func{
			if(step == 4 and auto_procedure.getValue()){
				setprop("/b707/hydraulic/hyd-fluid-shutoff-cover[0]", 1);
				toggle_switch3();
			}else{
				step = 0;
				screen.log.write(" Hydraulic Shutoff Cover INOP - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 0.2;

		settimer( func{
			if(step == 4 and auto_procedure.getValue()){
				setprop("/b707/hydraulic/hyd-fluid-shutoff-cover[1]", 1);
				toggle_switch3();
			}else{
				step = 0;
				screen.log.write(" Hydraulic Shutoff Cover INOP - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 0.2;
		
		settimer( func{
			if(step == 4 and auto_procedure.getValue()){
				setprop("/b707/hydraulic/hyd-fluid-shutoff[0]", 1);
				toggle_switch3();
			}else{
				step = 0;
				screen.log.write(" Hydraulic Shutoff INOP - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 0.2;
		
		settimer( func{
			if(step == 4 and auto_procedure.getValue()){
				setprop("/b707/hydraulic/hyd-fluid-shutoff[1]", 1);
				toggle_switch3();
			}else{
				step = 0;
				screen.log.write(" Hydraulic Shutoff INOP - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 0.2;

		settimer( func{
			if(step == 4 and auto_procedure.getValue()){
				setprop("/b707/hydraulic/hyd-fluid-shutoff-cover[0]", 0);
				toggle_switch3();
			}else{
				step = 0;
				screen.log.write(" Hydraulic Shutoff Cover INOP - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 0.2;

		settimer( func{
			if(step == 4 and auto_procedure.getValue()){
				setprop("/b707/hydraulic/hyd-fluid-shutoff-cover[1]", 0);
				toggle_switch3();
			}else{
				step = 0;
				screen.log.write(" Hydraulic Shutoff Cover INOP - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 0.2;
		
		settimer( func{
			if(step == 4 and auto_procedure.getValue()){
				setprop("/b707/hydraulic/hyd-fluid-pump[0]", 1);
				toggle_switch3();
			}else{
				step = 0;
				screen.log.write(" Hydraulic Pump for Engine 2 INOP - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 4;
		
		settimer( func{
			if(step == 4 and auto_procedure.getValue()){
				setprop("/b707/hydraulic/hyd-fluid-pump[1]", 1);
				step = 5;
				toggle_switch3();
			}else{
				step = 0;
				screen.log.write(" Hydraulic Pump for Engine 3 INOP - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 8;
		
		# Gen Drive
		settimer( func{
		 	if(step == 5 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-drive-cover[0]", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 5 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-drive-cover[1]", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 5 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-drive-cover[2]", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 5 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-drive-cover[3]", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 5 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-drive[3]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 5 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-drive[2]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 5 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-drive[1]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 5 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-drive[0]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 5 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-drive-cover[0]", 0);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 5 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-drive-cover[1]", 0);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 5 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-drive-cover[2]", 0);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 5 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-drive-cover[3]", 0);
				toggle_switch3();
				step = 6;
			}
		}, t); t += 0.8;

		# external power to Power Bus Tie (sync bus)
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/ground-connect", 1);
				toggle_switch2();
			}else{
				step = 0;
				screen.log.write(" No External Power Unit found on bus - startup interrupted ", 1, 0, 0);
			}
		}, t); t += 0.2;
	
		# Gen Control
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-control-cover[0]", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-control-cover[1]", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-control-cover[2]", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-control-cover[3]", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-control[3]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-control[2]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-control[1]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-control[0]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-control-cover[0]", 0);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-control-cover[1]", 0);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-control-cover[2]", 0);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-control-cover[3]", 0);
				toggle_switch3();
			}
		}, t); t += 0.2;
		
	
		# Gen bus-tie
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-bus-tie-cover[0]", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-bus-tie-cover[1]", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-bus-tie-cover[2]", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-bus-tie-cover[3]", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-bus-tie[3]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-bus-tie[2]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-bus-tie[1]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-bus-tie[0]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-bus-tie-cover[0]", 0);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-bus-tie-cover[1]", 0);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-bus-tie-cover[2]", 0);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
		 	if(step == 6 and auto_procedure.getValue()) {
				setprop("b707/generator/gen-bus-tie-cover[3]", 0);
				toggle_switch3();
			}
		}, t); t += 0.2;
	
		# Gen - Breaker, so engines generator ar ready for start the engine
		settimer( func{
			if(step == 6 and auto_procedure.getValue()){
				setprop("b707/generator/gen-breaker[3]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 6 and auto_procedure.getValue()){
				setprop("b707/generator/gen-breaker[2]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 6 and auto_procedure.getValue()){
				setprop("b707/generator/gen-breaker[1]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 6 and auto_procedure.getValue()){
				setprop("b707/generator/gen-breaker[0]", 1);
				toggle_switch2();				
				step = 7;
			}
		}, t); t += 1.2;
		
		# The fuel valves
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/valve[0]", 1);
				b707.valve_pos(0);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/valve[1]", 1);
				b707.valve_pos(1);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/valve[2]", 1);
				b707.valve_pos(2);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/valve[3]", 1);
				b707.valve_pos(3);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/valve[4]", 1);
				b707.valve_pos(4);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/valve[5]", 1);
				b707.valve_pos(5);
				toggle_switch3();
			}
		}, t); t += 0.8;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/valve[0]", 0);
				b707.valve_pos(0);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/valve[1]", 0);
				b707.valve_pos(1);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/valve[2]", 0);
				b707.valve_pos(2);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/valve[3]", 0);
				b707.valve_pos(3);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/valve[4]", 0);
				b707.valve_pos(4);
				toggle_switch3();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/valve[5]", 0);
				b707.valve_pos(5);
				toggle_switch3();
			}
		}, t); t += 0.8;
		
		# the fuel boost-pumps
				settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/boost-pump[0]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/boost-pump[1]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/boost-pump[2]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/boost-pump[3]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/boost-pump[4]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/boost-pump[5]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/boost-pump[6]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/boost-pump[7]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/boost-pump[8]", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/boost-pump[9]", 1);
				toggle_switch2();
			}
		}, t); t += 0.5;
		
		# the fuel shutoff-valves
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/fuel-shutoff[0]", 1);
				b707.shutoff_pos(0);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/fuel-shutoff[1]", 1);
				b707.shutoff_pos(1);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/fuel-shutoff[2]", 1);
				b707.shutoff_pos(2);
				toggle_switch2();
			}
		}, t); t += 0.2;
		settimer( func{
			if(step == 7 and auto_procedure.getValue()){
				setprop("/b707/fuel/valves/fuel-shutoff[3]", 1);
				b707.shutoff_pos(3);
				toggle_switch2();				
				screen.log.write("Look down to your throttle levers on center pedestal.", 1, 1, 1);
				step = 8;
			}
		}, t); t += 2.5;

		# throttle levers
		settimer( func{
			if(step == 8 and auto_procedure.getValue()){
			interpolate("controls/engines/engine[0]/throttle", 0.25, 0.4);
			interpolate("controls/engines/engine[1]/throttle", 0.25, 0.4);
			interpolate("controls/engines/engine[2]/throttle", 0.25, 0.4);
			interpolate("controls/engines/engine[3]/throttle", 0.25, 0.4);
			}
		}, t); t += 1.0;
	
		settimer( func{
			if(step == 8 and auto_procedure.getValue()){
				setprop("controls/engines/engine[0]/cutoff", 1);
				toggle_switch2();
			}
		}, t); t += 0.5;
		settimer( func{
			if(step == 8 and auto_procedure.getValue()){
				setprop("controls/engines/engine[1]/cutoff", 1);
				toggle_switch2();
			}
		}, t); t += 0.5;
		settimer( func{
			if(step == 8 and auto_procedure.getValue()){
				setprop("controls/engines/engine[2]/cutoff", 1);
				toggle_switch2();
			}
		}, t); t += 0.5;	
		settimer( func{
			if(step == 8 and auto_procedure.getValue()){
				setprop("controls/engines/engine[3]/cutoff", 1);
				toggle_switch2();
				screen.log.write("We continue at the overhead panel.", 1, 1, 1);
				step = 9;
			}
		}, t); t += 1.5;

		# Starter in the overhead panel
		settimer( func{
			if(step == 9 and auto_procedure.getValue()){
				setprop("b707/start/startercover[2]", 1);
				toggle_switch3();
			}
		}, t); t += 0.5;
		settimer( func{
			if(step == 9 and auto_procedure.getValue()){
			setprop("controls/engines/engine[2]/starter", 1);
			toggle_switch2();
			}else{
				screen.log.write("WARNING: startup interrupted before ENGINE 3 ", 1, 0, 0);
			}
		}, t); t += 6.0;
		settimer(func{
			if(step == 9 and auto_procedure.getValue()){
				setprop("controls/engines/engine[2]/cutoff", 0);
			}
		}, t); t += 29.5;	
		settimer( func{
			if(step == 9 and auto_procedure.getValue()){
				setprop("b707/start/startercover[2]", 0);
				toggle_switch3();
				step = 10;
			}
		}, t); t += 0.5; # 30 sec per engine

		settimer( func{	  
			if(step == 10 and auto_procedure.getValue()){
				setprop("b707/start/startercover[3]", 1);
				toggle_switch3();
			}
		}, t); t += 0.5;
		settimer( func{
			if(step == 10 and auto_procedure.getValue() and run3.getBoolValue()){
				setprop("controls/engines/engine[3]/starter", 1);
				toggle_switch2();
			}else{
				screen.log.write("WARNING: startup interrupted at ENGINE 3 ", 1, 0, 0);
			}
		}, t); t += 6.0;
		settimer(func{
			if(step == 10 and auto_procedure.getValue()){
				setprop("controls/engines/engine[3]/cutoff", 0);
			}
		}, t); t += 29.5;	
		settimer( func{
			if(step == 10 and auto_procedure.getValue()){
				setprop("b707/start/startercover[3]", 0);
				toggle_switch3();
				step = 11;
			}
		}, t); t += 0.5; # 30 sec per engine 	
	
		settimer( func{	  
			if(step == 11 and auto_procedure.getValue()){
				setprop("b707/start/startercover[1]", 1);
				toggle_switch3();
			}
		}, t); t += 0.5;
		settimer( func{
			if(step == 11 and auto_procedure.getValue() and run3.getBoolValue() and run4.getBoolValue()){
				setprop("controls/engines/engine[1]/starter", 1);
				toggle_switch2();
			}else{
				screen.log.write("WARNING: startup interrupted at ENGINE 4 ", 1, 0, 0);
			}
		}, t); t += 6.0;
		settimer(func{
			if(step == 11 and auto_procedure.getValue()){
				setprop("controls/engines/engine[1]/cutoff", 0);
			}
		}, t); t += 29.5;	
		settimer( func{
			if(step == 11 and auto_procedure.getValue()){
				setprop("b707/start/startercover[1]", 0);
				toggle_switch3();
				step = 12;
			}
		}, t); t += 0.5; # 30 sec per engine 

		settimer( func{	  
			if(step == 12 and auto_procedure.getValue()){
				setprop("b707/start/startercover[0]", 1);
				toggle_switch3();
			}
		}, t); t += 0.5;
		settimer( func{
			if(step == 12 and auto_procedure.getValue() and run2.getBoolValue() and run3.getBoolValue() and run4.getBoolValue()){
				setprop("controls/engines/engine[0]/starter", 1);
				toggle_switch2();
			}else{
				screen.log.write("WARNING: startup interrupted at ENGINE 2 ", 1, 0, 0);
			}
		}, t); t += 6.0;
		settimer(func{
			if(step == 12 and auto_procedure.getValue()){
				setprop("controls/engines/engine[0]/cutoff", 0);
			}
		}, t); t += 29.5;
		settimer( func{
			if(step == 12 and auto_procedure.getValue()){
				setprop("b707/start/startercover[0]", 0);
				toggle_switch3();
				screen.log.write("Synchronisation of the engines now - have a look to the engineer panel", 1, 1, 1);
				step = 13;
			}
		}, t); t += 1.5; # 30 sec per engine 
		 
		# synchronized the generator one and select this engine as ess-pwr
	 	settimer( func{		
			if(step == 13 and auto_procedure.getValue()){
		 		setprop("b707/ac/ac-para-select", 1);
				toggle_switch3();
			}
		}, t); t += 1.5;

	 	settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
				interpolate("b707/generator/gen-freq[0]",400, 1.0);
			}	
		}, t); t += 1.0;
	
	 	settimer( func{		
			if(step == 13 and auto_procedure.getValue()){
		 		setprop("b707/ac/ac-para-select", 2);
				toggle_switch3();
			}
		}, t); t += 1.5;

	 	settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
				interpolate("b707/generator/gen-freq[1]",400, 1.0);
			}	
		}, t); t += 1.0;
	
	 	settimer( func{		
			if(step == 13 and auto_procedure.getValue()){
		 		setprop("b707/ac/ac-para-select", 3);
				toggle_switch3();
			}
		}, t); t += 1.5;
	
	 	settimer( func{		
			if(step == 13 and auto_procedure.getValue()){
		 		setprop("b707/ac/ac-para-select", 4);
				toggle_switch3();
			}
		}, t); t += 0.5;

	 	settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
				interpolate("b707/generator/gen-freq[2]",400, 1.0);
			}	
		}, t); t +=  1.0;
	
	 	settimer( func{		
			if(step == 13 and auto_procedure.getValue()){
		 		setprop("b707/ac/ac-para-select", 5);
				toggle_switch3();
			}
		}, t); t += 1.5;

	 	settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
				interpolate("b707/generator/gen-freq[3]",400, 1.0);
			}	
		}, t); t += 1.0;
		
	 	settimer( func{
		 	if(step == 13 and auto_procedure.getValue()) {
		 		setprop("b707/ac/ac-para-select", 6);
				toggle_switch3();
			}
		}, t); t += 0.2;
		
	 	settimer( func{
		 	if(step == 13 and auto_procedure.getValue()) {
		 		setprop("b707/ac/ac-para-select", 0);
				toggle_switch3();
			}
		}, t); t += 0.2;
		
	 	settimer( func{
		 	if(step == 13 and auto_procedure.getValue()) {
		 		setprop("b707/ac/ac-para-select", 1);
				toggle_switch3();
			}
		}, t); t += 0.5;
		
		# switch generators to the sync bus now
	 	settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
		 		setprop("b707/generator/gen-bus-tie-cover[0]", 1);
				toggle_switch3();
			}
		}, t); t += 0.5;
		settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
				setprop("b707/generator/gen-bus-tie[0]", 1);
				toggle_switch2();
			}
		}, t); t += 0.5;
		settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
				setprop("b707/generator/gen-bus-tie-cover[0]", 0);
				toggle_switch3();
			}	
		}, t); t += 0.5;
	
	 	settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
		 		setprop("b707/generator/gen-bus-tie-cover[1]", 1);
				toggle_switch3();
			}
		}, t); t += 0.5;
		settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
				setprop("b707/generator/gen-bus-tie[1]", 1);
				toggle_switch2();
			}
		}, t); t += 0.5;
		settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
				setprop("b707/generator/gen-bus-tie-cover[1]", 0);
				toggle_switch3();
			}	
		}, t); t += 0.5;
	
	 	settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
		 		setprop("b707/generator/gen-bus-tie-cover[2]", 1);
				toggle_switch3();
			}
		}, t); t += 0.5;
		settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
				setprop("b707/generator/gen-bus-tie[2]", 1);
				toggle_switch2();
			}
		}, t); t += 0.5;
		settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
				setprop("b707/generator/gen-bus-tie-cover[2]", 0);
				toggle_switch3();
			}	
		}, t); t += 0.5;
	
	 	settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
		 		setprop("b707/generator/gen-bus-tie-cover[3]", 1);
				toggle_switch3();
			}
		}, t); t += 0.5;
		settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
				setprop("b707/generator/gen-bus-tie[3]", 1);
				toggle_switch2();
			}
		}, t); t += 0.5;
		settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
				setprop("b707/generator/gen-bus-tie-cover[3]", 0);
				toggle_switch3();
			}	
		}, t); t += 1.0;
	
		# Essential-Power-Selector
	 	settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
		 		setprop("b707/ess-power-switch", 4);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
		 		setprop("b707/ess-power-switch", 3);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
		 		setprop("b707/ess-power-switch", 2);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{
	 		if(step == 13 and auto_procedure.getValue()){
		 		setprop("b707/ess-power-switch", 1);
				step = 14;
				toggle_switch3();
			}
		}, t); t += 0.5;		

		# external power disconnected Power Bus Tie (sync bus)
		settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
				setprop("b707/ground-connect", 0);
				toggle_switch2();
			}
		}, t); t += 1.0;
	
		# plug out
	 	settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
		 		setprop("b707/external-power-connected", 0);
				setprop("/b707/hydraulic/brake-valve", 0);
				toggle_switch3();
			}
		}, t); t += 1.5;
		
		# equipment cooling
	 	settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
		 		setprop("/b707/generator/hertz-converter", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;		
	 	settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
		 		setprop("/b707/equipment/blower", 1);
				toggle_switch2();
			}
		}, t); t += 0.2;
	 	settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
		 		setprop("/b707/equipment/ovbd-dump", 1);
				toggle_switch2();
			}
		}, t); t += 0.5;
	
	  # compressors
	  settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
		 		setprop("/b707/air-conditioning/ram-air-switch", 1);
				toggle_switch2();
			}
		}, t); t += 0.5;	  
	  settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
				setprop("/b707/air-conditioning/compressor-start[0]", 2);
				setprop("/b707/air-conditioning/compressor-rpm[0]", 110);
				toggle_switch2();
			}
		}, t); t += 0.5;	
	  settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
				setprop("/b707/air-conditioning/compressor-start[1]", 2);
				setprop("/b707/air-conditioning/compressor-rpm[1]", 95);
				toggle_switch2();
			}
		}, t); t += 0.5;		
	  settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
				setprop("/b707/air-conditioning/compressor-start[2]", 2);
				setprop("/b707/air-conditioning/compressor-rpm[2]", 104);
				toggle_switch2();
			}
		}, t); t += 0.5;

	  settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
				setprop("/b707/air-conditioning/air-cond-unit-left-start",1);
				toggle_switch2();
			}
		}, t); t += 0.5;		

	  settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
				setprop("/b707/air-conditioning/air-cond-unit-right-start",1);
				toggle_switch2();
			}
		}, t); t += 0.5;			

	  settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
				setprop("/b707/air-conditioning/wing-valve[0]",1);
				toggle_switch2();
			}
		}, t); t += 0.5;			

	  settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
				setprop("/b707/air-conditioning/wing-valve[1]",1);
				toggle_switch2();
			}
		}, t); t += 0.5;			

	  settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
				setprop("/b707/air-conditioning/cabin-temp-selector[0]",4);
				toggle_switch2();
			}
		}, t); t += 0.5;			

	  settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
				setprop("/b707/air-conditioning/cabin-temp-selector[1]",4);
				setprop("/b707/emergency/oxygen-switch",2);
				toggle_switch2();
			}
		}, t); t += 0.5;			

		# safety-valve switch
	 	settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
		 		setprop("/b707/pressurization/safety-valve-cover", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;
	 	settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
		 		setprop("/b707/pressurization/safety-valve", 1);
				b707.safety_valv_pos();
				toggle_switch2();
			}
		}, t); t += 0.2;
	 	settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
		 		setprop("/b707/pressurization/safety-valve-cover", 0);
				toggle_switch3();
			}
		}, t); t += 0.5;	
				
		# cabin pressurization to AUTO
	 	settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
		 		setprop("/b707/pressurization/manual-mode-switch", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;	
	 	settimer( func{ 		
			if(step == 14 and auto_procedure.getValue()){
		 		setprop("/b707/pressurization/mode-switch", 1);
				toggle_switch3();
			}
		}, t); t += 0.2;		

		 # lights on 
		 if(getprop("sim/time/sun-angle-rad") > 1.55){
		 	settimer( func{
		 		screen.log.write("Switch lighting in the overhead panel.", 1, 1, 1);
				setprop("controls/lighting/beacon", 1);
				toggle_switch2();
			}, t); t += 0.5;
		 	settimer( func{
				setprop("controls/lighting/landing-light[0]", 1);
				toggle_switch2();
			}, t); t += 0.5;
		 	settimer( func{
				setprop("controls/lighting/landing-light[1]", 1);
				toggle_switch2();
			}, t); t += 0.5;
		 	settimer( func{
				setprop("controls/lighting/landing-light[2]", 1);
				toggle_switch2();
			}, t); t += 0.5;
		 	settimer( func{
				setprop("controls/lighting/nav-lights", 1);
				toggle_switch2();
			}, t); t += 0.5;
		 	settimer( func{
				setprop("controls/lighting/cabin-lights", 1);
				toggle_switch2();
			}, t); t += 0.5;
		 	settimer( func{
				interpolate("controls/lighting/cabin-dim", 0.8,0.5);
				toggle_switch2();
			}, t); t += 0.5;
		 	settimer( func{
				setprop("controls/lighting/strobe", 1);
				toggle_switch2();
			}, t); t += 0.5;

		 }else{
			 	settimer( func{
					setprop("controls/lighting/beacon", 1);
					toggle_switch2();
				}, t); t += 0.5;
			 	settimer( func{
					setprop("controls/lighting/nav-lights", 1);
					toggle_switch2();
				}, t); t += 0.5;  
		 }    
			# switch on the FlightRallyeMode
			var frwKnob = getprop("instrumentation/frw/btn-mode");
			if (frwKnob == 0) {
				setprop("instrumentation/frw/btn-mode",1);
				b707.frw_mode();
			}
			
				# always after startup
			settimer( func{
				auto_procedure.setValue(0);
			}, t);
		
		}else{
			screen.log.write("The Automatical Start Procedure is allready running. Please wait!", 1, 0, 0);
		}
 };

var shutdown = func
 {
	 	if(!auto_procedure.getValue()){
			setprop("b707/generator/gen-drive[0]", 0);
			setprop("b707/generator/gen-drive[1]", 0);
			setprop("b707/generator/gen-drive[2]", 0);
			setprop("b707/generator/gen-drive[3]", 0);
			setprop("b707/generator/gen-drive[4]", 0);
		 	setprop("b707/generator/gen-bus-tie[0]", 0);
			setprop("b707/generator/gen-bus-tie[1]", 0);
			setprop("b707/generator/gen-bus-tie[2]", 0);
			setprop("b707/generator/gen-bus-tie[3]", 0);				
			setprop("/b707/generator/gen-breaker[0]", 0);			
			setprop("/b707/generator/gen-breaker[1]", 0);			
			setprop("/b707/generator/gen-breaker[2]", 0);			
			setprop("/b707/generator/gen-breaker[3]", 0);
		 	setprop("b707/generator/gen-control[0]", 0);
			setprop("b707/generator/gen-control[1]", 0);
			setprop("b707/generator/gen-control[2]", 0);
			setprop("b707/generator/gen-control[3]", 0);
		 	setprop("b707/generator/gen-freq[0]", 0);
			setprop("b707/generator/gen-freq[1]", 0);
			setprop("b707/generator/gen-freq[2]", 0);
			setprop("b707/generator/gen-freq[3]", 0);
			setprop("controls/engines/engine[0]/cutoff", 1);
			setprop("controls/engines/engine[1]/cutoff", 1);
			setprop("controls/engines/engine[2]/cutoff", 1);
			setprop("controls/engines/engine[3]/cutoff", 1);
			setprop("/controls/wiper/degrees",0);
			setprop("b707/apu/off-start-run", 0);
	
			screen.log.write("The Aircraft Engines have been shut down.", 1, 1, 1);
		
		}else{
				screen.log.write("The Automatical Start Procedure is allready running. Please wait!", 1, 0, 0);
		}
 };

# listener to activate these functions accordingly
setlistener("sim/model/start-idling", func(idle)
 {
 var autorun = idle.getBoolValue();
 
 if (autorun and !run1.getBoolValue() and !run2.getBoolValue() and !run3.getBoolValue() and !run4.getBoolValue())
  {
  startup();
  }
 else
  {
  shutdown();
  }
 }, 0, 0);
 
## START PROCEDURE ON MAIN SWITCHES ###
#######################################
var starter = func(nr)
 {
 	var s_bat = getprop("b707/battery-switch") or 0;
	var s_ext_con = getprop("b707/external-power-connected") or 0;
	var s_ess_pwr = getprop("b707/ess-power-switch") or 0;
	var s_ess_bus = getprop("b707/ess-bus") or 0;
	var s_ground_c = getprop("b707/ground-connect") or 0;
	var s_par_sel = getprop("b707/ac/ac-para-select") or 0;
	var s_apu_start = getprop("b707/apu/off-start-run") or 0;
	var s_apu_gen = getprop("b707/generator/gen-drive[4]") or 0;			
	var s_bus_tie = getprop("/b707/generator/gen-bus-tie["~nr~"]") or 0;
	var s_gen_bre = getprop("/b707/generator/gen-breaker["~nr~"]") or 0;
	var s_bus_con = getprop("/b707/generator/gen-control["~nr~"]") or 0;
	
	if(s_bat and s_ess_bus > 20 and s_gen_bre and s_bus_tie and s_bus_con and
			((s_ext_con and s_ess_pwr == 5 and s_ground_c == 1) or
		 	 ( s_ess_pwr == 0 and s_apu_start == 2 and s_apu_gen) or
		 	 ((run1.getBoolValue() and s_ess_pwr == 1) or 
		 	  (run2.getBoolValue() and s_ess_pwr == 2) or 
		 	  (run3.getBoolValue() and s_ess_pwr == 3) or 
		 	  (run4.getBoolValue() and s_ess_pwr == 4) ))){
	
			# not supported the fuel system for the moment
			setprop("controls/engines/engine["~nr~"]/starter", 0);
			setprop("controls/engines/engine["~nr~"]/cutoff", 1);
			setprop("controls/engines/engine["~nr~"]/starter", 1);
			setprop("controls/engines/engine["~nr~"]/started", 1);
			setprop("b707/generator/gen-freq["~nr~"]", b707.my_rand(384,418));
			
			if(auto_procedure.getValue()){
				settimer(func
				{
					setprop("controls/engines/engine["~nr~"]/cutoff", 0);
				}, 1.2);
			}
			
			# fake highpressure and crossfeed pressure startup - instrument in engineer panel
			if(nr == 2 or nr == 3) interpolate("b707/start-air-bottle-press[0]",0, 15);
			if(nr == 1 or nr == 0) interpolate("b707/start-air-bottle-press[1]",0, 15);
			settimer(func
			{
				if(nr == 2 or nr == 3) interpolate("b707/start-air-bottle-press[0]",2870,7);
				if(nr == 1 or nr == 0) interpolate("b707/start-air-bottle-press[1]",2930,8);
			}, 22);
	
	}else{
		setprop("controls/engines/engine["~nr~"]/starter", 0);
		setprop("b707/generator/gen-freq["~nr~"]",0);
	}
		
};

setlistener("b707/start/startercover[2]", func(open)
 {
 	var open = open.getBoolValue();
 	var s_bat = getprop("b707/battery-switch") or 0;
	var s_ext_con = getprop("b707/external-power-connected") or 0;
	var s_ess_pwr = getprop("b707/ess-power-switch") or 0;
	var s_ess_bus = getprop("b707/ess-bus") or 0;
	var s_ground_c = getprop("b707/ground-connect") or 0;
	var s_par_sel = getprop("b707/ac/ac-para-select") or 0;
	var s_apu_start = getprop("b707/apu/off-start-run") or 0;
	var s_apu_gen = getprop("b707/generator/gen-drive[4]") or 0;			
	var s_bus_tie = getprop("/b707/generator/gen-bus-tie[2]") or 0;
	var s_gen_bre = getprop("/b707/generator/gen-breaker[2]") or 0;
	
	if(open and s_bat and s_ess_bus > 20 and s_gen_bre and s_bus_tie and 
			((s_ext_con and s_ess_pwr == 5 and s_ground_c == 1) or
		 	 ( s_ess_pwr == 0 and s_apu_start == 2 and s_apu_gen))
		){
	 setprop("controls/engines/engine[2]/msg", 1);
	}
 }, 0, 0); 

setlistener("controls/engines/engine[0]/starter", func
 {
 	if(!run1.getBoolValue()){
	 starter(0);
	}
 }, 0, 0);
 
setlistener("controls/engines/engine[1]/starter", func
 {

 	if(!run2.getBoolValue()){
	 starter(1);
	}
 }, 0, 0);
 
setlistener("controls/engines/engine[2]/starter", func
 {
 	if(!run3.getBoolValue()){
	 starter(2);
	}
 }, 0, 0); 
 
setlistener("controls/engines/engine[3]/starter", func
 {
 	if(!run4.getBoolValue()){
	 starter(3);
	}
 }, 0, 0);

setlistener("engines/engine[0]/running", func
 {
 	if(run1.getBoolValue()){
	 setprop("controls/engines/msg", 2);
	}else{
	 setprop("controls/engines/engine[0]/msg", 0);
	 setprop("controls/engines/engine[1]/msg", 0);
	 setprop("controls/engines/engine[2]/msg", 0);
	 setprop("controls/engines/engine[3]/msg", 0);
	 setprop("controls/engines/msg", 0);
	 if(getprop("controls/engines/engine[0]/started")){  # started control engines stop after running
    	 	setprop("b707/generator/gen-drive[0]", 0);
    	 	setprop("b707/generator/gen-bus-tie[0]", 0);
				setprop("b707/generator/gen-breaker[0]", 0);
				setprop("b707/generator/gen-control[0]", 0);	 
	 };
	}
 }, 0, 0);
 
setlistener("engines/engine[1]/running", func
 {
 	if(run2.getBoolValue()){
	 setprop("controls/engines/engine[0]/msg", 1);
	}else{
	 setprop("controls/engines/engine[0]/msg", 0);
	 setprop("controls/engines/engine[1]/msg", 0);
	 setprop("controls/engines/engine[2]/msg", 0);
	 setprop("controls/engines/engine[3]/msg", 0);
	 setprop("controls/engines/msg", 0);
	 if(getprop("controls/engines/engine[1]/started")){  # started control engines stop after running
    	 	setprop("b707/generator/gen-drive[1]", 0);
    	 	setprop("b707/generator/gen-bus-tie[1]", 0);
				setprop("b707/generator/gen-breaker[1]", 0);
				setprop("b707/generator/gen-control[1]", 0);	 
	 };
	}
 }, 0, 0);
 
setlistener("engines/engine[2]/running", func
 {
 	if(run3.getBoolValue()){
	 setprop("controls/engines/engine[3]/msg", 1);
	}else{
	 setprop("controls/engines/engine[0]/msg", 0);
	 setprop("controls/engines/engine[1]/msg", 0);
	 setprop("controls/engines/engine[2]/msg", 0);
	 setprop("controls/engines/engine[3]/msg", 0);
	 setprop("controls/engines/msg", 0);
	 if(getprop("controls/engines/engine[2]/started")){  # started control engines stop after running
    	 	setprop("b707/generator/gen-drive[2]", 0);
    	 	setprop("b707/generator/gen-bus-tie[2]", 0);
				setprop("b707/generator/gen-breaker[2]", 0);
				setprop("b707/generator/gen-control[2]", 0);	 
	 };
	}
 }, 0, 0); 
 
setlistener("engines/engine[3]/running", func
 {
 	if(run4.getBoolValue()){
	 setprop("controls/engines/engine[1]/msg", 1);
	}else{
	 setprop("controls/engines/engine[0]/msg", 0);
	 setprop("controls/engines/engine[1]/msg", 0);
	 setprop("controls/engines/engine[2]/msg", 0);
	 setprop("controls/engines/engine[3]/msg", 0);
	 setprop("controls/engines/msg", 0);
	 if(getprop("controls/engines/engine[3]/started")){  # started control engines stop after running
    	 	setprop("b707/generator/gen-drive[3]", 0);
    	 	setprop("b707/generator/gen-bus-tie[3]", 0);
				setprop("b707/generator/gen-breaker[3]", 0);
				setprop("b707/generator/gen-control[3]", 0);	 
	 };
	}
 }, 0, 0);
 

var toggle_switch2 = func{

	if(getprop("/sim/sound/switch2") == 1){
  	 setprop("/sim/sound/switch2", 0); 
  }else{
  	 setprop("/sim/sound/switch2", 1);
  }

}

var toggle_switch3 = func{

	if(getprop("/sim/sound/switch3") == 1){
  	 setprop("/sim/sound/switch3", 0); 
  }else{
  	 setprop("/sim/sound/switch3", 1);
  }

}


######################## short Startup for testflight #################################

var short_startup = func
 {
 	setprop("b707/battery-switch", 1);		
 	setprop("b707/external-power-connected", 0);
	setprop("b707/ground-connect", 0);
	setprop("b707/ess-power-switch", 0);
	setprop("b707/ac/ac-para-select", 0);
 	setprop("b707/apu/starter", 1);
	setprop("b707/load-volt-selector", 1);
	setprop("instrumentation/transponder/inputs/knob-mode", 4);
	
   settimer(func
    {	
			setprop("engines/APU/rpm", 95);
    }, 0.5);
	
   settimer(func
    {	
		b707.apu_gen_switch();

		setprop("/b707/hydraulic/ac-aux-pump[0]", 1);
		setprop("/b707/hydraulic/ac-aux-pump[1]", 1);
		setprop("/b707/hydraulic/hyd-fluid-shutoff[0]", 1);
		setprop("/b707/hydraulic/hyd-fluid-shutoff[1]", 1);
		setprop("/b707/hydraulic/hyd-fluid-pump[0]", 1);
		setprop("/b707/hydraulic/hyd-fluid-pump[1]", 1);
	
		setprop("b707/generator/gen-drive[0]", 1);
		setprop("b707/generator/gen-drive[1]", 1);
		setprop("b707/generator/gen-drive[2]", 1);
		setprop("b707/generator/gen-drive[3]", 1);
	 	setprop("b707/generator/gen-bus-tie[0]", 1);
		setprop("b707/generator/gen-bus-tie[1]", 1);
		setprop("b707/generator/gen-bus-tie[2]", 1);
		setprop("b707/generator/gen-bus-tie[3]", 1);
		setprop("b707/generator/gen-breaker[0]", 1);
		setprop("b707/generator/gen-breaker[1]", 1);
		setprop("b707/generator/gen-breaker[2]", 1);
		setprop("b707/generator/gen-breaker[3]", 1);
		setprop("b707/generator/gen-control[0]", 1);
		setprop("b707/generator/gen-control[1]", 1);
		setprop("b707/generator/gen-control[2]", 1);
		setprop("b707/generator/gen-control[3]", 1);
	
		setprop("/b707/fuel/valves/valve[0]", 0);
		b707.valve_pos(0);
		setprop("/b707/fuel/valves/valve[1]", 0);
		b707.valve_pos(1);
		setprop("/b707/fuel/valves/valve[2]", 0);
		b707.valve_pos(2);
		setprop("/b707/fuel/valves/valve[3]", 0);
		b707.valve_pos(3);
		setprop("/b707/fuel/valves/valve[4]", 0);
		b707.valve_pos(4);
		setprop("/b707/fuel/valves/valve[5]", 0);
		b707.valve_pos(5);
	
		setprop("/b707/fuel/valves/boost-pump[0]", 1);
		setprop("/b707/fuel/valves/boost-pump[1]", 1);
		setprop("/b707/fuel/valves/boost-pump[2]", 1);
		setprop("/b707/fuel/valves/boost-pump[3]", 1);
		setprop("/b707/fuel/valves/boost-pump[4]", 1);
		setprop("/b707/fuel/valves/boost-pump[5]", 1);
		setprop("/b707/fuel/valves/boost-pump[6]", 1);
		setprop("/b707/fuel/valves/boost-pump[7]", 1);
		setprop("/b707/fuel/valves/boost-pump[8]", 1);
		setprop("/b707/fuel/valves/boost-pump[9]", 1);
	
		setprop("/b707/fuel/valves/fuel-shutoff[0]", 1);
		b707.shutoff_pos(0);
		setprop("/b707/fuel/valves/fuel-shutoff[1]", 1);
		b707.shutoff_pos(1);
		setprop("/b707/fuel/valves/fuel-shutoff[2]", 1);
		b707.shutoff_pos(2);
		setprop("/b707/fuel/valves/fuel-shutoff[3]", 1);
		b707.shutoff_pos(3);
	
		setprop("controls/engines/engine[0]/throttle", 0.25);
		setprop("controls/engines/engine[1]/throttle", 0.25);
		setprop("controls/engines/engine[2]/throttle", 0.25);
		setprop("controls/engines/engine[3]/throttle", 0.25);
		setprop("controls/engines/engine[0]/cutoff", 1);
		setprop("controls/engines/engine[1]/cutoff", 1);
		setprop("controls/engines/engine[2]/cutoff", 1);
		setprop("controls/engines/engine[3]/cutoff", 1);
		setprop("controls/engines/engine[0]/starter", 1);
		setprop("controls/engines/engine[1]/starter", 1);
		setprop("controls/engines/engine[2]/starter", 1);
		setprop("controls/engines/engine[3]/starter", 1);
    }, 4);

   settimer(func
    {
			setprop("controls/engines/engine[0]/cutoff", 0);
			setprop("controls/engines/engine[1]/cutoff", 0);
			setprop("controls/engines/engine[2]/cutoff", 0);
			setprop("controls/engines/engine[3]/cutoff", 0);
    }, 14);
    

   settimer(func
    {
      setprop("/b707/air-conditioning/ram-air-switch",1);
      b707.air_compressor(0);
      b707.air_compressor(1);
      b707.air_compressor(2);
      setprop("/b707/air-conditioning/compressor-rpm[1]",105);
      setprop("/b707/air-conditioning/compressor-rpm[2]",108);
    	setprop("b707/generator/gen-freq[0]", 400);
			setprop("b707/generator/gen-freq[1]", 400);
			setprop("b707/generator/gen-freq[2]", 400);
			setprop("b707/generator/gen-freq[3]", 400);
		 	setprop("b707/generator/gen-bus-tie[0]", 1);
			setprop("b707/generator/gen-bus-tie[1]", 1);
			setprop("b707/generator/gen-bus-tie[2]", 1);
			setprop("b707/generator/gen-bus-tie[3]", 1);
			setprop("b707/ess-power-switch", 1);
			setprop("b707/ac/ac-para-select", 1);
			setprop("b707/generator/gen-drive[4]", 0);				
			setprop("b707/apu/starter", 0);
			setprop("b707/hydraulic/quantity", 3050);
			setprop("/b707/generator/hertz-converter", 1);
			setprop("/b707/equipment/blower", 1);
			setprop("/b707/equipment/ovbd-dump", 1);
			setprop("/b707/pressurization/safety-valve", 1);
			b707.safety_valv_pos();
			setprop("/b707/pressurization/manual-mode-switch",1);
			setprop("/b707/pressurization/mode-switch",1);
			setprop("/b707/air-conditioning/air-cond-unit-left-start",1);
			setprop("/b707/air-conditioning/air-cond-unit-right-start",1);
			setprop("/b707/air-conditioning/wing-valve[0]",1);
			setprop("/b707/air-conditioning/wing-valve[1]",1);
			setprop("/b707/air-conditioning/cabin-temp-selector[0]",4);
			setprop("/b707/air-conditioning/cabin-temp-selector[1]",4);
			setprop("/b707/emergency/oxygen-switch",2);
    }, 34);

		
 };

 
