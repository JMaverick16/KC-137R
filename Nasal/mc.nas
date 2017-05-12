# KC-137R Master Caution System Wrapper Octal by Joshua Davidson (it0uchpods/411)

# Init always happens, but who cares? So I make it after the FDM is fine.

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/warnings/mc", 0);
	if (getprop("/b707/anti-ice/engine-inlet[0]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/anti-ice/engine-inlet[1]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/anti-ice/engine-inlet[2]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/anti-ice/engine-inlet[3]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/anti-ice/valve-selector") == 2) {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/anti-ice/switch") == 2) {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/fuel/heater[0]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/fuel/heater[1]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/fuel/heater[2]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/fuel/heater[3]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/emergency/exit-lights") == 1) {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/anti-ice/window-heat-cap-switch") == 0) {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/b707/anti-ice/window-heat-fo-switch") == 0) {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/it-fbw/roll-disable") == 1) {
		setprop("/warnings/mc", 1);
	}
	if (getprop("/it-fbw/pitch-disable") == 1) {
		setprop("/warnings/mc", 1);
	}
	print("Master Caution System ... FINE!");
});

setlistener("/b707/anti-ice/engine-inlet[0]", func {
	if (getprop("/b707/anti-ice/engine-inlet[0]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/anti-ice/engine-inlet[1]", func {
	if (getprop("/b707/anti-ice/engine-inlet[1]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/anti-ice/engine-inlet[2]", func {
	if (getprop("/b707/anti-ice/engine-inlet[2]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/anti-ice/engine-inlet[3]", func {
	if (getprop("/b707/anti-ice/engine-inlet[3]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/anti-ice/valve-selector", func {
	if (getprop("/b707/anti-ice/valve-selector") == 2) {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/anti-ice/switch", func {
	if (getprop("/b707/anti-ice/switch") == 2) {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/fuel/heater[0]", func {
	if (getprop("/b707/fuel/heater[0]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/fuel/heater[1]", func {
	if (getprop("/b707/fuel/heater[1]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/fuel/heater[2]", func {
	if (getprop("/b707/fuel/heater[2]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/fuel/heater[3]", func {
	if (getprop("/b707/fuel/heater[3]") == "true") {
		# Do nothing
	} else {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/b707/emergency/exit-lights", func {
	if (getprop("/b707/emergency/exit-lights") == 1) {
		# Do nothing
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

setlistener("/it-fbw/roll-disable", func {
	if (getprop("/it-fbw/roll-disable") == 1) {
		setprop("/warnings/mc", 1);
	}
});

setlistener("/it-fbw/pitch-disable", func {
	if (getprop("/it-fbw/pitch-disable") == 1) {
		setprop("/warnings/mc", 1);
	}
});
