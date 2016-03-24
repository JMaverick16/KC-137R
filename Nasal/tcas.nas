# Lake of Constance Hangar :: M.Kraus
# Avril 2013
# This file is licenced under the terms of the GNU General Public Licence V2 or later
################################ Reverser ####################################
setlistener("/instrumentation/mptcas/on", func(state) {
  var state = state.getBoolValue();  
  if(state) tcas();
}, 0, 1);

var tcas = func {

		var run = getprop("/instrumentation/mptcas/on") or 0;

		var pos_lat = getprop("/position/latitude-deg") or 0;
		var pos_lon = getprop("/position/longitude-deg") or 0;
		
		var our_pos = geo.aircraft_position();
		var my_hdg = getprop("/orientation/heading-deg") or 0;
		
		var display_factor = getprop("/instrumentation/mptcas/display-factor") or 0;
		var display_factor_awacs = getprop("/instrumentation/mptcas/display-factor-awacs") or 0;
		
		var aircraft_list = {};
	
		# Multiplayer TCAS
	
		for (var n = 0; n < 30; n += 1) {
		
			var callsign = getprop("ai/models/multiplayer[" ~ n ~ "]/callsign") or 0;
	
			if (getprop("ai/models/multiplayer[" ~ n ~ "]/valid") and callsign and run) {
		
				var mp_lat = getprop("ai/models/multiplayer[" ~ n ~ "]/position/latitude-deg") or 0;
				var mp_lon = getprop("ai/models/multiplayer[" ~ n ~ "]/position/longitude-deg") or 0;
				var bearing = getprop("ai/models/multiplayer[" ~ n ~ "]/radar/bearing-deg") or 0;
					
				var x = (mp_lon - pos_lon) * display_factor;
				var y = (mp_lat - pos_lat) * display_factor;
				var xa = (mp_lon - pos_lon) * display_factor_awacs;
				var ya = (mp_lat - pos_lat) * display_factor_awacs;			
				
				# What is our position to the mp?		
				var mp_pos 	= geo.Coord.new();
						mp_pos.set_latlon( mp_lat, mp_lon);
				var hdg_to_mp = our_pos.course_to(mp_pos);
				var distance = our_pos.distance_to(mp_pos) * 0.0005399568034557236; # to nautical miles
				var course_to_mp = 360 - geo.normdeg(my_hdg - hdg_to_mp); 
			  
				var display = distance * display_factor; # for the range of the selected mp-aircrafts
				var displayAwacs = distance * display_factor_awacs; # for the range of the selected mp-aircrafts
				
				var alt_ft = getprop("ai/models/multiplayer[" ~ n ~ "]/position/altitude-ft") or 0;
			  var tas_kt = getprop("ai/models/multiplayer[" ~ n ~ "]/velocities/true-airspeed-kt") or 0;
			  var t_code = getprop("ai/models/multiplayer[" ~ n ~ "]/instrumentation/transponder/transmitted-id") or 0;
			  var t_code = abs(t_code);
			  
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/dis-x", x);										# for the radar pos
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/dis-y", y);										# for the radar pos
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/dis-xa", xa);									# for the radar pos
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/dis-ya", ya);									# for the radar pos
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/callsign", callsign);					# only info
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/distance-nm", distance);			# only info		
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/course-to-mp",course_to_mp);	# only info
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/bearing-deg", bearing);				# only info	
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/altitude-ft", alt_ft);				# only info
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/tas-kt", tas_kt);							# only info
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/id-code", t_code);						# only info
				
				# fill the Awacs data array
				if(getprop("sim/aircraft") == "EC-137D"){
				  var true_hdg = getprop("ai/models/multiplayer[" ~ n ~ "]/orientation/true-heading-deg") or 0;
				  t_code = (t_code > 0) ? t_code : "----";
				  
				  var model_short = getprop("ai/models/multiplayer[" ~ n ~ "]/sim/model/path");
				  if(model_short != nil) {
						var u = split("/", model_short); # give array
						var s = size(u); # how many elements in array
						var o = u[s-1];	 # the last element
						var m = size(o); # how long is this string in the last element
						var e = m - 4;   # - 4 chars .xml
						var ms = substr(o, 0, e); # the string without .xml
				  }else{
				  	var ms = "no ident";
				  }
				  aircraft_list[callsign] = {cs: callsign, dis: distance, alt: alt_ft, th: true_hdg, ctm: course_to_mp, tas: tas_kt, at: ms~" | "~t_code };
				}
				
				# select object if in range of radar / 3.24 found by trial and error depends on range select knob
				if (display < 3.23){ 
					setprop("/instrumentation/mptcas/mp[" ~ n ~ "]/show", 1);
				}else{
					setprop("/instrumentation/mptcas/mp[" ~ n ~ "]/show", 0);				
				}
				if (displayAwacs < 2.0){ 
					setprop("/instrumentation/mptcas/mp[" ~ n ~ "]/show-awacs", 1);
				}else{
					setprop("/instrumentation/mptcas/mp[" ~ n ~ "]/show-awacs", 0);				
				}
				
			}else{
			
				setprop("/instrumentation/mptcas/mp[" ~ n ~ "]/show-awacs", 0);
				setprop("/instrumentation/mptcas/mp[" ~ n ~ "]/show", 0);		
			}
	
		}
	
	# AI TCAS
	
		for (var n = 0; n < 20; n += 1) {
		
			var callsign = getprop("ai/models/aircraft[" ~ n ~ "]/callsign") or 0;
	
			if (getprop("ai/models/aircraft[" ~ n ~ "]/valid") and callsign and run) {
		
				var ai_lat = getprop("ai/models/aircraft[" ~ n ~ "]/position/latitude-deg") or 0;
				var ai_lon = getprop("ai/models/aircraft[" ~ n ~ "]/position/longitude-deg") or 0;
				var bearing = getprop("ai/models/aircraft[" ~ n ~ "]/radar/bearing-deg") or 0;

				var x = (ai_lon - pos_lon) * display_factor;
				var y = (ai_lat - pos_lat) * display_factor;
				var xa = (ai_lon - pos_lon) * display_factor_awacs;
				var ya = (ai_lat - pos_lat) * display_factor_awacs;			
				
				# What is our position to the ai?		
				var ai_pos 	= geo.Coord.new();
						ai_pos.set_latlon( ai_lat, ai_lon);
				var hdg_to_mp = our_pos.course_to(ai_pos);
				var distance = our_pos.distance_to(ai_pos) * 0.0005399568034557236; # to Nautical Miles
				var course_to_mp = 360 - geo.normdeg(my_hdg - hdg_to_mp); 
			  
				var display = distance * display_factor; # for the range of the selected ai-aircrafts
				var displayAwacs = distance * display_factor_awacs; # for the range of the selected ai-aircrafts
				
				var alt_ft = getprop("ai/models/aircraft[" ~ n ~ "]/position/altitude-ft") or 0;
			  var tas_kt = getprop("ai/models/aircraft[" ~ n ~ "]/velocities/true-airspeed-kt") or 0;
			  
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/dis-x", x);										# for the radar pos
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/dis-y", y);										# for the radar pos
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/dis-xa", xa);									# for the radar pos
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/dis-ya", ya);									# for the radar pos
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/callsign", callsign);					# only info
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/distance-nm", distance);			# only info	
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/bearing-deg", bearing);			  # only info		
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/course-to-mp",course_to_mp);	# only info
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/altitude-ft", alt_ft);				# only info
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/tas-kt", tas_kt);							# only info
				
				# fill the Awacs data array
				if(getprop("sim/aircraft") == "EC-137D"){
				  var true_hdg = getprop("ai/models/aircraft[" ~ n ~ "]/orientation/true-heading-deg") or 0;
				  aircraft_list[callsign] = {cs: callsign, dis: distance, alt: alt_ft, th: true_hdg, ctm: course_to_mp, tas: tas_kt, at: "AI" };
				}
				
				# select object if in range of radar / 3.24 found by trial and error depends on range select knob
				if (display < 3.23){ 
					setprop("/instrumentation/mptcas/ai[" ~ n ~ "]/show", 1);
				}else{
					setprop("/instrumentation/mptcas/ai[" ~ n ~ "]/show", 0);				
				}
				if (displayAwacs < 2.0){ 
					setprop("/instrumentation/mptcas/ai[" ~ n ~ "]/show-awacs", 1);
				}else{
					setprop("/instrumentation/mptcas/ai[" ~ n ~ "]/show-awacs", 0);				
				}				
			}else{
			
				setprop("/instrumentation/mptcas/ai[" ~ n ~ "]/show-awacs", 0);
				setprop("/instrumentation/mptcas/ai[" ~ n ~ "]/show", 0);		
			}
	
		}
		
	# TCAS for Tanker in refueling_demos
		
		for (var n = 0; n < 1; n += 1) {
		
			var callsign = getprop("ai/models/tanker[" ~ n ~ "]/callsign") or 0;
	
			if (getprop("ai/models/tanker[" ~ n ~ "]/valid") and callsign and run) {
		
				var ai_lat = getprop("ai/models/tanker[" ~ n ~ "]/position/latitude-deg") or 0;
				var ai_lon = getprop("ai/models/tanker[" ~ n ~ "]/position/longitude-deg") or 0;
				var bearing = getprop("ai/models/tanker[" ~ n ~ "]/radar/bearing-deg") or 0;

				var x = (ai_lon - pos_lon) * display_factor;
				var y = (ai_lat - pos_lat) * display_factor;
				var xa = (ai_lon - pos_lon) * display_factor_awacs;
				var ya = (ai_lat - pos_lat) * display_factor_awacs;			
				
				# What is our position to the ai?		
				var ai_pos 	= geo.Coord.new();
						ai_pos.set_latlon( ai_lat, ai_lon);
				var hdg_to_mp = our_pos.course_to(ai_pos);
				var distance = our_pos.distance_to(ai_pos) * 0.0005399568034557236; # to Nautical Miles
				var course_to_mp = 360 - geo.normdeg(my_hdg - hdg_to_mp); 
			  
				var display = distance * display_factor; # for the range of the selected ai-tankers
				var displayAwacs = distance * display_factor_awacs; # for the range of the selected ai-tankers
				
				var alt_ft = getprop("ai/models/tanker[" ~ n ~ "]/position/altitude-ft") or 0;
			  	var tas_kt = getprop("ai/models/tanker[" ~ n ~ "]/velocities/true-airspeed-kt") or 0;
			  
				setprop("instrumentation/mptcas/ta[" ~ n ~ "]/dis-x", x);										# for the radar pos
				setprop("instrumentation/mptcas/ta[" ~ n ~ "]/dis-y", y);										# for the radar pos
				setprop("instrumentation/mptcas/ta[" ~ n ~ "]/dis-xa", xa);									# for the radar pos
				setprop("instrumentation/mptcas/ta[" ~ n ~ "]/dis-ya", ya);									# for the radar pos
				setprop("instrumentation/mptcas/ta[" ~ n ~ "]/callsign", callsign);					# only info
				setprop("instrumentation/mptcas/ta[" ~ n ~ "]/distance-nm", distance);			# only info	
				setprop("instrumentation/mptcas/ta[" ~ n ~ "]/bearing-deg", bearing);			  # only info		
				setprop("instrumentation/mptcas/ta[" ~ n ~ "]/course-to-mp",course_to_mp);	# only info
				setprop("instrumentation/mptcas/ta[" ~ n ~ "]/altitude-ft", alt_ft);				# only info
				setprop("instrumentation/mptcas/ta[" ~ n ~ "]/tas-kt", tas_kt);							# only info
				
				# fill the Awacs data array
				if(getprop("sim/aircraft") == "EC-137D"){
				  var true_hdg = getprop("ai/models/tanker[" ~ n ~ "]/orientation/true-heading-deg") or 0;
				  aircraft_list[callsign] = {cs: callsign, dis: distance, alt: alt_ft, th: true_hdg, ctm: course_to_mp, tas: tas_kt, at: "TANKER" };
				}
				
				# select object if in range of radar / 3.24 found by trial and error depends on range select knob
				if (display < 3.23){ 
					setprop("/instrumentation/mptcas/ta[" ~ n ~ "]/show", 1);
				}else{
					setprop("/instrumentation/mptcas/ta[" ~ n ~ "]/show", 0);				
				}
				if (displayAwacs < 2.0){ 
					setprop("/instrumentation/mptcas/ta[" ~ n ~ "]/show-awacs", 1);
				}else{
					setprop("/instrumentation/mptcas/ta[" ~ n ~ "]/show-awacs", 0);				
				}				
			}else{
			
				setprop("/instrumentation/mptcas/ta[" ~ n ~ "]/show-awacs", 0);
				setprop("/instrumentation/mptcas/ta[" ~ n ~ "]/show", 0);		
			}
	
		}
		
		if(getprop("sim/aircraft") == "EC-137D"){
			# first reset the old inputs
			foreach(var r; props.globals.getNode("/instrumentation/mptcas/table").getChildren("row")){
				if(r.getNode("col[0]") != nil){
					r.getNode("col[0]").setValue("------------");
				}
				if(r.getNode("col[1]") != nil){
					r.getNode("col[1]").setValue("------------");
				}
				if(r.getNode("col[2]") != nil){
					r.getNode("col[2]").setValue("------------");
				}
				if(r.getNode("col[3]") != nil){
					r.getNode("col[3]").setValue("------------");
				}
				if(r.getNode("col[4]") != nil){
					r.getNode("col[4]").setValue("------------");
				}
				if(r.getNode("col[5]") != nil){
					r.getNode("col[5]").setValue("------------");
				}
			}

			# write the heading
			setprop("/instrumentation/mptcas/table/row[0]/col[0]","CALLSIGN");	
			setprop("/instrumentation/mptcas/table/row[0]/col[1]","DISTANCE");
			setprop("/instrumentation/mptcas/table/row[0]/col[2]","ALTITUDE");	
			setprop("/instrumentation/mptcas/table/row[0]/col[3]","HDG | DIR");
			setprop("/instrumentation/mptcas/table/row[0]/col[4]","TAS");	
			setprop("/instrumentation/mptcas/table/row[0]/col[5]","AIRCRAFT | ID");
			
			#return a list of the hash keys sorted by altitude_m
			var sortedkeys = sort(keys(aircraft_list), func (a,b) { aircraft_list[a].dis - aircraft_list[b].dis; });

			var n = 1; #n=0 is the headline
			foreach (var i; sortedkeys){ 
			 	#print (i, ": ", aircraft_list[i].cs, ", ", aircraft_list[i].dis);
			 				
				var text1 = sprintf("%.1f", aircraft_list[i].dis);
				var text2 = sprintf("%.0f", aircraft_list[i].alt);
				var text3 = sprintf("%.0f | %.0f", aircraft_list[i].th, aircraft_list[i].ctm);
				var text4 = sprintf("%.0f", aircraft_list[i].tas);
				var text5 = aircraft_list[i].at;
						
				setprop("/instrumentation/mptcas/table/row["~n~"]/col[0]",aircraft_list[i].cs);	
				setprop("/instrumentation/mptcas/table/row["~n~"]/col[1]",text1);
				setprop("/instrumentation/mptcas/table/row["~n~"]/col[2]",text2);	
				setprop("/instrumentation/mptcas/table/row["~n~"]/col[3]",text3);
				setprop("/instrumentation/mptcas/table/row["~n~"]/col[4]",text4);	
				setprop("/instrumentation/mptcas/table/row["~n~"]/col[5]",text5);
				n += 1;	
			}
		}
	if (run) settimer(tcas, 1.4);
	
}


   

