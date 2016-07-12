# IT AUTOFLIGHT Logic by Joshua Davidson (it0uchpods/411).
# V2.10

var ap_logic_init = func {
	setprop("/controls/it2/ap_master", 0);
	setprop("/controls/it2/at_master", 0);
	setprop("/controls/it2/hdg", 1);
	setprop("/controls/it2/nav", 0);
	setprop("/controls/it2/loc", 0);
	setprop("/controls/it2/loc1", 0);
	setprop("/controls/it2/alt", 0);
	setprop("/controls/it2/vs", 0);
	setprop("/controls/it2/app", 0);
	setprop("/controls/it2/app1", 0);
	setprop("/controls/it2/altc", 0);
	setprop("/controls/it2/flch", 1);
	setprop("/controls/it2/aplatmode", 0);
	setprop("/controls/it2/aphldtrk", 0);
	setprop("/controls/it2/apvertmode", 3);
	setprop("/controls/it2/aphldtrk2", 0);
	setprop("/controls/it2/apoffsound", 1);
	setprop("/controls/it2/thr", 1);
	setprop("/controls/it2/idle", 0);
	setprop("/controls/it2/clb", 0);
	setprop("/controls/it2/apthrmode", 0);
	setprop("/controls/it2/apthrmode2", 0);
	print("AUTOFLIGHT LOGIC ... FINE!");
}

# AP Master System
setlistener("/controls/it2/ap_mastersw", func {
  var apmas = getprop("/controls/it2/ap_mastersw");
  if (apmas == 0) {
	setprop("/controls/it2/ap_master", 0);
    ap_off();
  } else if (apmas == 1) {
	setprop("/controls/it2/ap_master", 1);
	setprop("/controls/it2/apoffsound", 0);
    ap_refresh();
  }
});

# AT Master System
setlistener("/controls/it2/at_mastersw", func {
  var atmas = getprop("/controls/it2/at_mastersw");
  if (atmas == 0) {
	setprop("/controls/it2/at_master", 0);
    at_off();
  } else if (atmas == 1) {
	setprop("/controls/it2/at_master", 1);
    at_refresh();
  }
});

# Flight Director Master System
setlistener("/controls/it2/fd_mastersw", func {
  var fdmas = getprop("/controls/it2/fd_mastersw");
  if (fdmas == 0) {
	setprop("/controls/it2/fd_master", 0);
  } else if (fdmas == 1) {
	setprop("/controls/it2/fd_master", 1);
  }
});

# Master Lateral
setlistener("/controls/it2/aplatset", func {
  var latset = getprop("/controls/it2/aplatset");
  if (latset == 0) {
	setprop("/controls/it2/hdg", 1);
	setprop("/controls/it2/nav", 0);
	setprop("/controls/it2/loc", 0);
	setprop("/controls/it2/loc1", 0);
	setprop("/controls/it2/app", 0);
	setprop("/controls/it2/app1", 0);
	setprop("/controls/it2/aplatmode", 0);
	setprop("/controls/it2/aphldtrk", 0);
    hdg_master();
  } else if (latset == 1) {
	setprop("/controls/it2/hdg", 0);
	setprop("/controls/it2/nav", 1);
	setprop("/controls/it2/loc", 0);
	setprop("/controls/it2/loc1", 0);
	setprop("/controls/it2/app", 0);
	setprop("/controls/it2/app1", 0);
	setprop("/controls/it2/aplatmode", 1);
	setprop("/controls/it2/aphldtrk", 1);
    nav_master();
  } else if (latset == 2) {
	setprop("/instrumentation/nav/signal-quality-norm", 0);
	setprop("/controls/it2/hdg", 0);
	setprop("/controls/it2/nav", 0);
	setprop("/controls/it2/loc", 1);
	setprop("/controls/it2/loc1", 1);
	setprop("/controls/it2/apilsmode", 0);
  } else if (latset == 3) {
	setprop("/controls/it2/hdg", 1);
	setprop("/controls/it2/nav", 0);
	setprop("/controls/it2/loc", 0);
	setprop("/controls/it2/loc1", 0);
	setprop("/controls/it2/app", 0);
	setprop("/controls/it2/app1", 0);
	setprop("/controls/it2/aplatmode", 0);
	setprop("/controls/it2/aphldtrk", 0);
    var hdgnow = int(getprop("/orientation/heading-magnetic-deg")+0.5);
	setprop("/autopilot/settings/heading-bug-deg", hdgnow);
    hdg_master();
  }
});

# Master Vertical
setlistener("/controls/it2/apvertset", func {
  var vertset = getprop("/controls/it2/apvertset");
  if (vertset == 0) {
	setprop("/controls/it2/alt", 1);
	setprop("/controls/it2/vs", 0);
	setprop("/controls/it2/app", 0);
	setprop("/controls/it2/app1", 0);
	setprop("/controls/it2/altc", 0);
	setprop("/controls/it2/flch", 0);
	setprop("/controls/it2/apvertmode", 0);
	setprop("/controls/it2/aphldtrk2", 0);
	setprop("/controls/it2/apilsmode", 0);
    var altnow = int((getprop("/instrumentation/altimeter/indicated-altitude-ft")+50)/100)*100;
	setprop("/autopilot/settings/target-altitude-ft", altnow);
	flchthrust();
    alt_master();
  } else if (vertset == 1) {
	setprop("/controls/it2/alt", 0);
	setprop("/controls/it2/vs", 1);
	setprop("/controls/it2/app", 0);
	setprop("/controls/it2/app1", 0);
	setprop("/controls/it2/altc", 0);
	setprop("/controls/it2/flch", 0);
	setprop("/controls/it2/apvertmode", 1);
	setprop("/controls/it2/aphldtrk2", 0);
	setprop("/controls/it2/apilsmode", 0);
	flchthrust();
    vs_master();
  } else if (vertset == 2) {
	setprop("/instrumentation/nav/signal-quality-norm", 0);
	setprop("/controls/it2/hdg", 0);
	setprop("/controls/it2/nav", 0);
	setprop("/controls/it2/loc", 1);
	setprop("/controls/it2/loc1", 1);
	setprop("/instrumentation/nav/gs-rate-of-climb", 0);
	setprop("/controls/it2/alt", 0);
	setprop("/controls/it2/vs", 0);
	setprop("/controls/it2/app", 1);
	setprop("/controls/it2/app1", 1);
	setprop("/controls/it2/altc", 0);
	setprop("/controls/it2/flch", 0);
	setprop("/controls/it2/apilsmode", 1);
  } else if (vertset == 3) {
	setprop("/controls/it2/alt", 0);
	setprop("/controls/it2/vs", 0);
	setprop("/controls/it2/altc", 1);
	setprop("/controls/it2/flch", 0);
	setprop("/controls/it2/apvertmode", 0);
	setprop("/controls/it2/aphldtrk2", 0);
    altcap_master();
  } else if (vertset == 4) {
	setprop("/controls/it2/alt", 0);
	setprop("/controls/it2/vs", 0);
	setprop("/controls/it2/app", 0);
	setprop("/controls/it2/app1", 0);
	setprop("/controls/it2/altc", 0);
	setprop("/controls/it2/flch", 1);
	setprop("/controls/it2/apvertmode", 4);
	setprop("/controls/it2/aphldtrk2", 2);
	setprop("/controls/it2/apilsmode", 0);
	flchtimer.start();
    flch_master();
  }
});

# Capture Logic
setlistener("/controls/it2/apvertmode", func {
  var vertm = getprop("/controls/it2/apvertmode");
	if (vertm == 1) {
      altcaptt.start();
    } else if (vertm == 4) {
      altcaptt.start();	
	} else {
	  altcaptt.stop();
    }
});

var altcapt = func {
  var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
  var alt = getprop("/autopilot/settings/target-altitude-ft");
  var dif = calt - alt;
  if (dif < 400 and dif > -400) {
    setprop("/controls/it2/apvertset", 3);
    setprop("/controls/it2/apthrmode2", 0);
  }
}

# FLCH Thrust Mode Selector
var flchthrust = func {
  var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
  var alt = getprop("/autopilot/settings/target-altitude-ft");
  var vertm = getprop("/controls/it2/apvertmode");
  if (vertm == 4) {
    if (calt < alt) {
	  setprop("/controls/it2/apthrmode2", 2);
    } else if (calt > alt) {
      setprop("/controls/it2/apthrmode2", 1);
    } else {
	  setprop("/controls/it2/apthrmode2", 0);
	  setprop("/controls/it2/apvertset", 3);
	}
  } else {
	setprop("/controls/it2/apthrmode2", 0);
	flchtimer.stop();
  }
}

# Thrust Modes
setlistener("/controls/it2/apthrmode2", func {
  var thrmode2 = getprop("/controls/it2/apthrmode2");
  if (thrmode2 == 0) {
	setprop("/controls/it2/thr", 1);
	setprop("/controls/it2/idle", 0);
	setprop("/controls/it2/clb", 0);
	thr_master();
  } else if (thrmode2 == 1) {
	setprop("/controls/it2/thr", 0);
	setprop("/controls/it2/idle", 1);
	setprop("/controls/it2/clb", 0);
	idle_master();
  } else if (thrmode2 == 2) {
	setprop("/controls/it2/thr", 0);
	setprop("/controls/it2/idle", 0);
	setprop("/controls/it2/clb", 1);
	clb_master();
  }
});

# Timers
var altcaptt = maketimer(0.5, altcapt);
var flchtimer = maketimer(0.5, flchthrust);