# KC-137R EPR Thrust Logic System by Joshua Davidson (it0uchpods/411)

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/controls/engines/eprlim", 1.29);
	setprop("/controls/engines/eprlimx100", 129);
	setprop("/controls/engines/eproverlim", 1.31);
	print("Thrust System ... OK!");
});