# GMeter Min/Max Pulled Logic
# Joshua Davidson (Octal450)

# Init
var gmeter_init = func {
	setprop("/gmeter/min", -0.5);
	setprop("/gmeter/max", 2.5);
	gmeter_loop();
}

var gmeter_loop = func {
	var g = getprop("/accelerations/pilot-gdamped");
	var min = getprop("/gmeter/min");
	var max = getprop("/gmeter/max");
	if (g > max) {
		setprop("/gmeter/max", getprop("/accelerations/pilot-gdamped"));
	} else if (g < min) {
		setprop("/gmeter/min", getprop("/accelerations/pilot-gdamped"));
	}
    settimer(gmeter_loop, 0.1);
}

var gmeter_reset = func {
	setprop("/gmeter/min", 1);
	setprop("/gmeter/max", 1);
}