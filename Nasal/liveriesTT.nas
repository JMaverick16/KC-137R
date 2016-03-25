aircraft.livery.init("Aircraft/KC-137R/Models/Liveries");

# Not the best place but liveries are independent to the aircraft

var isEC = func {
    var mpOther = props.globals.getNode("/ai/models").getChildren("multiplayer");
    var otherNr = size(mpOther);
		var am = getprop("/tanker") or 0;

    # find EC-137D
    for(var v = 0; v < otherNr; v += 1) {

       if (mpOther[v].getNode("sim/model/path").getValue() == "Aircraft/KC-137R/Models/EC-137D.xml" and
           mpOther[v].getNode("id").getValue() >= 0 and mpOther[v].getNode("radar/range-nm").getValue() < 0.3 ) {

			if (mpOther[v].getNode("sim/multiplay/generic/int[12]").getValue() != nil){
				if(mpOther[v].getNode("sim/multiplay/generic/int[12]").getValue() == 1){
					setprop("/b707/refuelling/contact",1);
					break;
				}elsif(mpOther[v].getNode("sim/multiplay/generic/int[12]").getValue() == 2){
					setprop("/b707/refuelling/ready",1);
					break;
				}else{
					setprop("/b707/refuelling/contact",0);
					setprop("/b707/refuelling/ready",0);
				}
			}else{
				setprop("/b707/refuelling/contact",0);
				setprop("/b707/refuelling/ready",0);
			}
		}else{
			setprop("/b707/refuelling/contact",0);
			setprop("/b707/refuelling/ready",0);
		}
    }
	if(am) settimer( isEC, 0.4);
}

setlistener( "/tanker", func{ 
	isEC();
});


