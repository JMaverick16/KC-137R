# KC-137R Wing Leveller/Pitch Stabilization Augmentation System by Joshua Davidson (it0uchpods/411)
# V0.1

setprop("/it-fbw/roll-engage", 0);
setprop("/it-fbw/pitch-engage", 0);

var roll = func {
	if (getprop("/it-fbw/roll-engage") == 0) {
	setprop("/it-autoflight/input/ap1", 0);
	setprop("/it-autoflight/input/ap2", 0);
	setprop("/it-fbw/sound/enableapoffsound", 1);
	setprop("/it-fbw/sound/apoffsound", 0);
	setprop("/it-fbw/roll-engage", 1);
	} else {
	if (getprop("/it-fbw/sound/enableapoffsound") == 1) {
		setprop("/it-fbw/sound/apoffsound", 1);	
		setprop("/it-fbw/sound/enableapoffsound", 0);	  
	}
	setprop("/it-fbw/roll-engage", 0);
	}
}

var pitch = func {
	if (getprop("/it-fbw/pitch-engage") == 0) {
	setprop("/it-autoflight/input/ap1", 0);
	setprop("/it-autoflight/input/ap2", 0);
	setprop("/it-fbw/pitch-deg", getprop("/orientation/pitch-deg"));
	setprop("/it-fbw/sound/enableapoffsound2", 1);
	setprop("/it-fbw/sound/apoffsound2", 0);
	setprop("/it-fbw/pitch-engage", 1);
	} else {
	if (getprop("/it-fbw/sound/enableapoffsound2") == 1) {
		setprop("/it-fbw/sound/apoffsound2", 1);	
		setprop("/it-fbw/sound/enableapoffsound2", 0);	  
	}
	setprop("/it-fbw/pitch-engage", 0);
	}
}

setlistener("/it-autoflight/output/ap1", func {
	if (getprop("/it-autoflight/output/ap1") == 1) {
		setprop("/it-fbw/roll-engage", 0);
		setprop("/it-fbw/pitch-engage", 0);
	}
});

setlistener("/it-autoflight/output/ap2", func {
	if (getprop("/it-autoflight/output/ap2") == 1) {
		setprop("/it-fbw/roll-engage", 0);
		setprop("/it-fbw/pitch-engage", 0);
	}
});

var pitch_input = func {
	var elev = getprop("/controls/flight/elevator");

	if (getprop("/it-autoflight/output/ap1") == 0 and getprop("/it-autoflight/output/ap2") == 0 and getprop("/it-fbw/pitch-engage") == 1) {
		
		if (elev >= 0.05 and elev < 0.15) {
			var pfbw = getprop("/it-fbw/pitch-deg");
			setprop("/it-fbw/pitch-deg", pfbw - "0.02");
		} else if (elev >= 0.15 and elev < 0.3) {
			var pfbw = getprop("/it-fbw/pitch-deg");
			setprop("/it-fbw/pitch-deg", pfbw - "0.05");
		} else if (elev >= 0.3 and elev < 0.5) {
			var pfbw = getprop("/it-fbw/pitch-deg");
			setprop("/it-fbw/pitch-deg", pfbw - "0.1");
		} else if (elev >= 0.5 and elev < 0.7) {
			var pfbw = getprop("/it-fbw/pitch-deg");
			setprop("/it-fbw/pitch-deg", pfbw - "0.15");
		} else if (elev >= 0.7 and elev <= 1) {
			var pfbw = getprop("/it-fbw/pitch-deg");
			setprop("/it-fbw/pitch-deg", pfbw - "0.2");
		}
	
		if (elev <= -0.05 and elev > -0.15) {
			var pfbw = getprop("/it-fbw/pitch-deg");
			setprop("/it-fbw/pitch-deg", pfbw + "0.02");
		} else if (elev <= -0.15 and elev > -0.3) {
			var pfbw = getprop("/it-fbw/pitch-deg");
			setprop("/it-fbw/pitch-deg", pfbw + "0.05");
		} else if (elev <= -0.3 and elev > -0.5) {
			var pfbw = getprop("/it-fbw/pitch-deg");
			setprop("/it-fbw/pitch-deg", pfbw + "0.1");
		} else if (elev <= -0.5 and elev > -0.7) {
			var pfbw = getprop("/it-fbw/pitch-deg");
			setprop("/it-fbw/pitch-deg", pfbw + "0.15");
		} else if (elev <= -0.7 and elev >= -1) {
			var pfbw = getprop("/it-fbw/pitch-deg");
			setprop("/it-fbw/pitch-deg", pfbw + "0.2");
		}
	}
	
	if (getprop("/it-fbw/pitch-deg") >= 15) {
		if (getprop("/position/gear-agl-ft") <= 30) {
			setprop("/it-fbw/pitch-deg", "15");
		}
		if (getprop("/it-fbw/pitch-deg") >= 30) {
			setprop("/it-fbw/pitch-deg", "30");
		}
	}
	
	if (getprop("/it-fbw/pitch-deg") <= -15) {
		setprop("/it-fbw/pitch-deg", "-15");
	}
	
	if (getprop("/gear/gear[1]/wow") == 1 and getprop("/gear/gear[2]/wow")) {
		setprop("/it-fbw/roll-engage", 0);
		setprop("/it-fbw/pitch-engage", 0);
		setprop("/it-fbw/pitch-deg", getprop("/orientation/pitch-deg"));
	}

    settimer(pitch_input, 0.01);
}

setlistener("/sim/signals/fdm-initialized", func {
	pitch_input();
	print("Pitch Stabilization System ... OK!")
});
