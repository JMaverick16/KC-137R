####    autopilot/BendixPB20.nas help-functions adapted for 707                                ####
####    Author: Markus Bulik                                                                   ####
####    This file is licenced under the terms of the GNU General Public Licence V2 or later    ####

##############################################################################
##                                                                          ##
## AP - routines for 'Bendix PB 20' autopilot system                        ##
##                                                                          ##
##############################################################################


### Bendix PB 20 ###
# Knobs:
# /autopilot/Bendix-PB-20/controls/active : true/false
# /autopilot/Bendix-PB-20/controls/alt-active : true/false
# /autopilot/Bendix-PB-20/controls/mode-selector : 0: NAV, 1: HDG, 2: MAN, 3: LOC VOR, 4: GS AUTO, 5: GS MAN
# /autopilot/Bendix-PB-20/settings/pitch-wheel-deg : -30 .. 30
# /autopilot/Bendix-PB-20/settings/roll-knob-deg : -35 .. 35

# init
var listenerApPB20InitFunc = func {
	# do initializations of new properties

	setprop("/autopilot/Bendix-PB-20/controls/active", 0);
	setprop("/autopilot/Bendix-PB-20/controls/alt-active", 0);
	setprop("/autopilot/Bendix-PB-20/controls/mode-selector", 2);
	setprop("/autopilot/Bendix-PB-20/settings/roll-knob-deg", 0);
	setprop("/autopilot/Bendix-PB-20/settings/pitch-wheel-deg", 0);
	setprop("/autopilot/Bendix-PB-20/mutex", "");
}
setlistener("/sim/signals/fdm-initialized", listenerApPB20InitFunc);

# Mutex - for synchronization of the listener-events
var bendixPB20MutexSet = func(value) {
	setprop("/autopilot/Bendix-PB-20/mutex", value);
}
var bendixPB20MutexReset = func {
	setprop("/autopilot/Bendix-PB-20/mutex", "");
}
var bendixPB20MutexResetFunc = func {
	if (getprop("/autopilot/Bendix-PB-20/mutex") != "") {
		settimer(bendixPB20MutexReset, 0.2);
	}
}
setlistener("/autopilot/Bendix-PB-20/mutex", bendixPB20MutexResetFunc);

# Active-switch
var bendixPB20ActivePrev = 0;
var listenerApPB20ActiveFunc = func {
	if (bendixPB20ActivePrev == 0) {
		if (getprop("/autopilot/Bendix-PB-20/controls/active") == 1) {
			if (getprop("/autopilot/Bendix-PB-20/mutex") == "") {
				setprop("/autopilot/Bendix-PB-20/controls/mode-selector", 2);
			}
		}
	}
	bendixPB20Active = getprop("/autopilot/Bendix-PB-20/controls/active");
}
setlistener("/autopilot/Bendix-PB-20/controls/active", listenerApPB20ActiveFunc);

# Mode-selector
#
# !!! FEHLER: bei zurückschalten von Mode 4,5 auf 3,2,1 bleibt GS eingeschaltet anstatt ALT (bei eingeschaltetem Alt-Switch) !!!
#
var listenerApPB20ModeFunc = func {

	if (	getprop("/autopilot/Bendix-PB-20/mutex") == "" or
		getprop("/autopilot/Bendix-PB-20/mutex") == "MODE") {
		bendixPB20MutexSet("MODE");
	}
	else {
		return;
	}

	if (getprop("/autopilot/Bendix-PB-20/controls/active") == 1) {
		#print ("-> listenerApPB20ModeFunc -> Mode-selector=", getprop("/autopilot/Bendix-PB-20/controls/mode-selector"));

		if (	getprop("/autopilot/Bendix-PB-20/controls/mode-selector") == 0) {
			# NAV - Mode

			if (getprop("autopilot/route-manager/active") == 1 and getprop("autopilot/route-manager/airborne") == 1) {
				setprop("/autopilot/locks/passive-mode", 1);

				# resets
				setprop("/autopilot/locks/altitude", "");
				setprop("/autopilot/locks/heading", "");
			}
			else {
				gui.popupTip("You must be airborne and a route must be active to activate this mode !");
			}
		}
		if (getprop("/autopilot/Bendix-PB-20/controls/mode-selector") == 1) {
			# HDG - Mode

			setprop("/autopilot/locks/heading", "dg-heading-hold");

			# resets
			if (getprop("/autopilot/Bendix-PB-20/controls/alt-active") == 0) {
				setprop("/autopilot/locks/altitude", "");
			}
			else {
				setprop("/autopilot/locks/altitude", "altitude-hold");
			}
			setprop("/autopilot/locks/passive-mode", 0);
		}
		if (getprop("/autopilot/Bendix-PB-20/controls/mode-selector") == 2) {
			# MAN - Mode

			#var rollKnobDeg = getprop("/instrumentation/turn-indicator/indicated-turn-rate") * 36.63;
			var rollKnobDeg = 0.0;
			setprop("/autopilot/Bendix-PB-20/settings/roll-knob-deg", rollKnobDeg);
			listenerApPB20MANRollFunc();

			setprop("/autopilot/locks/heading", "wing-leveler");

			if (getprop("/autopilot/Bendix-PB-20/controls/alt-active") == 0) {
				setprop("/autopilot/Bendix-PB-20/settings/pitch-wheel-deg", getprop("/orientation/pitch-deg"));
				listenerApPB20MANPitchFunc();

				setprop("/autopilot/locks/altitude", "pitch-hold");
			}
			else {
				setprop("/autopilot/locks/altitude", "altitude-hold");
			}

			# resets
			setprop("/autopilot/locks/passive-mode", 0);
		}
		if (getprop("/autopilot/Bendix-PB-20/controls/mode-selector") == 3) {
			# LOC VOR - Mode

			setprop("/autopilot/locks/heading", "nav1-hold");

			# resets
			if (getprop("/autopilot/Bendix-PB-20/controls/alt-active") == 0) {
				setprop("/autopilot/locks/altitude", "");
			}
			else {
				setprop("/autopilot/locks/altitude", "altitude-hold");
			}
			setprop("/autopilot/locks/passive-mode", 0);
		}
		if (getprop("/autopilot/Bendix-PB-20/controls/mode-selector") == 4) {
			# GS AUTO - Mode

			setprop("/autopilot/locks/heading", "nav1-hold");
			setprop("/autopilot/locks/altitude", "gs1-hold");

			# resets
			setprop("/autopilot/locks/passive-mode", 0);
			setprop("/autopilot/Bendix-PB-20/controls/alt-active", 0);
		}
		if (getprop("/autopilot/Bendix-PB-20/controls/mode-selector") == 5) {
			# GS MAN - Mode

			setprop("/autopilot/locks/heading", "nav1-hold");
			if (getprop("/autopilot/Bendix-PB-20/controls/alt-active") == 0) {
				setprop("/autopilot/locks/altitude", "");
			}
			else {
				setprop("/autopilot/locks/altitude", "altitude-hold");
			}

			gsMANAltControl();

			# resets
			setprop("/autopilot/locks/passive-mode", 0);
		}
	}
	else {
		# switched off
		setprop("/autopilot/locks/heading", "");
		setprop("/autopilot/locks/altitude", "");
		setprop("/autopilot/internal/wing-leveler-target-roll-deg", 0.0);
		setprop("/autopilot/locks/passive-mode", 0);
		setprop("/autopilot/locks/speed", "");	# for compatibility only (Bendix-PB-20 don't have speed-mode)
	}
}
setlistener("/autopilot/Bendix-PB-20/controls/active", listenerApPB20ModeFunc);
setlistener("/autopilot/Bendix-PB-20/controls/mode-selector", listenerApPB20ModeFunc, 1,0);

# switches off 'altitude-hold' if GS is in range and all other conditions are satisfied
var gsMANAltControl = func {
	if (	getprop("/autopilot/Bendix-PB-20/controls/active") == 1 and
		getprop("/autopilot/Bendix-PB-20/controls/mode-selector") == 5) {
		if (getprop("instrumentation/nav[0]/gs-in-range") == 0) {
			settimer(gsMANAltControl, 0.2);
		}
		else {
			setprop("/autopilot/locks/altitude", "");
		}
	}
}


# MAN - Mode - roll-selector
var listenerApPB20MANRollFunc = func {
    # if roll-knob-deg turn, the mode selector jump to mode 2
	setprop("/autopilot/Bendix-PB-20/controls/mode-selector", 2);

	if (	getprop("/autopilot/Bendix-PB-20/controls/active") == 1 and
		getprop("/autopilot/Bendix-PB-20/controls/mode-selector") == 2) {

		setprop("/autopilot/internal/wing-leveler-target-roll-deg", getprop("/autopilot/Bendix-PB-20/settings/roll-knob-deg"));
	}
}
setlistener("/autopilot/Bendix-PB-20/settings/roll-knob-deg", listenerApPB20MANRollFunc);

# MAN - Mode - pitch-selector
var listenerApPB20MANPitchFunc = func {

	if (	getprop("/autopilot/Bendix-PB-20/controls/active") == 1 and
		getprop("/autopilot/Bendix-PB-20/controls/mode-selector") == 2) {
		if (getprop("/autopilot/Bendix-PB-20/controls/alt-active") == 0) {

			var pitchDeg = getprop("/autopilot/Bendix-PB-20/settings/pitch-wheel-deg");
			pitchDeg = (pitchDeg > 30 ? 30 : pitchDeg);
			pitchDeg = (pitchDeg < -30 ? -30 : pitchDeg);
			setprop("/autopilot/settings/target-pitch-deg", pitchDeg);
		}
	}
}
setlistener("/autopilot/Bendix-PB-20/settings/pitch-wheel-deg", listenerApPB20MANPitchFunc);

# ALT switch
var listenerApPB20AltFunc = func {

	if (getprop("/autopilot/Bendix-PB-20/mutex") == "") {
		bendixPB20MutexSet("PB20-ALT");
	}
	else {
		return;
	}

	if (getprop("/autopilot/Bendix-PB-20/controls/active") == 1) {
		if (getprop("/autopilot/Bendix-PB-20/controls/alt-active") == 1) {

			# set altitude-hold-value to the actual altitude plus an offset dependent on vspeed

			var vspeed = getprop("/velocities/vertical-speed-fps");
			var altOffset = vspeed * 5;	# ft climed/falled in 5 seconds

			var altitudeFt = getprop("/instrumentation/altimeter/indicated-altitude-ft") + altOffset;
			setprop("/autopilot/settings/target-altitude-ft", altitudeFt);

			setprop("/autopilot/locks/altitude", "altitude-hold");
		}
		else {
			if (getprop("/autopilot/Bendix-PB-20/controls/mode-selector") == 2) {
				setprop("/autopilot/locks/altitude", "pitch-hold");
			}
			else {
				if (getprop("/autopilot/locks/altitude") == "altitude-hold") {
					setprop("/autopilot/locks/altitude", "");
				}
			}
		}
	}
	else {
		setprop("/autopilot/locks/altitude", "");
	}
}
setlistener("/autopilot/Bendix-PB-20/controls/alt-active", listenerApPB20AltFunc);


# settings from FG-menu (F11)

listenerApPB20SetHeadingFunc = func {

	if (	getprop("/autopilot/Bendix-PB-20/mutex") == "" or
		getprop("/autopilot/Bendix-PB-20/mutex") == "PASSIVE") {
		bendixPB20MutexSet("HEADING");
	}
	else {
		return;
	}

	menuSwitchBendixPB20();
}
setlistener("/autopilot/locks/heading", listenerApPB20SetHeadingFunc);

listenerApPB20SetPassiveModeFunc = func {

	# unfortunalety 'passive-mode' is triggered many times, we only need to act if it's wsitched to '1'
	if (	getprop("/autopilot/Bendix-PB-20/mutex") == "" and
		getprop("/autopilot/locks/passive-mode") == 1) {
		bendixPB20MutexSet("PASSIVE");
	}
	else {
		return;
	}

	if (getprop("/autopilot/locks/passive-mode") == 1) {
		if (getprop("autopilot/route-manager/active") == 1 and getprop("autopilot/route-manager/airborne") == 1) {
			setprop("/autopilot/Bendix-PB-20/controls/active", 1);
			setprop("/autopilot/Bendix-PB-20/controls/mode-selector", 0);
		}
		else {
			gui.popupTip("You must be airborne and a route must be active to activate this mode !");
			setprop("/autopilot/locks/passive-mode", 0);
		}

		setprop("/autopilot/Bendix-PB-20/controls/active", 1);
		setprop("/autopilot/Bendix-PB-20/controls/mode-selector", 0);
	}
}
setlistener("/autopilot/locks/passive-mode", listenerApPB20SetPassiveModeFunc);

listenerApPB20SetAltitudeFunc = func {

	if (	getprop("/autopilot/Bendix-PB-20/mutex") == "" or
		getprop("/autopilot/Bendix-PB-20/mutex") == "PASSIVE") {
		bendixPB20MutexSet("ALT");
	}
	else {
		return;
	}

	if (getprop("/autopilot/locks/altitude") == "altitude-hold") {
		setprop("/autopilot/Bendix-PB-20/controls/active", 1);
		setprop("/autopilot/Bendix-PB-20/controls/alt-active", 1);
		if (getprop("/autopilot/Bendix-PB-20/controls/mode-selector") == 2) {
			setprop("/autopilot/locks/heading", "wing-leveler");
		}
	}
	else {
		setprop("/autopilot/Bendix-PB-20/controls/alt-active", 0);
	}

	menuSwitchBendixPB20();
}
setlistener("/autopilot/locks/altitude", listenerApPB20SetAltitudeFunc);

var menuSwitchBendixPB20 = func {

	if (getprop("/autopilot/locks/heading") == "wing-leveler") {
		setprop("/autopilot/Bendix-PB-20/controls/active", 1);
		setprop("/autopilot/Bendix-PB-20/controls/mode-selector", 2);
	}
	elsif (getprop("/autopilot/locks/heading") == "dg-heading-hold") {
		setprop("/autopilot/Bendix-PB-20/controls/active", 1);
		setprop("/autopilot/Bendix-PB-20/controls/mode-selector", 1);
	}
	elsif (	getprop("/autopilot/locks/heading") == "nav1-hold") {
		if (getprop("/autopilot/locks/altitude") == "gs1-hold") {
			setprop("/autopilot/Bendix-PB-20/controls/active", 1);
			setprop("/autopilot/Bendix-PB-20/controls/mode-selector", 4);
		}
		else {
			setprop("/autopilot/Bendix-PB-20/controls/active", 1);
			setprop("/autopilot/Bendix-PB-20/controls/mode-selector", 3);
		}
	}
	elsif (getprop("/autopilot/locks/heading") == "") {
		if (getprop("/autopilot/locks/altitude") == "") {
			setprop("/autopilot/Bendix-PB-20/controls/active", 0);
			setprop("/autopilot/Bendix-PB-20/controls/alt-active", 0);
			setprop("/autopilot/Bendix-PB-20/controls/mode-selector", 2);
		}
	}
}

listenerApPB20SetPitchFunc = func {

	setprop("/autopilot/Bendix-PB-20/settings/pitch-wheel-deg", getprop("/autopilot/settings/target-pitch-deg"));
}
setlistener("/autopilot/locks/altitude", listenerApPB20SetPitchFunc);
setlistener("/autopilot/settings/pitch-hold", listenerApPB20SetPitchFunc);

### Bendix PB 20 ###

setlistener("/controls/special/yoke-switch1", func (s1){
    var s1 = s1.getBoolValue();
    if (s1 == 1){
      setprop("/autopilot/Bendix-PB-20/controls/active", 0);
      setprop("/autopilot/Bendix-PB-20/controls/alt-active", 0);
		  setprop("/autopilot/Bendix-PB-20/controls/mode-selector", 2);
      setprop("/autopilot/Bendix-PB-20/settings/pitch-wheel-deg", 0);
			setprop("/autopilot/settings/target-pitch-deg", 0);
			setprop("/autopilot/locks/altitude", "");
			setprop("/autopilot/locks/speed", "");
    }
});

