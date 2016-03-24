# Lake of Constance Hangar :: M.Kraus
# Avril 2013
# This file is licenced under the terms of the GNU General Public Licence V2 or later
# wiper action
setlistener("/controls/special/wiper-switch", func() {
  wiper_action();  
}, 0, 1);

var wiper_action = func(){

    var ws = getprop("/controls/special/wiper-switch") or 0;
    var d = getprop("/controls/special/wiper-deg") or 0;
    
 		if(ws){
 								
 		  if(ws == 4){
				if (d > 108){        
					interpolate("/controls/special/wiper-deg", 0, 2);  
				}
				if (d < 2){        
					interpolate("/controls/special/wiper-deg", 110,  2);  
				}
				
				settimer(wiper_action, 6);
			}
 		
 		  if(ws == 1){
				if (d > 108){        
					interpolate("/controls/special/wiper-deg", 0, 2);  
				}
				if (d < 2){        
					interpolate("/controls/special/wiper-deg", 110,  2);  
				}
				
				settimer(wiper_action, 2.5);
			}
			
 		  if(ws == 2){
				if (d > 108){        
					interpolate("/controls/special/wiper-deg", 0, 1);  
				}
				if (d < 2){        
					interpolate("/controls/special/wiper-deg", 110,  1);  
				}
				
				settimer(wiper_action, 1.1);
			}
					
 		  if(ws == 3){
				if (d > 108){        
					interpolate("/controls/special/wiper-deg", 0, 0.6);  
				}
				if (d < 2){        
					interpolate("/controls/special/wiper-deg", 110,  0.6);  
				}
				
				settimer(wiper_action, 0.7);
			}

			

		  
		}else{
			interpolate("/controls/special/wiper-deg", 0,  1);
		}   


};
