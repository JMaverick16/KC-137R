# KC-137R System Init File

setlistener("/sim/signals/fdm-initialized", func {
  it2.ap_init();
  var autopilot = gui.Dialog.new("sim/gui/dialogs/autopilot/dialog", "Aircraft/KC-137R/Systems/autopilot-dlg.xml");
  setprop("/controls/internal/value1", "1");
});