# IT AUTOFLIGHT Logic by Joshua Davidson (it0uchpods/411).
# V3.0.0 Beta 2

var ap_logic_init = func {
	setprop("/it-autoflight/ap_master", 0);
	setprop("/it-autoflight/at_master", 0);
	setprop("/it-autoflight/hdg", 1);
	setprop("/it-autoflight/nav", 0);
	setprop("/it-autoflight/loc", 0);
	setprop("/it-autoflight/loc1", 0);
	setprop("/it-autoflight/alt", 0);
	setprop("/it-autoflight/vs", 0);
	setprop("/it-autoflight/app", 0);
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/altc", 0);
	setprop("/it-autoflight/flch", 1);
	setprop("/it-autoflight/vnav", 0);
	setprop("/it-autoflight/land", 0);
	setprop("/it-autoflight/aplatmode", 0);
	setprop("/it-autoflight/aphldtrk", 0);
	setprop("/it-autoflight/apvertmode", 3);
	setprop("/it-autoflight/aphldtrk2", 0);
	setprop("/it-autoflight/thr", 1);
	setprop("/it-autoflight/idle", 0);
	setprop("/it-autoflight/clb", 0);
	setprop("/it-autoflight/apthrmode", 0);
	setprop("/it-autoflight/apthrmode2", 0);
	print("IT-AUTOFLIGHT LOGIC ... OK!");
}

# AP Master System
setlistener("/it-autoflight/ap_mastersw", func {
  var apmas = getprop("/it-autoflight/ap_mastersw");
  if (apmas == 0) {
	setprop("/it-autoflight/ap_master", 0);
    ap_off();
  } else if (apmas == 1) {
	setprop("/it-autoflight/ap_master", 1);
	setprop("/it-autoflight/apoffsound", 0);
    ap_refresh();
  }
});

# AT Master System
setlistener("/it-autoflight/at_mastersw", func {
  var atmas = getprop("/it-autoflight/at_mastersw");
  if (atmas == 0) {
	setprop("/it-autoflight/at_master", 0);
    at_off();
  } else if (atmas == 1) {
	setprop("/it-autoflight/at_master", 1);
    at_refresh();
  }
});

# Flight Director Master System
setlistener("/it-autoflight/fd_mastersw", func {
  var fdmas = getprop("/it-autoflight/fd_mastersw");
  if (fdmas == 0) {
	setprop("/it-autoflight/fd_master", 0);
  } else if (fdmas == 1) {
	setprop("/it-autoflight/fd_master", 0);  # Because FD is not yet implemented. Will be 1 later.
  }
});

# Master Lateral
setlistener("/it-autoflight/aplatset", func {
  var latset = getprop("/it-autoflight/aplatset");
  if (latset == 0) {
	setprop("/it-autoflight/hdg", 1);
	setprop("/it-autoflight/nav", 0);
	setprop("/it-autoflight/loc", 0);
	setprop("/it-autoflight/loc1", 0);
	setprop("/it-autoflight/app", 0);
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/aplatmode", 0);
	setprop("/it-autoflight/aphldtrk", 0);
    hdg_master();
  } else if (latset == 1) {
	setprop("/it-autoflight/hdg", 0);
	setprop("/it-autoflight/nav", 1);
	setprop("/it-autoflight/loc", 0);
	setprop("/it-autoflight/loc1", 0);
	setprop("/it-autoflight/app", 0);
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/aplatmode", 1);
	setprop("/it-autoflight/aphldtrk", 1);
    nav_master();
  } else if (latset == 2) {
	setprop("/instrumentation/nav/signal-quality-norm", 0);
	setprop("/it-autoflight/hdg", 0);
	setprop("/it-autoflight/nav", 0);
	setprop("/it-autoflight/loc", 1);
	setprop("/it-autoflight/loc1", 1);
	setprop("/it-autoflight/app", 0);
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/apilsmode", 0);
  } else if (latset == 3) {
	setprop("/it-autoflight/hdg", 1);
	setprop("/it-autoflight/nav", 0);
	setprop("/it-autoflight/loc", 0);
	setprop("/it-autoflight/loc1", 0);
	setprop("/it-autoflight/app", 0);
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/aplatmode", 0);
	setprop("/it-autoflight/aphldtrk", 0);
    var hdgnow = int(getprop("/orientation/heading-magnetic-deg")+0.5);
	setprop("/it-autoflight/settings/heading-bug-deg", hdgnow);
    hdg_master();
  }
});

# Master Vertical
setlistener("/it-autoflight/apvertset", func {
  var vertset = getprop("/it-autoflight/apvertset");
  if (vertset == 0) {
	setprop("/it-autoflight/alt", 1);
	setprop("/it-autoflight/vs", 0);
	setprop("/it-autoflight/app", 0);
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/altc", 0);
	setprop("/it-autoflight/flch", 0);
	setprop("/it-autoflight/apvertmode", 0);
	setprop("/it-autoflight/aphldtrk2", 0);
	setprop("/it-autoflight/apilsmode", 0);
    var altnow = int((getprop("/instrumentation/altimeter/indicated-altitude-ft")+50)/100)*100;
	setprop("/it-autoflight/settings/target-altitude-ft", altnow);
	setprop("/it-autoflight/settings/target-altitude-ft-actual", altnow);
	flchthrust();
    alt_master();
  } else if (vertset == 1) {
    var altinput = getprop("/it-autoflight/settings/target-altitude-ft");
	setprop("/it-autoflight/settings/target-altitude-ft-actual", altinput);
	setprop("/it-autoflight/alt", 0);
	setprop("/it-autoflight/vs", 1);
	setprop("/it-autoflight/app", 0);
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/altc", 0);
	setprop("/it-autoflight/flch", 0);
	setprop("/it-autoflight/apvertmode", 1);
	setprop("/it-autoflight/aphldtrk2", 0);
	setprop("/it-autoflight/apilsmode", 0);
	flchthrust();
    vs_master();
  } else if (vertset == 2) {
	setprop("/instrumentation/nav/signal-quality-norm", 0);
	setprop("/it-autoflight/hdg", 0);
	setprop("/it-autoflight/nav", 0);
	setprop("/it-autoflight/loc", 1);
	setprop("/it-autoflight/loc1", 1);
	setprop("/instrumentation/nav/gs-rate-of-climb", 0);
	setprop("/it-autoflight/alt", 0);
	setprop("/it-autoflight/vs", 0);
	setprop("/it-autoflight/app", 1);
	setprop("/it-autoflight/app1", 1);
	setprop("/it-autoflight/altc", 0);
	setprop("/it-autoflight/flch", 0);
	setprop("/it-autoflight/apilsmode", 1);
  } else if (vertset == 3) {
	setprop("/it-autoflight/alt", 0);
	setprop("/it-autoflight/vs", 0);
	setprop("/it-autoflight/altc", 1);
	setprop("/it-autoflight/flch", 0);
	setprop("/it-autoflight/apvertmode", 0);
	setprop("/it-autoflight/aphldtrk2", 0);
    altcap_master();
  } else if (vertset == 4) {
    var altinput = getprop("/it-autoflight/settings/target-altitude-ft");
	setprop("/it-autoflight/settings/target-altitude-ft-actual", altinput);
	setprop("/it-autoflight/alt", 0);
	setprop("/it-autoflight/vs", 0);
	setprop("/it-autoflight/app", 0);
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/altc", 0);
	setprop("/it-autoflight/flch", 1);
	setprop("/it-autoflight/apvertmode", 4);
	setprop("/it-autoflight/aphldtrk2", 2);
	setprop("/it-autoflight/apilsmode", 0);
	flchtimer.start();
    flch_master();
  }
});

# Capture Logic
setlistener("/it-autoflight/apvertmode", func {
  var vertm = getprop("/it-autoflight/apvertmode");
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
  var alt = getprop("/it-autoflight/settings/target-altitude-ft-actual");
  var dif = calt - alt;
  if (dif < 500 and dif > -500) {
    setprop("/it-autoflight/apvertset", 3);
    setprop("/it-autoflight/apthrmode2", 0);
  }
  var altinput = getprop("/it-autoflight/settings/target-altitude-ft");
  setprop("/it-autoflight/settings/target-altitude-ft-actual", altinput);
}

# FLCH Thrust Mode Selector
var flchthrust = func {
  var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
  var alt = getprop("/it-autoflight/settings/target-altitude-ft-actual");
  var vertm = getprop("/it-autoflight/apvertmode");
  if (vertm == 4) {
    if (calt < alt) {
	  setprop("/it-autoflight/apthrmode2", 2);
    } else if (calt > alt) {
      setprop("/it-autoflight/apthrmode2", 1);
    } else {
	  setprop("/it-autoflight/apthrmode2", 0);
	  setprop("/it-autoflight/apvertset", 3);
	}
  } else {
	setprop("/it-autoflight/apthrmode2", 0);
	flchtimer.stop();
  }
}

# Thrust Modes
setlistener("/it-autoflight/apthrmode2", func {
  var thrmode2 = getprop("/it-autoflight/apthrmode2");
  if (thrmode2 == 0) {
	setprop("/it-autoflight/thr", 1);
	setprop("/it-autoflight/idle", 0);
	setprop("/it-autoflight/clb", 0);
	thr_master();
  } else if (thrmode2 == 1) {
	setprop("/it-autoflight/thr", 0);
	setprop("/it-autoflight/idle", 1);
	setprop("/it-autoflight/clb", 0);
	idle_master();
  } else if (thrmode2 == 2) {
	setprop("/it-autoflight/thr", 0);
	setprop("/it-autoflight/idle", 0);
	setprop("/it-autoflight/clb", 1);
	clb_master();
  }
});

# Timers
var altcaptt = maketimer(0.5, altcapt);
var flchtimer = maketimer(0.5, flchthrust);

# For Canvas Nav Display.

setlistener("/it-autoflight/settings/heading-bug-deg", func {
  setprop("/autopilot/settings/heading-bug-deg", getprop("/it-autoflight/settings/heading-bug-deg"));
});