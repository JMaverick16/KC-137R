# IT AUTOFLIGHT Subsystem by Joshua Davidson (it0uchpods/411).
# V2.10

var ap_init = func {
	ap_logic_init();
	setprop("/controls/it2/aplatset", 0);
	setprop("/controls/it2/apvertset", 0);
	setprop("/controls/it2/apthrset", 0);
	setprop("/autopilot/settings/target-speed-kt", 200);
	setprop("/autopilot/settings/target-mach", 0.68);
	setprop("/autopilot/settings/idlethr", 0);
	setprop("/autopilot/settings/clbthr", 900);
	setprop("/autopilot/settings/heading-bug-deg", 360);
	setprop("/autopilot/settings/target-altitude-ft", 10000);
	setprop("/autopilot/settings/vertical-speed-fpm", 0);
	update_arms();
	ap_refresh();
	at_refresh();
	print("AUTOFLIGHT ... FINE!");
}

var update_arms = func {
  update_locarmelec();
  update_apparmelec();

  settimer(update_arms, 0.5);
}

var update_locarmelec = func {
  var ap = getprop("/controls/it2/ap_master");
  var loc1 = getprop("/controls/it2/loc1");
  if (loc1 & ap) {
  locarmcheck();
  } else {
  return 0;
  }
}

var update_apparmelec = func {
  var ap = getprop("/controls/it2/ap_master");
  var app1 = getprop("/controls/it2/app1");
  if (app1 & ap) {
  apparmcheck();
  } else {
  return 0;
  }
}

var hdg_master = func {
	var ap = getprop("/controls/it2/ap_master");
	var hdg = getprop("/controls/it2/hdg");
	if (hdg & ap) {
		setprop("/autopilot/locks/heading", "dg-heading-hold");
		setprop("/controls/it2/loc1", 0);
	} else {
		return 0;
	}
}

var nav_master = func {
	var ap = getprop("/controls/it2/ap_master");
	var nav = getprop("/controls/it2/nav");
	if (nav & ap) {
		setprop("/autopilot/locks/heading", "true-heading-hold");
		setprop("/controls/it2/loc1", 0);
	} else {
		return 0;
	}
}

var locarmcheck = func {
	var locdefl = getprop("instrumentation/nav/heading-needle-deflection-norm");
	if ((locdefl < 0.9233) and (getprop("instrumentation/nav/signal-quality-norm") > 0.99)) {
		setprop("/autopilot/locks/heading", "nav1-hold");
		setprop("/controls/it2/loc1", 0);
		setprop("/controls/it2/aplatmode", 2);
		setprop("/controls/it2/aphldtrk", 1);
	} else {
		return 0;
	}
}

var alt_master = func {
	var ap = getprop("/controls/it2/ap_master");
	var alt = getprop("/controls/it2/alt");
	if (alt & ap) {
		setprop("/autopilot/locks/altitude", "altitude-hold");
		setprop("/controls/it2/app1", 0);
	} else {
		return 0;
	}
}

var vs_master = func {
	var ap = getprop("/controls/it2/ap_master");
	var vs = getprop("/controls/it2/vs");
	if (vs & ap) {
		setprop("/autopilot/locks/altitude", "vertical-speed-hold");
		setprop("/controls/it2/app1", 0);
	} else {
		return 0;
	}
}

var apparmcheck = func {
	var signal = getprop("/instrumentation/nav/gs-needle-deflection-norm");
	if (signal <= -0.000000001) {
		setprop("/autopilot/locks/altitude", "gs1-hold");
		setprop("/controls/it2/app1", 0);
		setprop("/controls/it2/apvertmode", 2);
		setprop("/controls/it2/aphldtrk2", 1);
	} else {
		return 0;
	}
}

var altcap_master = func {
	var ap = getprop("/controls/it2/ap_master");
	var altc = getprop("/controls/it2/altc");
	if (altc & ap) {
		setprop("/autopilot/locks/altitude", "altitude-hold");
	} else {
		return 0;
	}
}

var flch_master = func {
	var ap = getprop("/controls/it2/ap_master");
	var flch = getprop("/controls/it2/flch");
	if (flch & ap) {
		setprop("/autopilot/locks/altitude", "flch");
	} else {
		return 0;
	}
}

var thr_master = func {
	var at = getprop("/controls/it2/at_master");
	var thr = getprop("/controls/it2/thr");
	if (thr & at) {
		setprop("/autopilot/locks/speed", "thr");
	} else {
		return 0;
	}
}

var idle_master = func {
	var at = getprop("/controls/it2/at_master");
	var idle = getprop("/controls/it2/idle");
	if (idle & at) {
		setprop("/autopilot/locks/speed", "idle");
	} else {
		return 0;
	}
}

var clb_master = func {
	var at = getprop("/controls/it2/at_master");
	var clb = getprop("/controls/it2/clb");
	if (clb & at) {
		setprop("/autopilot/locks/speed", "clb");
	} else {
		return 0;
	}
}

var ap_refresh = func {
	hdg_master();
	nav_master();
	alt_master();
	vs_master();
	altcap_master();
	flch_master();
}

var at_refresh = func {
	thr_master();
	idle_master();
	clb_master();
}

var ap_off = func {
	setprop("/controls/it2/ap_master", 0);
	setprop("/autopilot/locks/heading", 0);
	setprop("/autopilot/locks/altitude", 0);
	setprop("/controls/it2/apoffsound", 1);
	hdg_master();
	nav_master();
	alt_master();
	vs_master();
	altcap_master();
	flch_master();
}

var at_off = func {
	setprop("/controls/it2/at_master", 0);
	setprop("/autopilot/locks/speed", 0);
	thr_master();
	idle_master();
	clb_master();
}