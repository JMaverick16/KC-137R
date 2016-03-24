#######################################################################################
#		Lake of Constance Hangar :: M.Kraus
#		Boeing 707 for Flightgear February 2014
#		This file is licenced under the terms of the GNU General Public Licence V2 or later
#######################################################################################

setlistener("sim/current-view/view-number", func (n){
  var n = n.getValue() or 0;
  if (n == 0){
    setprop("sim/current-view/view-number",8);
  }
},0,1);
