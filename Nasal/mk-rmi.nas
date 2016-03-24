# RMI Driver
# Nasal code to calculate RMI needle deflections based on mode (VOR/ADF)
# and beacon range. Simplifies RMI animations.
#
# Reads two custom properties:
#   /instrumentation/rmi/rmi-needle[0]/switch		(values 'vor'|'adf', default 'vor')
#   /instrumentation/rmi/rmi-needle[1]/switch		(values 'vor'|'adf', default 'vor')
#
# These should be set by cockpit switches to control the two RMI needles.
#
# Function writes to two custom properties:
#  /instrumentation/rmi/rmi-needle[0]/value
#  /instrumentation/rmi/rmi-needle[1]/value
#
# These are read by the RMI instrument animations.
#
#
# Wolfram Gottfried aka 'Yakko'
# Gary Neely aka 'Buckaroo'
# with little changes by Lake of Constance Hangar :: M.Kraus
# Avril 2013
# This file is licenced under the terms of the GNU General Public Licence V2 or later


var updateRMI = func {

# Needle default 'off' or out-of-range positions:

  var needle1 = 90;
  var needle2 = 90;


# If RMI 1 set to ADF (mode 1):

  if (getprop("/instrumentation/rmi/rmi-needle[0]/switch")) {
    if (getprop("/instrumentation/adf[0]/in-range")) {
      needle1 = getprop("/instrumentation/adf[0]/indicated-bearing-deg");
    }
  }

# RMI 1 set to VOR (mode 0):

  else {
    if (getprop("/instrumentation/nav[0]/in-range")) {
      # Needle actual = needle bearing
      needle1 = indiBearingDeg(getprop("/instrumentation/nav[0]/heading-deg"),getprop("/orientation/heading-magnetic-deg")); 
    }
  }

# If RMI 2 set to ADF (mode 1):

  if (getprop("/instrumentation/rmi/rmi-needle[1]/switch")) {
    if (getprop("/instrumentation/adf[1]/in-range")) {
      needle2 = getprop("/instrumentation/adf[1]/indicated-bearing-deg");
    }
  }

# RMI 2 set to VOR (mode 0):

  else {
    if (getprop("/instrumentation/nav[1]/in-range")) {
      # Needle actual = needle bearing
      needle2 = indiBearingDeg(getprop("/instrumentation/nav[1]/heading-deg"),getprop("/orientation/heading-magnetic-deg")); 
    }
  }
  
  if(needle1 > 360) needle1 = needle1 - 360;
  if(needle2 > 360) needle2 = needle2 - 360;
  
  #screen.log.write("needle1 " ~needle1, 1.0, 0.1, 0.1);  
  #screen.log.write("needle2 " ~needle2, 1.0, 0.1, 0.1);
  
# Save Needle settings
  interpolate("/instrumentation/rmi/rmi-needle[0]/value", needle1, 1);
  interpolate("/instrumentation/rmi/rmi-needle[1]/value", needle2, 1);

# RMI updated 1 times / sec

  settimer(updateRMI, 1);
}


var adf_false_tick = func {
  setprop("/instrumentation/adf[0]/in-range", 0);
  setprop("/instrumentation/adf[1]/in-range", 0);
  settimer(adf_false_tick, 6);
}

updateRMI();
adf_false_tick();


############### Show the course correction deg ###################################
var rotation_degree = "/instrumentation/rmi/face-offset";

var mymod = func(x,y){
  var res = x/y;
  var resInt = int(res);
  var resSmall = y * resInt;
  return x - resSmall;
}

var indiBearingDeg = func(a,b){
  var diff = b-a;
  var newAngle = 0.0;
  if(diff > 180)
  {
      newAngle = mymod((diff + 180),360) - 180;
  }
  elsif(diff < -180)
  {
      newAngle = mymod((diff - 180),360) + 180;
  }
  else
  {
      newAngle = mymod(diff, 360);
  }
  return (360 - newAngle);
};

var rmiNavInfo = func (needle_nr) {
    var i = needle_nr - 1;
    #var rdfDeg = getprop(rotation_degree)*360;
    var rdfDeg = getprop(rotation_degree);
    
    var freqSel = getprop("/instrumentation/rmi/rmi-needle["~i~"]/switch"); # 1 = NDB, 0 = VOR or ILS
    var selected_freq = getprop("/instrumentation/nav["~i~"]/frequencies/selected-mhz") or 0;
    var text2 = "";
    if(freqSel == 1){
      var controlRange = getprop("/instrumentation/adf["~i~"]/in-range");
      var text = getprop("/instrumentation/adf["~i~"]/ident");
      if(text == "") text = "ADF "~needle_nr;
    }else{ 
      var controlRange = getprop("/instrumentation/nav["~i~"]/in-range");
      var text = getprop("/instrumentation/nav["~i~"]/nav-id");
      var dmeInRange = getprop("/instrumentation/dme["~i~"]/in-range");
      if(dmeInRange == 1){
        var dmeDistance = int(getprop("/instrumentation/dme["~i~"]/indicated-distance-nm"));
        text2 = "Distance "~dmeDistance~"nm";
      }
    }

    # there is a signal in range
    if (controlRange) {
    
			var newRdfDeg = rdfDeg;
			if (rdfDeg > 180){
				newRdfDeg = abs(360 - rdfDeg);
			}
			headCorrection = int(newRdfDeg);
			
			
			# is the face turn to range between 5 degree + or - of the needle heading?
			var needleDeg = getprop("/instrumentation/rmi/rmi-needle["~i~"]/value") or 0;
			if(needleDeg > 180){
				needleDeg = abs(360 - needleDeg);
			}else{
				needleDeg = needleDeg;
			}
			
			var diff_needle = abs(headCorrection - needleDeg);
			
      # build the heading correction message for the pilot
      mp_msg = "";

			if (diff_needle < 5){
		    if (rdfDeg > 180.5 and rdfDeg < 359.5){
		      mp_msg = text~" -> "~headCorrection~" degree to starboard";
		    }elsif(rdfDeg > 0.5 and rdfDeg < 179.5){
		      mp_msg = text~" -> "~headCorrection~" degree to port";
		    }elsif(rdfDeg >= 179.5 and rdfDeg <= 180.5){
		      mp_msg = text~" on 180 degree";
		    }elsif(rdfDeg >= 359.5 or rdfDeg <= 0.5){
		      mp_msg = text~" is straight ahead.";
		    }
		    
		    if(text2 != ""){
		      mp_msg = mp_msg~ ". " ~text2;
		    }
		    
		  }else{
        mp_msg = "Set first the rmi compass rose to the needle direction for calculation.";
		  }

    }else{
        mp_msg = "Nonviable calculation.";
    }
    
    help_win.write("Needle " ~needle_nr~" calculation: " ~mp_msg); #help_win is set in the mk-707.nas

}

#
# Round-off errors screw-up the textranslate animation used to display digits. This is a problem
# for the NAV and COMM freq display. This seems to affect only decimal place digits. So here I'm using
# a listener to copy the MHz and KHz portions of a freq string to a separate integer values
# that are used by the animations.
#
var nav1sel	= props.globals.getNode("/instrumentation/nav[0]/frequencies/selected-mhz");
var nav1sby	= props.globals.getNode("/instrumentation/nav[0]/frequencies/standby-mhz");
var nav1selstr	= props.globals.getNode("/instrumentation/nav[0]/frequencies/selected-mhz-fmt");
var nav1sbystr	= props.globals.getNode("/instrumentation/nav[0]/frequencies/standby-mhz-fmt");
var nav1selmhz= props.globals.getNode("/instrumentation/nav[0]/frequencies/display-sel-mhz");
var nav1selkhz= props.globals.getNode("/instrumentation/nav[0]/frequencies/display-sel-khz");
var nav1sbymhz= props.globals.getNode("/instrumentation/nav[0]/frequencies/display-sby-mhz");
var nav1sbykhz= props.globals.getNode("/instrumentation/nav[0]/frequencies/display-sby-khz");

var nav2sel	= props.globals.getNode("/instrumentation/nav[1]/frequencies/selected-mhz");
var nav2sby	= props.globals.getNode("/instrumentation/nav[1]/frequencies/standby-mhz");
var nav2selstr	= props.globals.getNode("/instrumentation/nav[1]/frequencies/selected-mhz-fmt");
var nav2sbystr	= props.globals.getNode("/instrumentation/nav[1]/frequencies/standby-mhz-fmt");
var nav2selmhz= props.globals.getNode("/instrumentation/nav[1]/frequencies/display-sel-mhz");
var nav2selkhz= props.globals.getNode("/instrumentation/nav[1]/frequencies/display-sel-khz");
var nav2sbymhz= props.globals.getNode("/instrumentation/nav[1]/frequencies/display-sby-mhz");
var nav2sbykhz= props.globals.getNode("/instrumentation/nav[1]/frequencies/display-sby-khz");

							# Update support vars on nav change
setlistener(nav1sel, func {
  var navstr = sprintf("%.2f",nav1sel.getValue());	# String conversion
  var navtemp = split(".",navstr);			# Split into MHz and KHz
  nav1selmhz.setValue(navtemp[0]);
  nav1selkhz.setValue(navtemp[1]);
});
setlistener(nav1sby, func {
  var navstr = sprintf("%.2f",nav1sby.getValue());
  var navtemp = split(".",navstr);
  nav1sbymhz.setValue(navtemp[0]);
  nav1sbykhz.setValue(navtemp[1]);
});
setlistener(nav2sel, func {
  var navstr = sprintf("%.2f",nav2sel.getValue());
  var navtemp = split(".",navstr);
  nav2selmhz.setValue(navtemp[0]);
  nav2selkhz.setValue(navtemp[1]);
});
setlistener(nav2sby, func {
  var navstr = sprintf("%.2f",nav2sby.getValue());
  var navtemp = split(".",navstr);
  nav2sbymhz.setValue(navtemp[0]);
  nav2sbykhz.setValue(navtemp[1]);
});


var comm1sel	= props.globals.getNode("/instrumentation/comm[0]/frequencies/selected-mhz");
var comm1sby	= props.globals.getNode("/instrumentation/comm[0]/frequencies/standby-mhz");
var comm1selstr	= props.globals.getNode("/instrumentation/comm[0]/frequencies/selected-mhz-fmt");
var comm1sbystr	= props.globals.getNode("/instrumentation/comm[0]/frequencies/standby-mhz-fmt");
var comm1selmhz= props.globals.getNode("/instrumentation/comm[0]/frequencies/display-sel-mhz");
var comm1selkhz= props.globals.getNode("/instrumentation/comm[0]/frequencies/display-sel-khz");
var comm1sbymhz= props.globals.getNode("/instrumentation/comm[0]/frequencies/display-sby-mhz");
var comm1sbykhz= props.globals.getNode("/instrumentation/comm[0]/frequencies/display-sby-khz");

var comm2sel	= props.globals.getNode("/instrumentation/comm[1]/frequencies/selected-mhz");
var comm2sby	= props.globals.getNode("/instrumentation/comm[1]/frequencies/standby-mhz");
var comm2selstr	= props.globals.getNode("/instrumentation/comm[1]/frequencies/selected-mhz-fmt");
var comm2sbystr	= props.globals.getNode("/instrumentation/comm[1]/frequencies/standby-mhz-fmt");
var comm2selmhz= props.globals.getNode("/instrumentation/comm[1]/frequencies/display-sel-mhz");
var comm2selkhz= props.globals.getNode("/instrumentation/comm[1]/frequencies/display-sel-khz");
var comm2sbymhz= props.globals.getNode("/instrumentation/comm[1]/frequencies/display-sby-mhz");
var comm2sbykhz= props.globals.getNode("/instrumentation/comm[1]/frequencies/display-sby-khz");

							# Update support vars on comm change
setlistener(comm1sel, func {
  var commstr = sprintf("%.2f",comm1sel.getValue());	# String conversion
  var commtemp = split(".",commstr);			# Split into MHz and KHz
  comm1selmhz.setValue(commtemp[0]);
  comm1selkhz.setValue(commtemp[1]);
});
setlistener(comm1sby, func {
  var commstr = sprintf("%.2f",comm1sby.getValue());
  var commtemp = split(".",commstr);
  comm1sbymhz.setValue(commtemp[0]);
  comm1sbykhz.setValue(commtemp[1]);
});
setlistener(comm2sel, func {
  var commstr = sprintf("%.2f",comm2sel.getValue());
  var commtemp = split(".",commstr);
  comm2selmhz.setValue(commtemp[0]);
  comm2selkhz.setValue(commtemp[1]);
});
setlistener(comm2sby, func {
  var commstr = sprintf("%.2f",comm2sby.getValue());
  var commtemp = split(".",commstr);
  comm2sbymhz.setValue(commtemp[0]);
  comm2sbykhz.setValue(commtemp[1]);
});

							# Set comm support vars to startups
var update_comms_navs = func {
  var commstr = "";
  var commtemp = 0;
  var navstr = "";
  var navtemp = 0;

  commstr = sprintf("%.2f",comm1sel.getValue());
  commtemp = split(".",commstr);
  comm1selmhz.setValue(commtemp[0]);
  comm1selkhz.setValue(commtemp[1]);
  commstr = sprintf("%.2f",comm1sby.getValue());
  commtemp = split(".",commstr);
  comm1sbymhz.setValue(commtemp[0]);
  comm1sbykhz.setValue(commtemp[1]);

  commstr = sprintf("%.2f",comm2sel.getValue());
  commtemp = split(".",commstr);
  comm2selmhz.setValue(commtemp[0]);
  comm2selkhz.setValue(commtemp[1]);
  commstr = sprintf("%.2f",comm2sby.getValue());
  commtemp = split(".",commstr);
  comm2sbymhz.setValue(commtemp[0]);
  comm2sbykhz.setValue(commtemp[1]);
  
  navstr = sprintf("%.2f",nav1sel.getValue());
  navtemp = split(".",navstr);
  nav1selmhz.setValue(navtemp[0]);
  nav1selkhz.setValue(navtemp[1]);
  navstr = sprintf("%.2f",nav1sby.getValue());
  navtemp = split(".",navstr);
  nav1sbymhz.setValue(navtemp[0]);
  nav1sbykhz.setValue(navtemp[1]);

  navstr = sprintf("%.2f",nav2sel.getValue());
  navtemp = split(".",navstr);
  nav2selmhz.setValue(navtemp[0]);
  nav2selkhz.setValue(navtemp[1]);
  navstr = sprintf("%.2f",nav2sby.getValue());
  navtemp = split(".",navstr);
  nav2sbymhz.setValue(navtemp[0]);
  nav2sbykhz.setValue(navtemp[1]);

  settimer(update_comms_navs, 2);
}

update_comms_navs();
