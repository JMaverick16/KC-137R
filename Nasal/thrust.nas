# KC-137R Thrust Logic System

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/controls/engines/n1lim", 0.951);
	setprop("/controls/engines/n1limx100", 95.1);
	setprop("/controls/engines/n1overlim", 97.3);
	print("Thrust System ... OK!");
});