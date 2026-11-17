# KC-137R EAD
# Cut down version of IS DU system
# Copyright (c) 2026 Josh Davidson (Octal450)

var display = nil;
var ead = nil;

var Prop = {
	activeLimInt: props.globals.getNode("/fdm/jsbsim/fadec/limit/active-int"),
	egt: [props.globals.getNode("/engines/engine[0]/egt-actual"), props.globals.getNode("/engines/engine[1]/egt-actual"), props.globals.getNode("/engines/engine[2]/egt-actual"), props.globals.getNode("/engines/engine[3]/egt-actual")],
	ff: [props.globals.getNode("/engines/engine[0]/ff-actual"), props.globals.getNode("/engines/engine[1]/ff-actual"), props.globals.getNode("/engines/engine[2]/ff-actual"), props.globals.getNode("/engines/engine[3]/ff-actual")],
	flapDeg: props.globals.getNode("/fdm/jsbsim/fcs/flap-pos-deg"),
	gAccel: props.globals.getNode("/accelerations/pilot-gdamped"),
	gMax: props.globals.getNode("/instrumentation/gmeter/max"),
	gMin: props.globals.getNode("/instrumentation/gmeter/min"),
	oilPsi: [props.globals.getNode("/engines/engine[0]/oil-psi"), props.globals.getNode("/engines/engine[1]/oil-psi"), props.globals.getNode("/engines/engine[2]/oil-psi"), props.globals.getNode("/engines/engine[3]/oil-psi")],
	oilTemp: [props.globals.getNode("/engines/engine[0]/oil-temp"), props.globals.getNode("/engines/engine[1]/oil-temp"), props.globals.getNode("/engines/engine[2]/oil-temp"), props.globals.getNode("/engines/engine[3]/oil-temp")],
	n1: [props.globals.getNode("/engines/engine[0]/n1-actual"), props.globals.getNode("/engines/engine[1]/n1-actual"), props.globals.getNode("/engines/engine[2]/n1-actual"), props.globals.getNode("/engines/engine[3]/n1-actual")],
	n1Lim: props.globals.getNode("/fdm/jsbsim/fadec/limit/active"),
	n2: [props.globals.getNode("/engines/engine[0]/n2-actual"), props.globals.getNode("/engines/engine[1]/n2-actual"), props.globals.getNode("/engines/engine[2]/n2-actual"), props.globals.getNode("/engines/engine[3]/n2-actual")],
	rev: [props.globals.getNode("/engines/engine[0]/reverser-pos-norm"), props.globals.getNode("/engines/engine[1]/reverser-pos-norm"), props.globals.getNode("/engines/engine[2]/reverser-pos-norm"), props.globals.getNode("/engines/engine[3]/reverser-pos-norm")],
};

var Value = {
	activeLimInt: 0,
	egt: [0, 0, 0, 0],
	ff: [0, 0, 0, 0],
	flapDeg: 0,
	n1: [0, 0, 0, 0],
	n1Lim: 0,
	n2: [0, 0, 0, 0],
	rev: [0, 0, 0, 0],
};

var CanvasBase = {
	init: func(canvasGroup, file) {
		var font_mapper = func(family, weight) {
			return "LiberationSansDU.ttf";
		};
		
		canvas.parsesvg(canvasGroup, file, {"font-mapper": font_mapper});
		
		var svgKeys = me.getKeys();
		foreach(var key; svgKeys) {
			me[key] = canvasGroup.getElementById(key);
			
			var clip_el = canvasGroup.getElementById(key ~ "_clip");
			if (clip_el != nil) {
				clip_el.setVisible(0);
				var tranRect = clip_el.getTransformedBounds();
				
				var clip_rect = sprintf("rect(%d, %d, %d, %d)",
					tranRect[1], # 0 ys
					tranRect[2], # 1 xe
					tranRect[3], # 2 ye
					tranRect[0] # 3 xs
				);
				
				# Coordinates are top, right, bottom, left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
				me[key].set("clip", clip_rect);
				me[key].set("clip-frame", canvas.Element.PARENT);
			}
		}
		
		me.page = canvasGroup;
		return me;
	},
	getKeys: func() {
		return KeyList;
	},
	update: func() {
		ead.update();
	},
};

var CanvasEad = {
	new: func(canvasGroup, file) {
		var m = {parents: [CanvasEad, CanvasBase]};
		m.init(canvasGroup, file);
		
		return m;
	},
	update: func() {
		Value.activeLimInt = Prop.activeLimInt.getValue();
		Value.n1Lim = Prop.n1Lim.getValue();
		
		if (Value.activeLimInt == 0) {
			me["LimMode"].setText("T/O");
		} else if (Value.activeLimInt == 1) {
			me["LimMode"].setText("MCT");
		} else if (Value.activeLimInt == 2) {
			me["LimMode"].setText("CLB");
		} else {
			me["LimMode"].setText("---");
		}
		
		me["N11_lim"].setText(sprintf("%5.1f", math.round(Value.n1Lim, 0.1)));
		me["N11_lim_needle"].setRotation(math.clamp((Value.n1Lim / 110) * 230, 0, 230) * D2R);
		me["N12_lim"].setText(sprintf("%5.1f", math.round(Value.n1Lim, 0.1)));
		me["N12_lim_needle"].setRotation(math.clamp((Value.n1Lim / 110) * 230, 0, 230) * D2R);
		me["N13_lim"].setText(sprintf("%5.1f", math.round(Value.n1Lim, 0.1)));
		me["N13_lim_needle"].setRotation(math.clamp((Value.n1Lim / 110) * 230, 0, 230) * D2R);
		me["N14_lim"].setText(sprintf("%5.1f", math.round(Value.n1Lim, 0.1)));
		me["N14_lim_needle"].setRotation(math.clamp((Value.n1Lim / 110) * 230, 0, 230) * D2R);
		
		Value.rev[0] = Prop.rev[0].getValue();
		Value.rev[1] = Prop.rev[1].getValue();
		Value.rev[2] = Prop.rev[2].getValue();
		Value.rev[3] = Prop.rev[3].getValue();
		
		if (Value.rev[0] <= 0.05) {
			me["REV1"].hide();
		} else {
			if (Value.rev[0] >= 0.95) {
				me["REV1"].setText("REV");
				me["REV1"].setColor(0, 1, 0);
			} else {
				me["REV1"].setText("U/L");
				me["REV1"].setColor(1, 0.8275, 0.1647);
			}
			me["REV1"].show();
		}
		if (Value.rev[1] <= 0.05) {
			me["REV2"].hide();
		} else {
			if (Value.rev[1] >= 0.95) {
				me["REV2"].setText("REV");
				me["REV2"].setColor(0, 1, 0);
			} else {
				me["REV2"].setText("U/L");
				me["REV2"].setColor(1, 0.8275, 0.1647);
			}
			me["REV2"].show();
		}
		if (Value.rev[2] <= 0.05) {
			me["REV3"].hide();
		} else {
			if (Value.rev[2] >= 0.95) {
				me["REV3"].setText("REV");
				me["REV3"].setColor(0, 1, 0);
			} else {
				me["REV3"].setText("U/L");
				me["REV3"].setColor(1, 0.8275, 0.1647);
			}
			me["REV3"].show();
		}
		if (Value.rev[3] <= 0.05) {
			me["REV4"].hide();
		} else {
			if (Value.rev[3] >= 0.95) {
				me["REV4"].setText("REV");
				me["REV4"].setColor(0, 1, 0);
			} else {
				me["REV4"].setText("U/L");
				me["REV4"].setColor(1, 0.8275, 0.1647);
			}
			me["REV4"].show();
		}
		
		Value.n1[0] = Prop.n1[0].getValue();
		Value.n1[1] = Prop.n1[1].getValue();
		Value.n1[2] = Prop.n1[2].getValue();
		Value.n1[3] = Prop.n1[3].getValue();
		
		me["N11"].setText(sprintf("%5.1f", math.round(Value.n1[0], 0.1)));
		me["N11_needle"].setRotation(math.clamp((Value.n1[0] / 110) * 230, 0, 230) * D2R);
		me["N12"].setText(sprintf("%5.1f", math.round(Value.n1[1], 0.1)));
		me["N12_needle"].setRotation(math.clamp((Value.n1[1] / 110) * 230, 0, 230) * D2R);
		me["N13"].setText(sprintf("%5.1f", math.round(Value.n1[2], 0.1)));
		me["N13_needle"].setRotation(math.clamp((Value.n1[2] / 110) * 230, 0, 230) * D2R);
		me["N14"].setText(sprintf("%5.1f", math.round(Value.n1[3], 0.1)));
		me["N14_needle"].setRotation(math.clamp((Value.n1[3] / 110) * 230, 0, 230) * D2R);
		
		if (abs(Value.n1[0] - Value.n1Lim) <= 0.5) {
			me["N11"].setColor(0, 1, 0);
			me["N11_box"].setColor(0, 1, 0);
		} else {
			me["N11"].setColor(1, 1, 1);
			me["N11_box"].setColor(1, 1, 1);
		}
		if (abs(Value.n1[1] - Value.n1Lim) <= 0.5) {
			me["N12"].setColor(0, 1, 0);
			me["N12_box"].setColor(0, 1, 0);
		} else {
			me["N12"].setColor(1, 1, 1);
			me["N12_box"].setColor(1, 1, 1);
		}
		if (abs(Value.n1[2] - Value.n1Lim) <= 0.5) {
			me["N13"].setColor(0, 1, 0);
			me["N13_box"].setColor(0, 1, 0);
		} else {
			me["N13"].setColor(1, 1, 1);
			me["N13_box"].setColor(1, 1, 1);
		}
		if (abs(Value.n1[3] - Value.n1Lim) <= 0.5) {
			me["N14"].setColor(0, 1, 0);
			me["N14_box"].setColor(0, 1, 0);
		} else {
			me["N14"].setColor(1, 1, 1);
			me["N14_box"].setColor(1, 1, 1);
		}
		
		Value.egt[0] = Prop.egt[0].getValue();
		Value.egt[1] = Prop.egt[1].getValue();
		Value.egt[2] = Prop.egt[2].getValue();
		Value.egt[3] = Prop.egt[3].getValue();
		
		me["EGT1"].setText(sprintf("%d", math.round(Value.egt[0])));
		me["EGT1_needle"].setRotation(math.clamp((Value.egt[0] / 1100) * 270, 0, 270) * D2R);
		me["EGT2"].setText(sprintf("%d", math.round(Value.egt[1])));
		me["EGT2_needle"].setRotation(math.clamp((Value.egt[1] / 1100) * 270, 0, 270) * D2R);
		me["EGT3"].setText(sprintf("%d", math.round(Value.egt[2])));
		me["EGT3_needle"].setRotation(math.clamp((Value.egt[2] / 1100) * 270, 0, 270) * D2R);
		me["EGT4"].setText(sprintf("%d", math.round(Value.egt[3])));
		me["EGT4_needle"].setRotation(math.clamp((Value.egt[3] / 1100) * 270, 0, 270) * D2R);
		
		Value.n2[0] = Prop.n2[0].getValue();
		Value.n2[1] = Prop.n2[1].getValue();
		Value.n2[2] = Prop.n2[2].getValue();
		Value.n2[3] = Prop.n2[3].getValue();
		
		me["N21"].setText(sprintf("%5.1f", math.round(Value.n2[0], 0.1)));
		me["N21_needle"].setRotation(math.clamp((Value.n2[0] / 110) * 230, 0, 230) * D2R);
		me["N22"].setText(sprintf("%5.1f", math.round(Value.n2[1], 0.1)));
		me["N22_needle"].setRotation(math.clamp((Value.n2[1] / 110) * 230, 0, 230) * D2R);
		me["N23"].setText(sprintf("%5.1f", math.round(Value.n2[2], 0.1)));
		me["N23_needle"].setRotation(math.clamp((Value.n2[2] / 110) * 230, 0, 230) * D2R);
		me["N24"].setText(sprintf("%5.1f", math.round(Value.n2[3], 0.1)));
		me["N24_needle"].setRotation(math.clamp((Value.n2[3] / 110) * 230, 0, 230) * D2R);
		
		Value.ff[0] = Prop.ff[0].getValue();
		Value.ff[1] = Prop.ff[1].getValue();
		Value.ff[2] = Prop.ff[2].getValue();
		Value.ff[3] = Prop.ff[3].getValue();
		
		me["FF1"].setText(sprintf("%d", math.round(Value.ff[0], 50)));
		me["FF1_needle"].setRotation((math.min(Value.ff[0] / 4000, 1) * 180 + math.max(math.min((Value.ff[0] - 4000) / 11000, 1), 0) * 90) * D2R);
		me["FF2"].setText(sprintf("%d", math.round(Value.ff[1], 50)));
		me["FF2_needle"].setRotation((math.min(Value.ff[1] / 4000, 1) * 180 + math.max(math.min((Value.ff[1] - 4000) / 11000, 1), 0) * 90) * D2R);
		me["FF3"].setText(sprintf("%d", math.round(Value.ff[2], 50)));
		me["FF3_needle"].setRotation((math.min(Value.ff[2] / 4000, 1) * 180 + math.max(math.min((Value.ff[2] - 4000) / 11000, 1), 0) * 90) * D2R);
		me["FF4"].setText(sprintf("%d", math.round(Value.ff[3], 50)));
		me["FF4_needle"].setRotation((math.min(Value.ff[3] / 4000, 1) * 180 + math.max(math.min((Value.ff[3] - 4000) / 11000, 1), 0) * 90) * D2R);
		
		me["OilPsi1"].setText(sprintf("%d", math.round(Prop.oilPsi[0].getValue())) ~ "PSI");
		me["OilPsi2"].setText(sprintf("%d", math.round(Prop.oilPsi[1].getValue())) ~ "PSI");
		me["OilPsi3"].setText(sprintf("%d", math.round(Prop.oilPsi[2].getValue())) ~ "PSI");
		me["OilPsi4"].setText(sprintf("%d", math.round(Prop.oilPsi[3].getValue())) ~ "PSI");
		
		me["OilTemp1"].setText(sprintf("%d", math.round(Prop.oilTemp[0].getValue())) ~ "C");
		me["OilTemp2"].setText(sprintf("%d", math.round(Prop.oilTemp[1].getValue())) ~ "C");
		me["OilTemp3"].setText(sprintf("%d", math.round(Prop.oilTemp[2].getValue())) ~ "C");
		me["OilTemp4"].setText(sprintf("%d", math.round(Prop.oilTemp[3].getValue())) ~ "C");
		
		me["G_needle"].setTranslation(math.clamp((Prop.gAccel.getValue() - 1) * 50, -150, 150), 0);
		me["G_max"].setTranslation(math.clamp((Prop.gMax.getValue() - 1) * 50, -150, 150), 0);
		me["G_min"].setTranslation(math.clamp((Prop.gMin.getValue() - 1) * 50, -150, 150), 0);
		
		Value.flapDeg = Prop.flapDeg.getValue();
		me["Flap_bar"].setTranslation(0, (math.min(Value.flapDeg / 14, 1) * 50 + math.max(math.min((Value.flapDeg - 14) / 11, 1), 0) * 50 + math.max(math.min((Value.flapDeg - 25) / 15, 1), 0) * 50 + math.max(math.min((Value.flapDeg - 40) / 10, 1), 0) * 50));
	},
};

var setup = func() {
	display = canvas.new({
		"name": "ead",
		"size": [1024, 1348],
		"view": [1024, 1348],
		"mipmapping": 1
	});
	
	display.addPlacement({"node": "EAD.screen"});
	var eadGroup = display.createGroup();
	ead = CanvasEad.new(eadGroup, "Aircraft/KC-137R/Nasal/Displays/res/EAD.svg");
	update.start();
}

var update = maketimer(0.05, func() { # 20FPS
	CanvasBase.update();
});

# SVG Key List
var KeyList = [
	"EGT1",
	"EGT1_needle",
	"EGT2",
	"EGT2_needle",
	"EGT3",
	"EGT3_needle",
	"EGT4",
	"EGT4_needle",
	"FF1",
	"FF1_needle",
	"FF2",
	"FF2_needle",
	"FF3",
	"FF3_needle",
	"FF4",
	"FF4_needle",
	"Flap_bar",
	"G_max",
	"G_min",
	"G_needle",
	"LimMode",
	"N11",
	"N11_box",
	"N11_lim",
	"N11_lim_needle",
	"N11_needle",
	"N12",
	"N12_box",
	"N12_lim",
	"N12_lim_needle",
	"N12_needle",
	"N13",
	"N13_box",
	"N13_lim",
	"N13_lim_needle",
	"N13_needle",
	"N14",
	"N14_box",
	"N14_lim",
	"N14_lim_needle",
	"N14_needle",
	"N21",
	"N21_needle",
	"N22",
	"N22_needle",
	"N23",
	"N23_needle",
	"N24",
	"N24_needle",
	"OilPsi1",
	"OilPsi2",
	"OilPsi3",
	"OilPsi4",
	"OilTemp1",
	"OilTemp2",
	"OilTemp3",
	"OilTemp4",
	"REV1",
	"REV2",
	"REV3",
	"REV4"
];
