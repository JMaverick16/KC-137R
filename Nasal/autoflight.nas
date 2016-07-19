# IT AUTOFLIGHT System Controller by Joshua Davidson (it0uchpods/411).
# V3.0.0 Beta 2

var ap_init = func {
	ap_logic_init();
	setprop("/it-autoflight/aplatset", 0);
	setprop("/it-autoflight/apvertset", 0);
	setprop("/it-autoflight/apthrset", 0);
	setprop("/it-autoflight/settings/target-speed-kt", 200);
	setprop("/it-autoflight/settings/target-mach", 0.68);
	setprop("/it-autoflight/settings/idlethr", 0);
	setprop("/it-autoflight/settings/clbthr", 900);
	setprop("/it-autoflight/settings/heading-bug-deg", 360);
	setprop("/it-autoflight/settings/target-altitude-ft", 10000);
	setprop("/it-autoflight/settings/target-altitude-ft-actual", 10000);
	setprop("/it-autoflight/settings/vertical-speed-fpm", 0);
	update_arms();
	ap_refresh();
	at_refresh();
	setprop("/it-autoflight/apvertset", 4);
	print("IT-AUTOFLIGHT ... OK!");
}

var update_arms = func {
  update_locarmelec();
  update_apparmelec();

  settimer(update_arms, 0.5);
}

var update_locarmelec = func {
  var ap = getprop("/it-autoflight/ap_master");
  var loc1 = getprop("/it-autoflight/loc1");
  if (loc1 & ap) {
  locarmcheck();
  } else {
  return 0;
  }
}

var update_apparmelec = func {
  var ap = getprop("/it-autoflight/ap_master");
  var app1 = getprop("/it-autoflight/app1");
  if (app1 & ap) {
  apparmcheck();
  } else {
  return 0;
  }
}

var hdg_master = func {
	var ap = getprop("/it-autoflight/ap_master");
	var hdg = getprop("/it-autoflight/hdg");
	if (hdg & ap) {
		setprop("/it-autoflight/locks/lateral", "it-hdg-sel");
		setprop("/it-autoflight/loc1", 0);
	} else {
		return 0;
	}
}

var nav_master = func {
	var ap = getprop("/it-autoflight/ap_master");
	var nav = getprop("/it-autoflight/nav");
	if (nav & ap) {
		setprop("/it-autoflight/locks/lateral", "it-nav-fms");
		setprop("/it-autoflight/loc1", 0);
	} else {
		return 0;
	}
}

var locarmcheck = func {
	var locdefl = getprop("instrumentation/nav/heading-needle-deflection-norm");
	if ((locdefl < 0.9233) and (getprop("instrumentation/nav/signal-quality-norm") > 0.99)) {
		setprop("/it-autoflight/locks/lateral", "it-vorloc");
		setprop("/it-autoflight/loc1", 0);
		setprop("/it-autoflight/aplatmode", 2);
		setprop("/it-autoflight/aphldtrk", 1);
	} else {
		return 0;
	}
}

var alt_master = func {
	var ap = getprop("/it-autoflight/ap_master");
	var alt = getprop("/it-autoflight/alt");
	if (alt & ap) {
		setprop("/it-autoflight/locks/pitch", "it-alt-cap-hld");
		setprop("/it-autoflight/app1", 0);
	} else {
		return 0;
	}
}

var vs_master = func {
	var ap = getprop("/it-autoflight/ap_master");
	var vs = getprop("/it-autoflight/vs");
	if (vs & ap) {
		setprop("/it-autoflight/locks/pitch", "it-vert-spd");
		setprop("/it-autoflight/app1", 0);
	} else {
		return 0;
	}
}

var apparmcheck = func {
	var signal = getprop("/instrumentation/nav/gs-needle-deflection-norm");
	if (signal <= -0.000000001) {
		setprop("/it-autoflight/locks/pitch", "it-gs");
		setprop("/it-autoflight/app1", 0);
		setprop("/it-autoflight/apvertmode", 2);
		setprop("/it-autoflight/aphldtrk2", 1);
	} else {
		return 0;
	}
}

var altcap_master = func {
	var ap = getprop("/it-autoflight/ap_master");
	var altc = getprop("/it-autoflight/altc");
	if (altc & ap) {
		setprop("/it-autoflight/locks/pitch", "it-alt-cap-hld");
	} else {
		return 0;
	}
}

var flch_master = func {
	var ap = getprop("/it-autoflight/ap_master");
	var flch = getprop("/it-autoflight/flch");
	if (flch & ap) {
		setprop("/it-autoflight/locks/pitch", "it-flch");
	} else {
		return 0;
	}
}

var vnav_master = func {
	var ap = getprop("/it-autoflight/ap_master");
	var vnav = getprop("/it-autoflight/vnav");
	if (vnav & ap) {
#		setprop("/it-autoflight/locks/pitch", "it-vnav");   # Disabled, because VNAV is not yet working.
	} else {
		return 0;
	}
}

var land_master = func {
	var ap = getprop("/it-autoflight/ap_master");
	var land = getprop("/it-autoflight/land");
	if (land & ap) {
#		setprop("/it-autoflight/locks/lateral", "it-land-lateral");   # Disabled, because AUTOLAND is not yet working.
#		setprop("/it-autoflight/locks/pitch", "it-land-pitch");   # Disabled, because AUTOLAND is not yet working.
	} else {
		return 0;
	}
}

var thr_master = func {
	var at = getprop("/it-autoflight/at_master");
	var thr = getprop("/it-autoflight/thr");
	if (thr & at) {
		setprop("/it-autoflight/locks/throttle", "it-thr");
	} else {
		return 0;
	}
}

var idle_master = func {
	var at = getprop("/it-autoflight/at_master");
	var idle = getprop("/it-autoflight/idle");
	if (idle & at) {
		setprop("/it-autoflight/locks/throttle", "it-idle");
	} else {
		return 0;
	}
}

var clb_master = func {
	var at = getprop("/it-autoflight/at_master");
	var clb = getprop("/it-autoflight/clb");
	if (clb & at) {
		setprop("/it-autoflight/locks/throttle", "it-clb");
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
	setprop("/it-autoflight/ap_master", 0);
	setprop("/it-autoflight/locks/lateral", 0);
	setprop("/it-autoflight/locks/pitch", 0);
	var ap = getprop("/it-autoflight/ap_master");
	if (ap) {
		setprop("/it-autoflight/apoffsound", 1);
	}
	setprop("/it-autoflight/apoffsound", 1);
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
	setprop("/it-autoflight/at_master", 0);
	setprop("/it-autoflight/locks/throttle", 0);
	thr_master();
	idle_master();
	clb_master();
}