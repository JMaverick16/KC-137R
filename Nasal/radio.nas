# KC-137R Radio Controller by Joshua Davidson (Octal450/411)
	
setprop("/controls/radio/number/zero", "0");
setprop("/controls/radio/number/one", "1");
setprop("/controls/radio/number/two", "2");
setprop("/controls/radio/number/three", "3");
print("RADIO ... OK!");

var comm1_switch = func {
	var freqa = getprop("/instrumentation/comm/frequencies/selected-mhz");
	var freqs = getprop("/instrumentation/comm/frequencies/standby-mhz");
	setprop("/instrumentation/comm/frequencies/selected-mhz", freqs);
	setprop("/instrumentation/comm/frequencies/standby-mhz", freqa);
}

var comm2_switch = func {
	var freqa = getprop("/instrumentation/comm[1]/frequencies/selected-mhz");
	var freqs = getprop("/instrumentation/comm[1]/frequencies/standby-mhz");
	setprop("/instrumentation/comm[1]/frequencies/selected-mhz", freqs);
	setprop("/instrumentation/comm[1]/frequencies/standby-mhz", freqa);
}

var nav1_switch = func {
	var freqa = getprop("/instrumentation/nav/frequencies/selected-mhz");
	var freqs = getprop("/instrumentation/nav/frequencies/standby-mhz");
	setprop("/instrumentation/nav/frequencies/selected-mhz", freqs);
	setprop("/instrumentation/nav/frequencies/standby-mhz", freqa);
}

var nav2_switch = func {
	var freqa = getprop("/instrumentation/nav[1]/frequencies/selected-mhz");
	var freqs = getprop("/instrumentation/nav[1]/frequencies/standby-mhz");
	setprop("/instrumentation/nav[1]/frequencies/selected-mhz", freqs);
	setprop("/instrumentation/nav[1]/frequencies/standby-mhz", freqa);
}