# KC-137R System Init File

setlistener("/sim/signals/fdm-initialized", func {
  itaf.ap_init();
  var autopilot = gui.Dialog.new("sim/gui/dialogs/autopilot/dialog", "Aircraft/KC-137R/Systems/autopilot-dlg.xml");
  setprop("/controls/internal/value1", "1");
  setprop("/controls/flight/speedbrake-arm", "0");
  setprop("/b707/anti-ice/window-heat-cap-switch", "0");
  setprop("/b707/anti-ice/window-heat-fo-switch", "0");
  setprop("/indicators/asi/vmo", "380");
  setprop("/instrumentation/efis[2]/mfd/rangearc", 1);
  b707.compass_swing();
  b707.gmeter_init();
  print("OCTAL ... FINE!");
});

setlistener("engines/engine[0]/epr-actual", func {
  setprop("engines/engine[0]/epr-actualx100", (getprop("engines/engine[0]/epr-actual") * 100));
});
setlistener("engines/engine[1]/epr-actual", func {
  setprop("engines/engine[1]/epr-actualx100", (getprop("engines/engine[1]/epr-actual") * 100));
});
setlistener("engines/engine[2]/epr-actual", func {
  setprop("engines/engine[2]/epr-actualx100", (getprop("engines/engine[2]/epr-actual") * 100));
});
setlistener("engines/engine[3]/epr-actual", func {
  setprop("engines/engine[3]/epr-actualx100", (getprop("engines/engine[3]/epr-actual") * 100));
});

setprop("/controls/flight/flap-lever", 0);

controls.flapsDown = func(step) {
	if (step == 1) {
		if (getprop("/controls/flight/flap-lever") == 0) {
			setprop("/controls/special/slats-switch", 0.0);
			setprop("/controls/flight/flaps", 0.2);
			setprop("/controls/flight/flap-lever", 1);
			return;
		} else if (getprop("/controls/flight/flap-lever") == 1) {
			setprop("/controls/special/slats-switch", 1.0);
			setprop("/controls/flight/flaps", 0.4);
			setprop("/controls/flight/flap-lever", 2);
			return;
		} else if (getprop("/controls/flight/flap-lever") == 2) {
			setprop("/controls/special/slats-switch", 1.0);
			setprop("/controls/flight/flaps", 0.6);
			setprop("/controls/flight/flap-lever", 3);
			return;
		} else if (getprop("/controls/flight/flap-lever") == 3) {
			setprop("/controls/special/slats-switch", 1.0);
			setprop("/controls/flight/flaps", 1.0);
			setprop("/controls/flight/flap-lever", 4);
			return;
		}
	} else if (step == -1) {
		if (getprop("/controls/flight/flap-lever") == 4) {
			setprop("/controls/special/slats-switch", 1.0);
			setprop("/controls/flight/flaps", 0.6);
			setprop("/controls/flight/flap-lever", 3);
			return;
		} else if (getprop("/controls/flight/flap-lever") == 3) {
			setprop("/controls/special/slats-switch", 1.0);
			setprop("/controls/flight/flaps", 0.4);
			setprop("/controls/flight/flap-lever", 2);
			return;
		} else if (getprop("/controls/flight/flap-lever") == 2) {
			setprop("/controls/special/slats-switch", 0.0);
			setprop("/controls/flight/flaps", 0.2);
			setprop("/controls/flight/flap-lever", 1);
			return;
		} else if (getprop("/controls/flight/flap-lever") == 1) {
			setprop("/controls/special/slats-switch", 0.0);
			setprop("/controls/flight/flaps", 0.0);
			setprop("/controls/flight/flap-lever", 0);
			return;
		}
	} else {
		return 0;
	}
}
