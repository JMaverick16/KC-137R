# Lake of Constance Hangar :: M.Kraus
# Avril 2013
# This file is licenced under the terms of the GNU General Public Licence V2 or later
# ============================================
# The analog watch for the flightgear - rallye 
# ============================================
var p = "/instrumentation/frw/";


#============================== only stopwatch actions ================================
var frw_start_stop = func {
  var running = props.globals.getNode(p~"running");

  if(!running.getBoolValue()){
    # start
    setprop(p~"flight-time/start-time", getprop("/sim/time/elapsed-sec"));
    running.setBoolValue(1);
    frw_loop();
  }else{
    # stop
    var accu = getprop(p~"flight-time/accu");
    accu += getprop("/sim/time/elapsed-sec") - getprop(p~"flight-time/start-time");
    setprop(p~"running",0);
    setprop(p~"flight-time/accu", accu);
    frw_show(accu);
  }
}

var frw_reset = func {
  var running = props.globals.getNode(p~"running");
  setprop(p~"flight-time/accu", 0);

  if(running.getBoolValue()){
    setprop(p~"flight-time/start-time", getprop("/sim/time/elapsed-sec"));
  }else{
    frw_show(0);
  }
}

var frw_loop = func {
  var running = props.globals.getNode(p~"running");
  if(running.getBoolValue()){
    frw_show(getprop("/sim/time/elapsed-sec") - getprop(p~"flight-time/start-time") + getprop(p~"flight-time/accu"));
    settimer(frw_loop, 0.02);
  }
}

var frw_show = func(s) {
  var hours = s / 3600;
  var minutes = int(math.mod(s / 60, 60));
  var seconds = int(math.mod(s, 60));

  setprop(p~"flight-time/total",s);
  setprop(p~"flight-time/hours",hours);
  setprop(p~"flight-time/minutes",minutes);
  setprop(p~"flight-time/seconds",seconds);
}

var frw_show_time_on_screen = func{
  var hours = getprop(p~"flight-time/hours") or 0;
  var minutes = getprop(p~"flight-time/minutes") or 0;
  var seconds = getprop(p~"flight-time/seconds") or 0;

  if (hours > 0){
    screen.log.write(sprintf("%3dh %02dmin %02dsec", hours, minutes, seconds), 0.0, 0.7, 0.0);
  }else{
    screen.log.write(sprintf("%02dmin %02dsec", minutes, seconds), 0.0, 0.7, 0.0);
  }
}

#=============================== Flightgear Rallye Mode actions =======================================
var frw_mode = func {
  #stop all action first and reset
  setprop(p~"running",0);
  frw_reset();

  #fire up the flightgear rallye controler
  frw_control();
  
}

var frw_control = func {
  var frw_mode = props.globals.getNode(p~"btn-mode");
  if(frw_mode.getBoolValue()){
    var frw_agl  = getprop("/position/altitude-agl-ft") - 6;
    var airspeed = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
    var running  = props.globals.getNode(p~"running");
    var crashed  = props.globals.getNode("/sim/crashed");

      if(frw_agl > 4 and !running.getBoolValue() and !crashed.getBoolValue()){
        frw_start_stop();
      }
      if(frw_agl < 4 and running.getBoolValue() and airspeed < 40.0 or crashed.getBoolValue()){
        var accu = getprop(p~"flight-time/accu");
        accu += getprop("/sim/time/elapsed-sec") - getprop(p~"flight-time/start-time");
        setprop(p~"running",0);
        setprop(p~"flight-time/accu", accu);
        frw_show(accu);
      }

      # fix the bug, if the aircraft chrashed with frw_mode the stopwatch was continued
      if(crashed.getBoolValue()) frw_mode.setBoolValue(0);

    settimer(frw_control, 1);
  }
}

