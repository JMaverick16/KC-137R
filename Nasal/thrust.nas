# KC-137R Thrust Logic System

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/controls/engines/n1lim", 0.971);
	setprop("/controls/engines/n1limx100", 97.1);
	setprop("/controls/engines/n1overlim", 99.3);
	print("Thrust System ... OK!");
});