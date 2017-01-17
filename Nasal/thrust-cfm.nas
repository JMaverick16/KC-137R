# MD-88/MD-90 Thrust Logic System by Joshua Davidson (it0uchpods/411)

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/controls/engines/n1lim", 0.89);
	setprop("/controls/engines/n1limx100", 89);
	print("Thrust System ... OK!");
});