# Gear tilting system by Joshua Davidson (it0uchpods)

var update_tilt = func {
	var comp1 = getprop("/gear/gear[1]/compression-ft");
	if (comp1 > 0) {
		var pitchdeg1 = getprop("/orientation/pitch-deg");
		setprop("/gear/gear[1]/angle-deg", pitchdeg1);
	} else {
		setprop("/gear/gear[1]/angle-deg", "20");
	}
	var comp2 = getprop("/gear/gear[2]/compression-ft");
	if (comp2 > 0) {
		var pitchdeg2 = getprop("/orientation/pitch-deg");
		setprop("/gear/gear[2]/angle-deg", pitchdeg2);
	} else {
		setprop("/gear/gear[2]/angle-deg", "20");
	}
}

setlistener("/gear/gear[1]/compression-norm", func {
	update_tilt();
});

setlistener("/gear/gear[2]/compression-norm", func {
	update_tilt();
});