# KC-137R EFIS controller by Joshua Davidson (it0uchpods/411).

var nd_init = func {
	setprop("/instrumentation/efis/inputs/range-nm", 10);
	setprop("/controls/switches/modekb", 2);
	setprop("/instrumentation/efis/inputs/tfc", "true");
	setprop("/instrumentation/efis[1]/inputs/range-nm", 10);
	setprop("/controls/switches/modekb2", 2);
	setprop("/instrumentation/efis[1]/inputs/tfc", "true");
	print("EFIS ... FINE!");
}

# Captain

var ctl_func = func(md,val) {
    if(md == "range") {
        var rng = getprop("/instrumentation/efis/inputs/range-nm");
        if(val ==1){
            rng = rng * 2;
            if(rng > 640) rng = 640;
        } else if(val = -1){
            rng = rng / 2;
            if(rng < 10) rng = 10;
        }
		setprop("/instrumentation/efis/inputs/range-nm", rng);
    }
}

var mode_inc = func {
	var mode = getprop("/instrumentation/efis/mfd/display-mode");
	if (mode == "APP") {
		setprop("/instrumentation/efis/inputs/nd-centered", "true");
		setprop("/instrumentation/efis/mfd/display-mode", "VOR");
		setprop("/controls/switches/modekb", 1);
	} else if (mode == "VOR") {
		setprop("/instrumentation/efis/inputs/nd-centered", "0");
		setprop("/instrumentation/efis/mfd/display-mode", "MAP");
		setprop("/controls/switches/modekb", 2);
	} else if (mode == "MAP") {
		setprop("/instrumentation/efis/mfd/display-mode", "PLAN");
		setprop("/controls/switches/modekb", 3);
	} else {
		return 0;
	}
}

var mode_dec = func {
	var mode = getprop("/instrumentation/efis/mfd/display-mode");
	if (mode == "PLAN") {
		setprop("/instrumentation/efis/inputs/nd-centered", "0");
		setprop("/instrumentation/efis/mfd/display-mode", "MAP");
		setprop("/controls/switches/modekb", 2);
	} else if (mode == "MAP") {
		setprop("/instrumentation/efis/inputs/nd-centered", "true");
		setprop("/instrumentation/efis/mfd/display-mode", "VOR");
		setprop("/controls/switches/modekb", 1);
	} else if (mode == "VOR") {
		setprop("/instrumentation/efis/inputs/nd-centered", "true");
		setprop("/instrumentation/efis/mfd/display-mode", "APP");
		setprop("/controls/switches/modekb", 0);
	} else {
		return 0;
	}
}

# First Officer

var ctl_func2 = func(md,val) {
    if(md == "range") {
        var rng = getprop("/instrumentation/efis[1]/inputs/range-nm");
        if(val ==1){
            rng = rng * 2;
            if(rng > 640) rng = 640;
        } else if(val = -1){
            rng = rng / 2;
            if(rng < 10) rng = 10;
        }
		setprop("/instrumentation/efis[1]/inputs/range-nm", rng);
    }
}

var mode_inc2 = func {
	var mode = getprop("/instrumentation/efis[1]/mfd/display-mode");
	if (mode == "APP") {
		setprop("/instrumentation/efis[1]/mfd/display-mode", "VOR");
		setprop("/instrumentation/efis[1]/inputs/nd-centered", "true");
		setprop("/controls/switches/modekb2", 1);
	} else if (mode == "VOR") {
		setprop("/instrumentation/efis[1]/mfd/display-mode", "MAP");
		setprop("/instrumentation/efis[1]/inputs/nd-centered", "0");
		setprop("/controls/switches/modekb2", 2);
	} else if (mode == "MAP") {
		setprop("/instrumentation/efis[1]/mfd/display-mode", "PLAN");
		setprop("/controls/switches/modekb2", 3);
	} else {
		return 0;
	}
}

var mode_dec2 = func {
	var mode = getprop("/instrumentation/efis[1]/mfd/display-mode");
	if (mode == "PLAN") {
		setprop("/instrumentation/efis[1]/inputs/nd-centered", "0");
		setprop("/instrumentation/efis[1]/mfd/display-mode", "MAP");
		setprop("/controls/switches/modekb2", 2);
	} else if (mode == "MAP") {
		setprop("/instrumentation/efis[1]/inputs/nd-centered", "true");
		setprop("/instrumentation/efis[1]/mfd/display-mode", "VOR");
		setprop("/controls/switches/modekb2", 1);
	} else if (mode == "VOR") {
		setprop("/instrumentation/efis[1]/inputs/nd-centered", "true");
		setprop("/instrumentation/efis[1]/mfd/display-mode", "APP");
		setprop("/controls/switches/modekb2", 0);
	} else {
		return 0;
	}
}