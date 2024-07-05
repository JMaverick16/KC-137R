var radar_fc = compat_failure_modes.set_unserviceable("instrumentation/radar");
FailureMgr.add_failure_mode("instrumentation/radar", "Radar", radar_fc);

var rwr_fc = compat_failure_modes.set_unserviceable("instrumentation/rwr");
FailureMgr.add_failure_mode("instrumentation/rwr", "RWR", rwr_fc);


## FLARES
var flareCount = -1;
var flareStart = -1;

var loop_flare = func {
    # Flare/chaff release
    if (getprop("ai/submodels/submodel[0]/flare-release-snd") == nil) {
        setprop("ai/submodels/submodel[0]/flare-release-snd", 0);
        setprop("ai/submodels/submodel[0]/flare-release-out-snd", 0);
    }
    var flareOn = getprop("ai/submodels/submodel[0]/flare-release-cmd");
    var flareOnA = getprop("ai/submodels/submodel[0]/flare-auto-release-cmd") != nil and getprop("ai/submodels/submodel[0]/flare-auto-release-cmd") > rand() and getprop("instrumentation/rwr/auto-cm") and getprop("ai/submodels/submodel[0]/flare-release-cmd") == 0;
    flareOn = flareOn or flareOnA;
    if (flareOn == 1 and getprop("ai/submodels/submodel[0]/flare-release") == 0
            and getprop("ai/submodels/submodel[0]/flare-release-out-snd") == 0
            and getprop("ai/submodels/submodel[0]/flare-release-snd") == 0) {
        flareCount = getprop("ai/submodels/submodel[0]/count");
        flareStart = getprop("sim/time/elapsed-sec");
        setprop("ai/submodels/submodel[0]/flare-release-cmd", 0);
        if (flareCount > 0) {
            # release a flare
            setprop("ai/submodels/submodel[0]/flare-release-snd", 1);
            setprop("ai/submodels/submodel[0]/flare-release", 1);
            setprop("rotors/main/blade[3]/flap-deg", flareStart);
            setprop("rotors/main/blade[3]/position-deg", flareStart);
            damage.flare_released();
        } else {
            # play the sound for out of flares
            setprop("ai/submodels/submodel[0]/flare-release-out-snd", 1);
        }
    }
    if (getprop("ai/submodels/submodel[0]/flare-release-snd") == 1 and (flareStart + 1) < getprop("sim/time/elapsed-sec")) {
        setprop("ai/submodels/submodel[0]/flare-release-snd", 0);
        setprop("rotors/main/blade[3]/flap-deg", 0);
        setprop("rotors/main/blade[3]/position-deg", 0);#MP interpolates between numbers, so nil is better than 0.
    }
    if (getprop("ai/submodels/submodel[0]/flare-release-out-snd") == 1 and (flareStart + 1) < getprop("sim/time/elapsed-sec")) {
        setprop("ai/submodels/submodel[0]/flare-release-out-snd", 0);
    }
    if (flareCount > getprop("ai/submodels/submodel[0]/count")) {
        # A flare was released in last loop, we stop releasing flares, so user have to press button again to release new.
        setprop("ai/submodels/submodel[0]/flare-release", 0);
        flareCount = -1;
    }
}
var flaretimer = maketimer(0.1, loop_flare);
flaretimer.start();


var resetView = func () {
    var hd = getprop("sim/current-view/heading-offset-deg");
    var hd_t = getprop("sim/current-view/config/heading-offset-deg");
    var field = getprop("sim/current-view/config/default-field-of-view-deg");
    var raw = getprop("sim/current-view/view-number-raw");
    var pos = getprop("sim/current-view/config/pitch-offset-deg");
    var ros = getprop("sim/current-view/config/roll-offset-deg");
    if (!checkNumber([hd,"hd"],[hd_t,"hd_t"],[field,"field"],[raw,"raw"],[pos,"pos"],[ros,"ros"])) {
        print("Problem was in view ", raw);
        return;
    }
    if (hd > 180) {
        hd_t = hd_t + 360;
    }
    interpolate("sim/current-view/field-of-view", field, 0.66);
    interpolate("sim/current-view/heading-offset-deg", hd_t,0.66);
    interpolate("sim/current-view/pitch-offset-deg", pos,0.66);
    interpolate("sim/current-view/roll-offset-deg", ros,0.66);

    var x = getprop("sim/view["~raw~"]/config/x-offset-m");
    var y = getprop("sim/view["~raw~"]/config/y-offset-m");
    var z = getprop("sim/view["~raw~"]/config/z-offset-m");
    if (!checkNumber([x,"x"],[y,"y"],[z,"z"])) {
        print("Problem was in view ", raw);
        return;
    }
    interpolate("sim/current-view/x-offset-m", x, 1);
    interpolate("sim/current-view/y-offset-m", y, 1);
    interpolate("sim/current-view/z-offset-m", z, 1);
}

var checkNumber = func {
    # Check if number is nil or NaN and print to console if it is.
    # Can take any number of arguments.
    foreach(var test ; arg) {
        if (test[0] == nil or debug.isnan(test[0])) {
            print("ERROR: Variable ",test[1]," is not valid number NaN=",debug.isnan(test[0])," nil=",test[0]==nil);
            return 0;
        }
    }
    return 1;
}