# KC-137R Wing Leveller/Pitch Stabilization Augmentation System by Joshua Davidson (it0uchpods)
# V0.8

##############################
# Engage/Disengage Functions #
##############################

setprop("/it-fbw/roll-engage", 0);
setprop("/it-fbw/pitch-disable", 0);
setprop("/it-fbw/man-pitch-btn", 0);

var roll = func {
	if (getprop("/it-fbw/roll-engage") == 0 and getprop("/gear/gear[0]/wow") == 0) {
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
	setprop("/it-autoflight/input/ap1", 0);
	setprop("/it-autoflight/input/ap2", 0);
	if (getprop("/it-fbw/pitch-disable") == 0) {
		setprop("/it-fbw/pitch-disable", 1);
		setprop("/it-fbw/man-pitch-btn", 1);
	} else {
		setprop("/it-fbw/pitch-disable", 0);
		setprop("/it-fbw/man-pitch-btn", 0);
	}
}

var update_fbw = func {
	if (getprop("/orientation/roll-deg") <= 55 and getprop("/orientation/roll-deg") >= -50) {
		if (getprop("/it-fbw/man-pitch-btn") == 0) {
			setprop("/it-fbw/pitch-disable", 0);
		}
	} else {
		setprop("/it-fbw/pitch-disable", 1);
	}
	if (getprop("/gear/gear[1]/wow") == 1 or getprop("/gear/gear[2]/wow") == 1) {
		setprop("/it-fbw/roll-engage", 0);
	}
}

setlistener("/it-autoflight/output/ap1", func {
	if (getprop("/it-autoflight/output/ap1") == 1) {
		setprop("/it-fbw/roll-engage", 0);
	}
});

setlistener("/it-autoflight/output/ap2", func {
	if (getprop("/it-autoflight/output/ap2") == 1) {
		setprop("/it-fbw/roll-engage", 0);
	}
});


####################
# Init and Various #
####################

setlistener("/sim/signals/fdm-initialized", func {
	update.start();
	print("Pitch Stabilization System ... OK!")
});

##########
# Timers #
##########
var update = maketimer(0.01, update_fbw);
