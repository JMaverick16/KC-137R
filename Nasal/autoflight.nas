# IT AUTOFLIGHT System Controller by Joshua Davidson (it0uchpods/411).
# V2.11 Beta 2

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
	setprop("/autopilot/settings/target-altitude-ft-actual", 10000);
	setprop("/autopilot/settings/vertical-speed-fpm", 0);
	update_arms();
	ap_refresh();
	at_refresh();
	setprop("/controls/it2/apvertset", 4);
	print("IT-AUTOFLIGHT ... OK!");
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
		setprop("/controls/it2/locks/lateral", "it-hdg-sel");
		setprop("/controls/it2/loc1", 0);
	} else {
		return 0;
	}
}

var nav_master = func {
	var ap = getprop("/controls/it2/ap_master");
	var nav = getprop("/controls/it2/nav");
	if (nav & ap) {
		setprop("/controls/it2/locks/lateral", "it-nav-fms");
		setprop("/controls/it2/loc1", 0);
	} else {
		return 0;
	}
}

var locarmcheck = func {
	var locdefl = getprop("instrumentation/nav/heading-needle-deflection-norm");
	if ((locdefl < 0.9233) and (getprop("instrumentation/nav/signal-quality-norm") > 0.99)) {
		setprop("/controls/it2/locks/lateral", "it-vorloc");
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
		setprop("/controls/it2/locks/pitch", "it-alt-cap-hld");
		setprop("/controls/it2/app1", 0);
	} else {
		return 0;
	}
}

var vs_master = func {
	var ap = getprop("/controls/it2/ap_master");
	var vs = getprop("/controls/it2/vs");
	if (vs & ap) {
		setprop("/controls/it2/locks/pitch", "it-vert-spd");
		setprop("/controls/it2/app1", 0);
	} else {
		return 0;
	}
}

var apparmcheck = func {
	var signal = getprop("/instrumentation/nav/gs-needle-deflection-norm");
	if (signal <= -0.000000001) {
		setprop("/controls/it2/locks/pitch", "it-gs");
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
		setprop("/controls/it2/locks/pitch", "it-alt-cap-hld");
	} else {
		return 0;
	}
}

var flch_master = func {
	var ap = getprop("/controls/it2/ap_master");
	var flch = getprop("/controls/it2/flch");
	if (flch & ap) {
		setprop("/controls/it2/locks/pitch", "it-flch");
	} else {
		return 0;
	}
}

var vnav_master = func {
	var ap = getprop("/controls/it2/ap_master");
	var vnav = getprop("/controls/it2/vnav");
	if (vnav & ap) {
#		setprop("/controls/it2/locks/pitch", "it-vnav");   # Disabled, because VNAV is not yet working.
	} else {
		return 0;
	}
}

var land_master = func {
	var ap = getprop("/controls/it2/ap_master");
	var land = getprop("/controls/it2/land");
	if (land & ap) {
#		setprop("/controls/it2/locks/lateral", "it-land-lateral");   # Disabled, because AUTOLAND is not yet working.
#		setprop("/controls/it2/locks/pitch", "it-land-pitch");   # Disabled, because AUTOLAND is not yet working.
	} else {
		return 0;
	}
}

var thr_master = func {
	var at = getprop("/controls/it2/at_master");
	var thr = getprop("/controls/it2/thr");
	if (thr & at) {
		setprop("/controls/it2/locks/throttle", "it-thr");
	} else {
		return 0;
	}
}

var idle_master = func {
	var at = getprop("/controls/it2/at_master");
	var idle = getprop("/controls/it2/idle");
	if (idle & at) {
		setprop("/controls/it2/locks/throttle", "it-idle");
	} else {
		return 0;
	}
}

var clb_master = func {
	var at = getprop("/controls/it2/at_master");
	var clb = getprop("/controls/it2/clb");
	if (clb & at) {
		setprop("/controls/it2/locks/throttle", "it-clb");
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
	vnav_master();
	land_master();
}

var at_refresh = func {
	thr_master();
	idle_master();
	clb_master();
}

var ap_off = func {
	setprop("/controls/it2/ap_master", 0);
	setprop("/controls/it2/locks/lateral", 0);
	setprop("/controls/it2/locks/pitch", 0);
	var ap = getprop("/controls/it2/ap_master");
	if (ap) {
		setprop("/controls/it2/apoffsound", 1);
	}
	setprop("/controls/it2/apoffsound", 1);
	hdg_master();
	nav_master();
	alt_master();
	vs_master();
	altcap_master();
	flch_master();
	vnav_master();
	land_master();
}

var at_off = func {
	setprop("/controls/it2/at_master", 0);
	setprop("/controls/it2/locks/throttle", 0);
	thr_master();
	idle_master();
	clb_master();
}