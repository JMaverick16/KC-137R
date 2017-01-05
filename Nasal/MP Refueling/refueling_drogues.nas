io.include("Aircraft/KC-137R/Nasal/MP Refueling/init.nas");

with("refueling_drogues");

check_version("refueling_drogues", 2, 0);

var callback_pose_right = func {
    var heading_deg = getprop("/engines/engine[8]/n1") or 0.0;
    var pitch_deg   = getprop("/engines/engine[8]/n2") or 0.0;
    var distance    = getprop("/engines/engine[8]/rpm") or 0.0;
    return [heading_deg, pitch_deg, distance];
};

var callback_pose_left = func {
    var heading_deg = getprop("/engines/engine[6]/n1") or 0.0;
    var pitch_deg   = getprop("/engines/engine[6]/n2") or 0.0;
    var distance    = getprop("/engines/engine[6]/rpm") or 0.0;
    return [heading_deg, pitch_deg, distance];
};

# Update the tracking state of the drogues
var tracking_updater_right = refueling_drogues.DrogueTrackingUpdater.new(callback_pose_right, 0);
var tracking_updater_left = refueling_drogues.DrogueTrackingUpdater.new(callback_pose_left, 1);

# Update the decision state (who is receiving fuel) of the drogues
var decision_updater_right = refueling_drogues.ReceiverDecisionUpdater.new(tracking_updater_right, 0);
var decision_updater_left  = refueling_drogues.ReceiverDecisionUpdater.new(tracking_updater_left, 1);

tracking_updater_right.set_chooser(decision_updater_right);
tracking_updater_left.set_chooser(decision_updater_left);

setlistener("/sim/signals/fdm-initialized", func {
    setlistener("/refueling/drogues/drogue[0]/enabled", func (node) {
        decision_updater_right.enable_or_disable(node.getBoolValue());
    }, 1, 0);
    setlistener("/refueling/drogues/drogue[1]/enabled", func (node) {
        decision_updater_left.enable_or_disable(node.getBoolValue());
    }, 1, 0);
});