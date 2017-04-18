# KC-137R N1 Thrust Logic System by Joshua Davidson (it0uchpods/411)

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/controls/engines/n1lim", 0.944);
	setprop("/controls/engines/n1limx100", 94.4);
	setprop("/controls/engines/n1overlim", 96.5);
	print("Thrust System ... OK!");
});