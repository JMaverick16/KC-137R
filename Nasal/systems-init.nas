# KC-137R System Init File

setlistener("/sim/signals/fdm-initialized", func {
  itaf.ap_init();
  var autopilot = gui.Dialog.new("sim/gui/dialogs/autopilot/dialog", "Aircraft/KC-137R/Systems/autopilot-dlg.xml");
  setprop("/controls/internal/value1", "1");
  setprop("/controls/flight/speedbrake-arm", "0");
  setprop("/b707/anti-ice/window-heat-cap-switch", "0");
  setprop("/b707/anti-ice/window-heat-fo-switch", "0");
  setprop("/indicators/asi/vmo", "380");
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