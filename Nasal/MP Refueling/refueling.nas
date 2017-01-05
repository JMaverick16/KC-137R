io.include("Aircraft/KC-137R/Nasal/MP Refueling/init.nas");

with("refueling_boom");

check_version("refueling_boom", 8, 2);

var callback_pose = func {
    var heading_deg = getprop("/engines/engine[9]/n1") or 0.0;
    var pitch_deg   = getprop("/engines/engine[9]/n2") or 0.0;
    var distance    = getprop("/engines/engine[9]/rpm") or 0.0;
    return [heading_deg, pitch_deg, distance];
};

# Update receiver tracking state of the refueling boom
var tracking_updater = refueling_boom.RefuelingBoomTrackingUpdater.new(callback_pose);

# Update the actual state of the refueling boom
var boom_position_updater = refueling_boom.RefuelingBoomPositionUpdater.new(tracking_updater);
tracking_updater.set_chooser(boom_position_updater);

var ready_node = props.globals.getNode("/b707/refuelling/ready");
var contact_node = props.globals.getNode("/b707/refuelling/contact");

# Enable the "READY" light if the boom is able to track a nearby aircraft
# Enable the "CONTACT" light if the boom is actually tracking a nearby aircraft
var lights_timer = maketimer(0, func {
    ready_node.setBoolValue(boom_position_updater.is_enabled());
    contact_node.setBoolValue(tracking_updater.is_enabled());
});
lights_timer.start();