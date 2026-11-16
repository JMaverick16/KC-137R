# GMeter Min/Max Pulled Logic
# Joshua Davidson (Octal450)

# Init
var gmeter_init = func {
	setprop("/instrumentation/gmeter/min", -0.2);
	setprop("/instrumentation/gmeter/max", 2.2);
	gmeter_loop();
}

var gmeter_loop = func {
	var g = getprop("/accelerations/pilot-gdamped");
	var min = getprop("/instrumentation/gmeter/min");
	var max = getprop("/instrumentation/gmeter/max");
	if (g > max) {
		setprop("/instrumentation/gmeter/max", getprop("/accelerations/pilot-gdamped"));
	} else if (g < min) {
		setprop("/instrumentation/gmeter/min", getprop("/accelerations/pilot-gdamped"));
	}
    settimer(gmeter_loop, 0.1);
}

var gmeter_reset = func {
	setprop("/instrumentation/gmeter/min", 0);
	setprop("/instrumentation/gmeter/max", 0);
}