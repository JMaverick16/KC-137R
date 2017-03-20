# KC-137R N1 Thrust Logic System by Joshua Davidson (it0uchpods/411)

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/controls/engines/n1lim", 0.971);
	setprop("/controls/engines/n1limx100", 97.1);
	setprop("/controls/engines/n1overlim", 97.5);
	print("Thrust System ... OK!");
});