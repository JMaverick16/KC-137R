# Lake of Constance Hangar :: M.Kraus
# Avril 2013
# This file is licenced under the terms of the GNU General Public Licence V2 or later
# ============================================
# The analog watch for the flightgear - rallye 
# ============================================
var sw = "/instrumentation/stopwatch/";


#============================== only stopwatch actions ================================
var sw_start_stop = func {
  var running = props.globals.getNode(sw~"running");

  if(!running.getBoolValue()){
    # start
    setprop(sw~"flight-time/start-time", getprop("/sim/time/elapsed-sec"));
    running.setBoolValue(1);
    sw_loop();
  }else{
    # stop
    var accu = getprop(sw~"flight-time/accu");
    accu += getprop("/sim/time/elapsed-sec") - getprop(sw~"flight-time/start-time");
    setprop(sw~"running",0);
    setprop(sw~"flight-time/accu", accu);
    sw_show(accu);
  }
}

var sw_reset = func {
  var running = props.globals.getNode(sw~"running");
  setprop(sw~"flight-time/accu", 0);

  if(running.getBoolValue()){
    setprop(sw~"flight-time/start-time", getprop("/sim/time/elapsed-sec"));
  }else{
    sw_show(0);
  }
}

var sw_loop = func {
  var running = props.globals.getNode(sw~"running");
  if(running.getBoolValue()){
    sw_show(getprop("/sim/time/elapsed-sec") - getprop(sw~"flight-time/start-time") + getprop(sw~"flight-time/accu"));
    settimer(sw_loop, 0.04);
  }
}

var sw_show = func(s) {
  var hours = s / 3600;
  var minutes = int(math.mod(s / 60, 60));
  var seconds = int(math.mod(s, 60));

  setprop(sw~"flight-time/total",s);
  setprop(sw~"flight-time/hours",hours);
  setprop(sw~"flight-time/minutes",minutes);
  setprop(sw~"flight-time/seconds",seconds);
}

var sw_show_time_on_screen = func{
  var hours = getprop(sw~"flight-time/hours") or 0;
  var minutes = getprop(sw~"flight-time/minutes") or 0;
  var seconds = getprop(sw~"flight-time/seconds") or 0;

  if (hours > 0){
    screen.log.write(sprintf("%3dh %02dmin %02dsec", hours, minutes, seconds), 0.0, 0.9, 0.0);
  }else{
    screen.log.write(sprintf("%02dmin %02dsec", minutes, seconds), 0.0, 0.9, 0.0);
  }
}
