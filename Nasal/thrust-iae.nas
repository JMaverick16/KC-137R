# KC-137R EPR Thrust Logic System by Joshua Davidson (it0uchpods/411)

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/controls/engines/eprlim", 1.28);
	setprop("/controls/engines/eprlimx100", 128);
	setprop("/controls/engines/eproverlim", 1.30);
	print("Thrust System ... OK!");
});