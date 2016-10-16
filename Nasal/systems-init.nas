# KC-137R System Init File

setlistener("/sim/signals/fdm-initialized", func {
  itaf.ap_init();
  var autopilot = gui.Dialog.new("sim/gui/dialogs/autopilot/dialog", "Aircraft/KC-137R/Systems/autopilot-dlg.xml");
  setprop("/it-autoflight/settings/retard-enable", 1);  # Enable or disable automatic autothrottle retard.
  setprop("/it-autoflight/settings/retard-ft", 20);     # Add this to change the retard altitude, default is 50ft AGL.
  setprop("/it-autoflight/settings/land-flap", 0.6);    # Define the landing flaps here. This is needed for autoland, and retard.
  setprop("/it-autoflight/settings/land-enable", 1);    # Enable or disable automatic landing.
  setprop("/controls/internal/value1", "1");
  setprop("/controls/flight/speedbrake-arm", "0");
  setprop("/b707/anti-ice/window-heat-cap-switch", "0");
  setprop("/b707/anti-ice/window-heat-fo-switch", "0");
  setprop("/indicators/asi/vmo", "380");
  b707.compass_swing();
  print("OCTAL ... FINE!");
});