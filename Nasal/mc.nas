# KC-137R Master Caution System Wrapper Octal by Joshua Davidson (it0uchpods/411)

# Init always happens, but who cares? So I make it after the FDM is fine.

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/warnings/mc", 0);
	if (getprop("/it-autoflight/ap_master") == 1) {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/it-autoflight/ap_master2") == 1) {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/anti-ice/engine-inlet[0]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/anti-ice/engine-inlet[1]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/anti-ice/engine-inlet[2]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/anti-ice/engine-inlet[3]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/anti-ice/valve-selector") == 2) {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/anti-ice/switch") == 2) {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/fuel/heater[0]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/fuel/heater[1]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/fuel/heater[2]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/fuel/heater[3]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/emergency/exit-lights") == 1) {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/anti-ice/window-heat-cap-switch") == 0) {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/anti-ice/window-heat-fo-switch") == 0) {
		setprop("/warnings/mc", 1);
	}
	print("Master Caution System ... FINE!");
});

setlistener("/it-autoflight/ap_master", func {
	if (getprop("/it-autoflight/ap_master") == 1) {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/it-autoflight/ap_master2", func {
	if (getprop("/it-autoflight/ap_master2") == 1) {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/anti-ice/engine-inlet[0]", func {
	if (getprop("/b707/anti-ice/engine-inlet[0]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/anti-ice/engine-inlet[1]", func {
	if (getprop("/b707/anti-ice/engine-inlet[1]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/anti-ice/engine-inlet[2]", func {
	if (getprop("/b707/anti-ice/engine-inlet[2]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/anti-ice/engine-inlet[3]", func {
	if (getprop("/b707/anti-ice/engine-inlet[3]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/anti-ice/valve-selector", func {
	if (getprop("/b707/anti-ice/valve-selector") == 2) {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/anti-ice/switch", func {
	if (getprop("/b707/anti-ice/switch") == 2) {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/fuel/heater[0]", func {
	if (getprop("/b707/fuel/heater[0]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/fuel/heater[1]", func {
	if (getprop("/b707/fuel/heater[1]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/fuel/heater[2]", func {
	if (getprop("/b707/fuel/heater[2]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/fuel/heater[3]", func {
	if (getprop("/b707/fuel/heater[3]") == "true") {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/emergency/exit-lights", func {
	if (getprop("/b707/emergency/exit-lights") == 1) {
		return 0;
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/anti-ice/window-heat-cap-switch", func {
	if (getprop("/b707/anti-ice/window-heat-cap-switch") == 0) {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/anti-ice/window-heat-fo-switch", func {
	if (getprop("/b707/anti-ice/window-heat-fo-switch") == 0) {
		setprop("/warnings/mc", 1);
	}
});