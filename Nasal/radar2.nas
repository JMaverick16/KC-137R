print("RADAR ... OK!");
################################################################################
#
#                        m2005-5's RADAR SETTINGS
#
################################################################################

# Radar
# Fabien BARBIER (5H1N0B1) September 2015
# inspired by Alexis Bory (xiii)

#var UPDATE_PERIOD = 0.1; # update interval for engine init() functions

var ElapsedSec        = props.globals.getNode("sim/time/elapsed-sec");

var wcs_mode          = "rws" ; # FIXME should handled as properties choice, not harcoded.
var tmp_nearest_rng   = nil;
var tmp_nearest_u     = nil;
var nearest_rng       = 0;
var nearest_u         = nil;


#radar : check : InRange, inAzimuth, inElevation, NotBeyondHorizon, doppler, isNotBehindTerrain
#rwr   : check : InhisRange (radardist), inHisElevation, inHisAzimuth, NotBeyondHorizon, isNotBehindTerrain
#heat  : check : InRange, inAzimuth, inElevation, NotBeyondHorizon, heat_sensor, isNotBehindTerrain
#laser : check : InRange, inAzimuth, inElevation, NotBeyondHorizon, isNotBehindTerrain
#cam  : check : InRange, inAzimuth, inElevation, NotBeyondHorizon, isNotBehindTerrain
#transponder : check :   radar, transponderOn (not yet implemented)


        
        
        
#var Mp = props.globals.getNode("ai/models");

# radar class
var Radar = {
    new: func(NewRangeTab = nil,                            #array with all the different possible range
                    NewRangeIndex = nil,                         #range indexshould not be greater than NewRangeTab
                    NewTypeTarget = nil,                           #array of different kind of object that can be seen.
                    NewRadarType = nil,                           #Array that indicate wich type of detector we have "radar","laser",
                    NewshowAI=nil,                                  # Show or not AI. (It will be depreciated)
                    NewUnfocused_az_fld=nil,                  # Total angle of radar
                    Newfocused_az_fld=nil,                      # Total angle of focused radar
                    NewFieldAzimuthCenter=nil,             # 0-360.For rear radar. 0 is the default value.
                    NewVerticalAzimuth=nil,                   #0-180
                    NewhaveSweep = nil,                       # boolean 1 or 0. Has a Sweep or not 
                    NewHaveDoppler = nil,                     # boolean 1 or 0. Has a Doppler or not
                    newDopplerSpeedLimit = nil,             # value in kts. This the min speed a doppler radar can detect. the less it is, more your doppler radar is recent and precise
                    NewMyTimeLimit = nil,
                    NewJanitorTime=nil,                          #Time a target will disapear from the radar
                    NewAutoUpdate=nil,                         # boolean 1 or 0. When to 1, it runs the update function in the init loop.
                    NewElectricalPath=nil,                      # Path of the property that allow the radar to be feed by electricity
                    path=nil,                                           #General path of the radar. it where we should have multiple targets array, targets[0], targets[1] where the number is the number of detection means present on the aircraft
                    forcePath=nil,                                    #Force the full tree. That prevent to use targets[1] when targets[0] is existing already.
                    NewSourcePath=nil){                               #If we want to use a different source than AI
        var m = { parents : [Radar]};
        #Variable that can be passed in parameters
        m.rangeTab      = NewRangeTab==nil?[10, 20, 40, 60, 160]:NewRangeTab; # radar Ranges in nm
        m.rangeIndex    = NewRangeIndex==nil?0:math.mod(NewRangeIndex, size(m.rangeTab)); # tab starts at index 1 so here it's 20
        m.HaveDoppler       = NewHaveDoppler == nil?1:NewHaveDoppler;
        m.DopplerSpeedLimit = newDopplerSpeedLimit == nil ? 50:newDopplerSpeedLimit; # in Knot
        
        m.MyTimeLimit       = NewMyTimeLimit==nil?2:NewMyTimeLimit; # in seconds
         m.janitorTime = NewJanitorTime==nil?5:NewJanitorTime;
         m.haveSweep         = NewhaveSweep==nil?1:NewhaveSweep;
         m.typeTarget = NewTypeTarget == nil?["multiplayer","tanker","aircraft","carrier","ship","missile"]:NewTypeTarget;
         m.showAI =NewshowAI==nil?1:NewshowAI;
         m.radarHeading  = 0;                       # in this we fix the radar position in the nose. We will change it to make rear radar or RWR etc
         m.unfocused_az_fld=NewUnfocused_az_fld == nil ?120:NewUnfocused_az_fld;
         m.focused_az_fld=Newfocused_az_fld == nil ?60:Newfocused_az_fld;
         m.vt_az_fld = NewVerticalAzimuth == nil ?120:NewVerticalAzimuth;
         m.fieldazCenter = NewFieldAzimuthCenter==nil?0:NewFieldAzimuthCenter;
         m.AutoUpdate = NewAutoUpdate==nil?1:NewAutoUpdate;
         m.ElectricalPath = NewElectricalPath==nil?"/systems/electrical/outputs/radar":NewElectricalPath;
         m.detectionTypetab = NewRadarType==nil?"radar":NewRadarType;  #old : m.detectionTypetab = ["radar","laser"];
         m.source = NewSourcePath==nil?"ai/models":NewSourcePath;
         me.Mp = props.globals.getNode(m.source);
         
         #m.detectionTypeIndex = 0;
         
        
        #Variables that need to be initialised
        m.loop_running  = 0;
       
        m.MyCoord       = geo.aircraft_position(); # this is when the radar is on our own aircraft. This part have to change if we want to put the radar on a missile/AI
        
        m.az_fld        = m.unfocused_az_fld;
        #m.vt_az_fld     = m.az_fld;
        
        # for Target Selection
        m.tgts_list         = [];
        m.Target_Index      = 0 ; # for Target Selection
        
        #Source behavior
        m.OurHdg        = 0;
        m.OurPitch      =  0;
        m.our_alt       =  0;
        
        m.Check_List  = [];
        
        
        
        
        # sweep : if have no sweep, we do not have to call internal very specific properties (This is one of the last part to tune)

          m.SwpMarker         = 0;
          m.sweep_frequency = 0;
          m.SwpDisplayWidth = 0;
          m.PpiDisplayRadius  =0;
          m.swp_diplay_width = 0;
          m.rng_diplay_width = 0;
          m.ppi_diplay_radius = 0;
          
       if(m.haveSweep ==1){
          m.sweepProperty   = "instrumentation/radar2/sweep-marker-norm";
          m.sweep_frequency   = m.MyTimeLimit / 4; # in seconds
          m.SwpDisplayWidth   = props.globals.getNode("instrumentation/radar2/sweep-width-m");
          m.PpiDisplayRadius  = props.globals.getNode("instrumentation/radar2/radius-ppi-display-m");
          m.swp_diplay_width = m.SwpDisplayWidth.getValue();# length of the max azimuth  range on the screen.
          m.rng_diplay_width = m.SwpDisplayWidth.getValue();# length of the max range vertical width on the
          m.ppi_diplay_radius = m.PpiDisplayRadius.getValue(); # length of the radial size
        }
        

          #Separate each "targets" Properties in case of multidetection systems
          m.tree = path==nil?"instrumentation/radar2/":path;
          var n = props.globals.getNode(m.tree, 1);
          for(var i = 0 ; 1 ; i += 1)
          {
              if(n.getChild("targets", i, 0) == nil)
              {
                  break;
              }
          }
          m.myTree = forcePath==nil?n.getChild("targets", i, 1):props.globals.getNode(forcePath, 1);
        
        print(m.myTree.getPath());
        
        
        # update interval for engine init() functions
        m.UPDATE_PERIOD = 0.1; 
        
        
        # return our new object
        return m;
    },

    ############### LOOP MANAGEMENT ##################
    # creates an engine update loop (optional)
    ##################################################
    init: func(){
        if(me.loop_running)
        {
            return;
        }
        me.loop_running = 1;
        
        # init Radar Distance
        
        # launch only On time : this is an auto updated loop.
        if(me.haveSweep ==1){me.maj_sweep();}
        
        var loop_Update = func(){
            var radarWorking = getprop(me.ElectricalPath);
            radarWorking = (radarWorking == nil) ? 0 : radarWorking;
            if(radarWorking > 24 and me.AutoUpdate)
            {
                me.update();
                #These line bellow are error management.
                var UpdateErr = [];
                call(me.update,[],me,nil,UpdateErr);
                if(size(UpdateErr) != 0)
                {
                    print("Radar update Error");
                }
            }
            me.janitor();
            settimer(loop_Update, me.UPDATE_PERIOD);
        };
        settimer(loop_Update, 0);
        
        var loop_Sweep = func(){
            if(me.haveSweep ==1){me.maj_sweep();}
            settimer(loop_Sweep, 0);
        };
        settimer(loop_Sweep, 0);
        #settimer(loop, 0);
    },

    ############
    #  UPDATE  #
    ############
    update: func(tempCoord = nil, tempHeading = nil, tempPitch = nil){
    
    
    ####First update Coord, Alt, heeading and Pitch. 
    ## The code pout the aircraft properties if nothing has been passed in parameters
        #Coord update ! Should be filled with altitude
        if(tempCoord == nil){
          me.MyCoord = geo.aircraft_position();
        }else{
          me.MyCoord = tempCoord;
        }
        
        #Altitude update (in meters)
        me.our_alt = me.MyCoord.alt();
        
        #Heading Update (should be the airplane heading, not the radar look direction)
         if(tempHeading == nil){
          me.OurHdg = getprop("orientation/heading-deg");
        }else{
          me.OurHdg = tempHeading;
        }
        
         #Pitch Update (should be the airplane heading, not the radar look direction)
         if(tempPitch == nil){
          me.OurPitch = getprop("orientation/pitch-deg");
        }else{
          me.OurPitch = tempPitch;
        }
        ####Variable initialized
        
        var CANVASARRAY = [];
        
        var raw_list = me.Mp.getChildren();
        foreach(var c ; raw_list)
        {
            # FIXME: At that time a multiplayer node may have been deleted while still
            # existing as a displayable target in the radar targets nodes.
            # FIXED, with janitor. 5H1N0B1
            var type = c.getName();
            if(! c.getNode("valid", 1).getValue())
            {
                continue;
            }
            
            # the 2 following line are needed : If not, it would detects our own missiles...
            # this will come soon
            var HaveRadarNode = c.getNode("radar");
            #print(me.check_selected_type(c));
            #if(type == "multiplayer"
            #    or (type == "tanker" and HaveRadarNode != nil)
            #    or (type == "aircraft" and me.showAI == 1)
             #   or type == "carrier"
              #  or type == "ship"
               # or (type == "missile" and HaveRadarNode != nil))
            #{
            if(me.check_selected_type(c))
            {
                # creation of the tempo object Target
                var u = Target.new(c,me.myTree.getPath());
                
                #print("Testing "~ u.get_Callsign()~"Type: " ~ type);
                
                # set Check_List to void
                me.Check_List = [];
                # this function do all the checks and put all result of each
                # test on an array[] named Check_List
                me.go_check(u);
                
                # then a function just check it all
                if(me.get_check(u))
                {
                    var HaveRadarNode = c.getNode("radar");
                    u.create_tree(me.MyCoord);
                    u.set_all(me.MyCoord);
                    me.calculateScreen(u);
                    # for Target Selection
                    # here we disable the capacity of targeting a missile. But 's possible.
                    append(CANVASARRAY, u);
                    if(type != "missile")
                    {
                        me.TargetList_AddingTarget(u);
                    }
                    me.displayTarget();
                }
                else
                {
                    if(u.get_Validity() == 1)
                    {
                        if(getprop("sim/time/elapsed-sec") - u.get_TimeLast() > me.MyTimeLimit)
                        {
                            # call Janitor
                            u.set_nill();
                            me.TargetList_RemovingTarget(u);
                        }
                    }
                }
            }
        }
        return CANVASARRAY;
    },


    calculateScreen: func(SelectedObject){
        # swp_diplay_width = Global
        # az_fld = Global
        # ppi_diplay_radius = Global
        
        SelectedObject.check_carrier_type();
        mydeviation = SelectedObject.get_deviation(me.OurHdg, me.MyCoord);
        var u_rng = me.targetRange(SelectedObject);
        
        # compute mp position in our B-scan like display. (Bearing/horizontal + Range/Vertical).
        SelectedObject.set_relative_bearing(me.swp_diplay_width / me.az_fld * mydeviation);
        var factor_range_radar = me.rng_diplay_width / me.rangeTab[me.rangeIndex]; # length of the distance range on the B-scan screen.
        SelectedObject.set_ddd_draw_range_nm(factor_range_radar * u_rng);
        u_fading = 1;
        u_display = 1;
        
        # Compute mp position in our PPI like display.
        factor_range_radar = me.ppi_diplay_radius / me.rangeTab[me.rangeIndex]; # Length of the radius range on the PPI like screen.
        SelectedObject.set_tid_draw_range_nm(factor_range_radar * u_rng);
        
        # Compute first digit of mp altitude rounded to nearest thousand. (labels).
        SelectedObject.set_rounded_alt(rounding1000(SelectedObject.get_altitude()) / 1000);
        
        # Compute closure rate in Kts.
        #SelectedObject.get_closure_rate_from_Coord(me.MyCoord) * MPS2KT;
        
        # Check if u = nearest echo.
        if(SelectedObject.get_Callsign() == getprop("/ai/closest/callsign"))
        {
            #print(u.get_Callsign());
            tmp_nearest_u = SelectedObject;
            tmp_nearest_rng = u_rng;
        }
        SelectedObject.set_display(u_display);
        SelectedObject.set_fading(u_fading);
    },

    isNotBehindTerrain: func(SelectedObject){
        isVisible = 0;
        
        # As the script is relatively ressource consuming, then, we do a maximum of test before doing it
#         if(me.get_check())
#         {
            SelectCoord = SelectedObject.get_Coord();
            
            SelectCoord.set_alt(SelectCoord.alt()+1);
            # Because there is no terrain on earth that can be between these 2
            if(me.our_alt < 8900 and SelectCoord.alt() < 8900)
            {
                  var myPos = geo.aircraft_position();

                  var xyz = {"x":myPos.x(),                  "y":myPos.y(),                 "z":myPos.z()};
                  var dir = {"x":SelectCoord.x()-myPos.x(),  "y":SelectCoord.y()-myPos.y(), "z":SelectCoord.z()-myPos.z()};

                  # Check for terrain between own aircraft and other:
                  v = get_cart_ground_intersection(xyz, dir);
                  if (v == nil) {
                    return 1;
                    #printf("No terrain, planes has clear view of each other");
                  } else {
                  var terrain = geo.Coord.new();
                  terrain.set_latlon(v.lat, v.lon, v.elevation);
                  var maxDist = myPos.direct_distance_to(SelectCoord);
                  var terrainDist = myPos.direct_distance_to(terrain);
                  if (terrainDist < maxDist-1) {
                    #print("terrain found between the planes");
                    return 0;
                  } else {
                      #print("The planes has clear view of each other");
                      return 1;
                  }
                  }
            
            
                
            }
            else
            {
                isVisible = 1;
            }
#         }
        return isVisible;
    },

    NotBeyondHorizon: func(SelectedObject){
        # if distance is beyond the earth curve
        var horizon = SelectedObject.get_horizon(me.our_alt);
        var u_rng = me.targetRange(SelectedObject);
        #print("u_rng : " ~ u_rng ~ ", Horizon : " ~ horizon);
        var InHorizon = (u_rng < horizon);
        return InHorizon;
    },

    doppler: func(SelectedObject){
        # Test to check if the target can hide bellow us
        # Or Hide using anti doppler movements
        
        var InDoppler = 0;
        var groundNotbehind = me.isGroundNotBehind(SelectedObject);
        if(groundNotbehind)
        {
            InDoppler = 1;
        }
        if(me.HaveDoppler and (abs(SelectedObject.get_closure_rate_from_Coord(me.MyCoord)) > me.DopplerSpeedLimit))
        {
            InDoppler = 1;
        }
        if(SelectedObject.get_Callsign() == "GROUND_TARGET" or SelectedObject.check_carrier_type())
        {
            InDoppler = 1;
        }
        return InDoppler;
    },

    isGroundNotBehind: func(SelectedObject){
        var myPitch = SelectedObject.get_Elevation_from_Coord(me.MyCoord);
        var GroundNotBehind = 1; # sky is behind the target (this don't work on a valley)
        if(myPitch < 0 and me.NotBeyondHorizon(SelectedObject))
        {
            # the aircraft is bellow us, the ground could be bellow
            # Based on earth curve. Do not work with mountains
            # The script will calculate what is the ground distance for the line (us-target) to reach the ground,
            # If the earth was flat. Then the script will compare this distance to the horizon distance
            # If our distance is greater than horizon, then sky behind
            # If not, we cannot see the target unless we have a doppler radar
            var distHorizon = me.MyCoord.alt() / math.tan(abs(myPitch * D2R)) * M2NM;
            var horizon = SelectedObject.get_horizon( me.our_alt);
            var TempBool = (distHorizon > horizon);
            GroundNotBehind = (distHorizon > horizon);
        }
        return GroundNotBehind;
    },

    inAzimuth: func(SelectedObject){
        # Check if it's in Azimuth.
        # first we check our heading+ center az deviation + the sweep if the radar is mechanical
        tempAz = me.az_fld;
        var inMyAzimuth = 0;
        
        var myHeading = math.mod(me.fieldazCenter + me.OurHdg, 360);
        if(me.haveSweep)
        {
            myHeading = math.mod(myHeading + me.SwpMarker * (0.0844 / me.swp_diplay_width) * tempAz / 4, 360);
            mydeviation = SelectedObject.get_deviation(myHeading, me.MyCoord);
            #print("Heading:"~ myHeading ~" My deviation:"~ mydeviation);
            inMyAzimuth = (abs(mydeviation) < (tempAz / 4));
        }
        else
        {
            mydeviation = SelectedObject.get_deviation(myHeading, me.MyCoord);
            inMyAzimuth = (abs(mydeviation)<(tempAz/2));
        }
        return inMyAzimuth;
    },

    inElevation: func(SelectedObject){
        # Moving the center of this field will be ne next option
        var tempAz = me.vt_az_fld;
        var myElevation = SelectedObject.get_total_elevation_from_Coord(me.OurPitch, me.MyCoord);
        var IsInElevation = (abs(myElevation) < (tempAz / 2));
        return IsInElevation;
    },

    InRange: func(SelectedObject){
        IsInRange = rcs.isInRadarRange(SelectedObject, 30*10, 150);
        return IsInRange;
    },

    heat_sensor: func(SelectedObject){
        myEngineTree = SelectedObject.get_engineTree();
        # If MP or AI has an engine tree, we will check for each engine n1>30 or rpm>1000
        if(myEngineTree != nil)
        {
            var engineList = myEngineTree.getChildren();
            foreach(var currentEngine ; engineList)
            {
                var HaveN1node = currentEngine.getNode("n1");
                var HaveRPMnode = currentEngine.getNode("rpm");
                if(HaveN1node != nil)
                {
                    n1value = HaveN1node.getValue();
                    if(n1value != nil and n1value > 30)
                    {
                        #print("N1 detected");
                        return 1;
                    }
                }
                if(HaveRPMnode != nil)
                {
                    RpMvalue = HaveRPMnode.getValue();
                    if(RpMvalue != nil and RpMvalue > 1000)
                    {
                        #print("RPM detected");
                        return 1;
                    }
                }
            }
        }
        # Here we could add a velocity test : if speed >mach 1, we can imagine that friction provides heat
    },

    maj_sweep:func(){
        var x = (getprop("sim/time/elapsed-sec") / (me.sweep_frequency)) * (0.0844 / me.swp_diplay_width); # shorten the period time when illuminating a target
        #print("SINUS (X) = "~math.sin(x);
        me.SwpMarker = (math.sin(3.14 * x) * (me.swp_diplay_width / 0.0844)); # shorten the period amplitude when illuminating
        setprop(me.sweepProperty,me.SwpMarker);
    },

    targetRange: func(SelectedObject){
        # This is a way to shortcurt the issue that some of node have : in-range =0
        # So by giving the second fucntion our coord, we just have to calculate it
        var myRange = 0;
        myRange = SelectedObject.get_range();
        if(myRange == 0)
        {
            myRange = SelectedObject.get_range_from_Coord(me.MyCoord);
        }
        #print("myRange="~myRange);
        return myRange;
    },

    targetBearing: func(SelectedObject){
        # This is a way to shortcurt the issue that some of node have : bearing =0
        # So by giving the second fucntion our coord, we just have to calculate it
        var myBearing = 0;
        myBearing = SelectedObject.get_bearing();
        if(myBearing == 0)
        {
            myBearing = SelectedObject.get_bearing_from_Coord(me.MyCoord);
        }
        return myBearing;
    },

    TargetList_AddingTarget: func(SelectedObject){
        # This is selectioned target management.
        if(me.TargetList_LookingForATarget(SelectedObject) == 0)
        {
            append(me.tgts_list, SelectedObject);
        }
    },

    TargetList_RemovingTarget: func(SelectedObject){
        # This is selectioned target management.
        if(me.TargetList_LookingForATarget(SelectedObject) > 5)
        {
            # Then kill it
            var TempoTgts_list = [];
            foreach(var TempTarget ; me.tgts_list)
            {
                if(TempTarget.get_shortring() != SelectedObject.get_shortring())
                {
                    append(TempoTgts_list, TempTarget);
                }
            }
            me.tgts_list = TempoTgts_list;
        }
    },

    TargetList_LookingForATarget: func(SelectedObject){
        # This is selectioned target management.
        # Target list janitor
        foreach(var TempTarget ; me.tgts_list)
        {
            if(TempTarget.get_shortring() == SelectedObject.get_shortring())
            {
                return TempTarget.get_TimeLast();
            }
        }
        return 0;
    },

    get_check: func(){
        # This function allow to display multi check
        var checked = 1;
        var CheckTable = ["InRange:", "inAzimuth:", "inElevation:", "Horizon:", "Doppler:", "NotBtBehindTerrain:"];
        var i = 0;
        foreach(myCheck ; me.Check_List)
        {
            #print(CheckTable[i] ~ " " ~ myCheck);
            i +=1;
            checked = (myCheck and checked);
        }
        return checked;
    },
    
    check_selected_type: func(SelectedObject)
    {
    var result = 0;
    #Variable for the selection Type test
    var selectedType = SelectedObject.getName();
    
     #variable for the RadarNode test
      var shouldHaveRadarNode = ["tanker","aircraft","missile"];
     var HaveRadarNode = SelectedObject.getNode("radar");
     
     #We test the type of target
      foreach(myType;me.typeTarget)
      {
        if(myType == selectedType){
           result = 1;
        }
      }
      
      #We test if they have a radar Node (they should all have one, but unconventionnal model like ATC or else could have these issue)
      foreach(myType;shouldHaveRadarNode)
      {
        if(myType == selectedType and HaveRadarNode == nil){
          result = 0;
        }
      }
      
      return result;
    },

    go_check: func(SelectedObject){
        #if radar : check : InRange, inAzimuth, inElevation, NotBeyondHorizon, doppler, isNotBehindTerrain
        #if Rwr   : check : InhisRange (radardist), inHisElevation, inHisAzimuth, NotBeyondHorizon, isNotBehindTerrain
        #if heat  : check : InRange, inAzimuth, inElevation, NotBeyondHorizon, heat_sensor, isNotBehindTerrain
        #if laser : check : InRange, inAzimuth, inElevation, NotBeyondHorizon, isNotBehindTerrain
        #if cam  : check : InRange, inAzimuth, inElevation, NotBeyondHorizon, isNotBehindTerrain
        # Need to add the fonction flare_sensivity : is there flare near aircraft and should we get fooled by it
    
        append(me.Check_List, me.InRange(SelectedObject));
        if(me.Check_List[0] == 0)
        {
            return;
        }
        append(me.Check_List, me.inAzimuth(SelectedObject));
        if(me.Check_List[1] == 0)
        {
            return;
        }
        append(me.Check_List, me.inElevation(SelectedObject));
        if(me.Check_List[2] == 0)
        {
            return;
        }
        append(me.Check_List, me.NotBeyondHorizon(SelectedObject));
        if(me.Check_List[3] == 0)
        {
            return;
        }
        #me.heat_sensor(SelectedObject);
        if( me.detectionTypetab=="laser")
        {
          append(me.Check_List, 1);
         }else{
          append(me.Check_List, me.doppler(SelectedObject));
         }
        if(me.Check_List[4] == 0)
        {
            return;
        }
        
        # Has to be last coz it will call the get_checked function
        append(me.Check_List, me.isNotBehindTerrain(SelectedObject));
    },

    janitor: func(){
        # This function is made to remove all persistent non relevant data on radar2 tree
        #var myRadarNode = props.globals.getNode("instrumentation/radar2/targets", 1);
        var raw_list = me.myTree.getChildren();
        foreach(var Tempo_TgtsFiles ; raw_list)
        {
            #print(Tempo_TgtsFiles.getName());
            if(Tempo_TgtsFiles.getNode("display", 1).getValue() != nil)
            {
                var myTime = Tempo_TgtsFiles.getNode("closure-last-time", 1);
                if(getprop("sim/time/elapsed-sec") - myTime.getValue() > me.janitorTime)
                {
                    var Property_list = Tempo_TgtsFiles.getChildren();
                    foreach(var myProperty ; Property_list )
                    {
                        # print(myProperty.getName());
                        if(myProperty.getName() != "closure-last-time")
                        {
                            myProperty.setValue("");
                        }
                    }
                }
            }
        }
    },
    #increase radar distance
    switch_distance_ics: func(){
      me.rangeIndex = math.mod(me.rangeIndex + 1, size(me.rangeTab));
    },
    #decrease radar distance
   switch_distance_dcs: func(){
      me.rangeIndex = math.mod(me.rangeIndex - 1, size(me.rangeTab));
    },
   #get radar distance
   get_radar_distance: func(){
      return me.rangeTab[me.rangeIndex];
    },
    
    radar_mode_toggle: func(){
      # FIXME: Modes props should provide their own data instead of being hardcoded.
      # Toggles between the available modes.
      foreach(var n ; props.globals.getNode("instrumentation/radar/mode").getChildren())
      {
        if(n.getBoolValue())
        {
          wcs_mode = n.getName();
        }
      }
      if(wcs_mode == "rws")
      {
        setprop("instrumentation/radar/mode/rws", 0);
        setprop("instrumentation/radar/mode/tws-auto", 1);
        wcs_mode = "tws-auto";
        me.az_fld=me.focused_az_fld;
        me.vt_az_fld=me.focused_az_fld;
        me.swp_diplay_width = 0.0422;
        me.tgts_list = [];
      }
      elsif(wcs_mode == "tws-auto")
      {
        setprop("instrumentation/radar/mode/tws-auto", 0);
        setprop("instrumentation/radar/mode/rws", 1);
        wcs_mode = "pulse-srch";
        me.az_fld=me.unfocused_az_fld;
        me.vt_az_fld=me.unfocused_az_fld;
        me.swp_diplay_width = 0.0844;
      }
      me.displayTarget();
      return me.az_fld;
    },
    
    next_Target_Index: func(){
      me.Target_Index = math.mod(me.Target_Index + 1, size(me.tgts_list));
    },

    previous_Target_Index: func(){
      me.Target_Index = math.mod(me.Target_Index - 1, size(me.tgts_list));
    },

    displayTarget: func(){
    #60 here is the illuminating or selecting cone. This has to be reworked
    #1 To not to depend of a written value. 2 To take account that some radar do not need focus to get target
    #perhaps introduce a "selecting" target variable
    # This is very mirage specific. We should find a way to remove it
        if(size(me.tgts_list) != 0 and me.az_fld==me.focused_az_fld)
        {
            if( me.Target_Index < 0)
            {
                 me.Target_Index = size(me.tgts_list) - 1;
            }
            if( me.Target_Index > size(me.tgts_list) - 1)
            {
                 me.Target_Index = 0;
            }
            var MyTarget = me.tgts_list[ me.Target_Index];
            closeRange   = me.targetRange(MyTarget);
            heading      = MyTarget.get_heading();
            altitude     = MyTarget.get_altitude();
            speed        = MyTarget.get_Speed();
            callsign     = MyTarget.get_Callsign();
            longitude    = MyTarget.get_Longitude();
            latitude     = MyTarget.get_Latitude();
            bearing      = me.targetBearing(MyTarget);
            if(speed == nil)
            {
                speed = 0;
            }
            setprop("/ai/closest/range", closeRange);
            setprop("/ai/closest/bearing", bearing);
            setprop("/ai/closest/heading", heading);
            setprop("/ai/closest/altitude", altitude);
            setprop("/ai/closest/speed", speed);
            setprop("/ai/closest/callsign", callsign);
            setprop("/ai/closest/longitude", longitude);
            setprop("/ai/closest/latitude", latitude);
        }else{
            setprop("/ai/closest/range", 0);
        }
    },
    GetTarget: func(){
      if(size(me.tgts_list) <= 0)
      {
        return nil;
      }
      if(me.Target_Index < 0)
      {
        me.Target_Index = size(me.tgts_list) - 1;
      }
      if(me.Target_Index > size(me.tgts_list) - 1)
      {
        me.Target_Index = 0;
      }
      return me.tgts_list[me.Target_Index];
    },
    #toggle_Type: func(){
    #  me.detectionTypeIndex = math.mod(me.detectionTypeIndex + 1, size(me.detectionTypetab));
    #  setprop("/sim/messages/atc", "Toggle Detection Type : "~ me.detectionTypetab[me.detectionTypeIndex]);
    #},

    myRadarList : [],
};

################################################################
#####################   Target class  ##########################
################################################################

var Target = {
    new: func(c,theTree = nil){
        var obj             = { parents : [Target,geo.Coord.new()]};
        obj.RdrProp         = c.getNode("radar");
        obj.Heading         = c.getNode("orientation/true-heading-deg");
        
        obj.Alt             = c.getNode("position/altitude-ft");
        obj.lat             = c.getNode("position/latitude-deg");
        obj.lon             = c.getNode("position/longitude-deg");
        
        #As it is a geo.Coord object, we have to update lat/lon/alt ->and alt is in meters
        #print("obj.lat:"~obj.lat~" obj.lon:"~" obj.Alt * FT2M:"~obj.Alt * FT2M);
        obj.set_latlon(obj.lat.getValue(), obj.lon.getValue(), obj.Alt.getValue() * FT2M);
        
        
        obj.pitch           = c.getNode("orientation/pitch-deg");
        obj.roll           = c.getNode("orientation/roll-deg");
        
        obj.Speed           = c.getNode("velocities/true-airspeed-kt");
        obj.VSpeed          = c.getNode("velocities/vertical-speed-fps");
        obj.Callsign        = c.getNode("callsign");
        obj.name            = c.getNode("name");
        obj.Valid            = c.getNode("valid");
        obj.validTree       = 0;
        obj.TransponderID = c.getNode("instrumentation/transponder/transmitted-id");
        
        obj.engineTree      = c.getNode("engines");
        
        obj.AcType          = c.getNode("sim/model/ac-type");
        obj.type            = c.getName();
        obj.index           = c.getIndex();
        obj.string          = "ai/models/" ~ obj.type ~ "[" ~ obj.index ~ "]";
        obj.shortstring     = obj.type ~ "[" ~ obj.index ~ "]";
        
        if(theTree == nil){
          obj.InstrString     = "instrumentation/radar2/targets";
        }else{
           obj.InstrString     = theTree;
        }
        #print("obj.InstrString:" ~obj.InstrString);
        obj.InstrTgts       = props.globals.getNode(obj.InstrString, 1);
        
        obj.TgtsFiles       =   0; #obj.InstrTgts.getNode(obj.shortstring, 1);
        
        obj.Range           = obj.RdrProp.getNode("range-nm");
        obj.Bearing         = obj.RdrProp.getNode("bearing-deg");
        obj.Elevation       = obj.RdrProp.getNode("elevation-deg");
        obj.pth = c.getNode("sim/model/path");
        obj.MyCallsign      = 0;
        obj.BBearing        = 0; #obj.TgtsFiles.getNode("bearing-deg", 1);
        obj.BHeading        = 0; #obj.TgtsFiles.getNode("true-heading-deg", 1);
        obj.RangeScore      = 0; #obj.TgtsFiles.getNode("range-score", 1);
        obj.RelBearing      = 0; #obj.TgtsFiles.getNode("ddd-relative-bearing", 1);
        obj.Carrier         = 0; #obj.TgtsFiles.getNode("carrier", 1);
        obj.EcmSignal       = 0; #obj.TgtsFiles.getNode("ecm-signal", 1);
        obj.EcmSignalNorm   = 0; #obj.TgtsFiles.getNode("ecm-signal-norm", 1);
        obj.EcmTypeNum      = 0; #obj.TgtsFiles.getNode("ecm_type_num", 1);
        obj.Display         = 0; #obj.TgtsFiles.getNode("display", 1);
        obj.Fading          = 0; #obj.TgtsFiles.getNode("ddd-echo-fading", 1);
        obj.DddDrawRangeNm  = 0; #obj.TgtsFiles.getNode("ddd-draw-range-nm", 1);
        obj.TidDrawRangeNm  = 0; #obj.TgtsFiles.getNode("tid-draw-range-nm", 1);
        obj.RoundedAlt      = 0; #obj.TgtsFiles.getNode("rounded-alt-ft", 1);
        obj.TimeLast        = 0; #obj.TgtsFiles.getNode("closure-last-time", 1);
        obj.RangeLast       = 0; #obj.TgtsFiles.getNode("closure-last-range-nm", 1);
        obj.ClosureRate     = 0; #obj.TgtsFiles.getNode("closure-rate-kts", 1);
        
        #obj.TimeLast.setValue(ElapsedSec.getValue());
        
        obj.RadarStandby    = c.getNode("sim/multiplay/generic/int[2]");
        
        obj.deviation       = nil;
        
        obj.Model = c.getNode("model-short");
        var model_short = c.getNode("sim/model/path");
        if(model_short != nil)
        {
            var model_short_val = model_short.getValue();
            if (model_short_val != nil and model_short_val != "")
            {
                var u = split("/", model_short_val); # give array
                var s = size(u); # how many elements in array
                var o = u[s-1];  # the last element
                var m = size(o); # how long is this string in the last element
                var e = m - 4;   # - 4 chars .xml
                obj.ModelType = substr(o, 0, e); # the string without .xml
            }
            else
                obj.ModelType = "";
        } elsif (c.getNode("type") != nil) {
            # not all have a path property
            obj.ModelType = c.getNode("type").getValue();
            if (obj.ModelType == nil) {
                # not all have a type property
                obj.ModelType = "";
            }
        } else {
            obj.ModelType = "";
        }
        
        return obj;
    },

    create_tree: func(MyAircraftCoord){

        me.TgtsFiles      = me.InstrTgts.getNode(me.shortstring, 1);
        
        me.MyCallsign     = me.TgtsFiles.getNode("callsign", 1);
        me.BBearing       = me.TgtsFiles.getNode("bearing-deg", 1);
        me.BHeading       = me.TgtsFiles.getNode("true-heading-deg", 1);
        me.RangeScore     = me.TgtsFiles.getNode("range-score", 1);
        me.RelBearing     = me.TgtsFiles.getNode("ddd-relative-bearing", 1);
        me.Carrier        = me.TgtsFiles.getNode("carrier", 1);
        me.EcmSignal      = me.TgtsFiles.getNode("ecm-signal", 1);
        me.EcmSignalNorm  = me.TgtsFiles.getNode("ecm-signal-norm", 1);
        me.EcmTypeNum     = me.TgtsFiles.getNode("ecm_type_num", 1);
        me.Display        = me.TgtsFiles.getNode("display", 1);
        me.Fading         = me.TgtsFiles.getNode("ddd-echo-fading", 1);
        me.DddDrawRangeNm = me.TgtsFiles.getNode("ddd-draw-range-nm", 1);
        me.TidDrawRangeNm = me.TgtsFiles.getNode("tid-draw-range-nm", 1);
        me.RoundedAlt     = me.TgtsFiles.getNode("rounded-alt-ft", 1);
        me.TimeLast       = me.TgtsFiles.getNode("closure-last-time", 1);
        me.RangeLast      = me.TgtsFiles.getNode("closure-last-range-nm", 1);
        me.ClosureRate    = me.TgtsFiles.getNode("closure-rate-kts", 1);
        me.pth2 = me.TgtsFiles.getNode("sim/model/path", 1); 
        if (me.pth != nil) {
        me.pth2.setValue(me.pth.getValue());
    }
        
        me.TimeLast.setDoubleValue(ElapsedSec.getValue());
        me.RangeLast.setValue(me.get_range_from_Coord(MyAircraftCoord));
        me.Carrier.setBoolValue(0);
        
        #Create essential tree
        var altTree =me.TgtsFiles.getNode("position/altitude-ft",1);
        var latTree =me.TgtsFiles.getNode("position/latitude-deg",1);
        var lonTree =me.TgtsFiles.getNode("position/longitude-deg",1);
         me.validTree =me.TgtsFiles.getNode("valid",1);
         var radarBearing =me.TgtsFiles.getNode("radar/bearing-deg",1);
         var radarRange =me.TgtsFiles.getNode("radar/range-nm",1);
         var elevation =me.TgtsFiles.getNode("radar/elevation-deg",1);
         var velocities =me.TgtsFiles.getNode("velocities/true-airspeed-kt",1);
         var transpondeur =me.TgtsFiles.getNode("instrumentation/transponder/transmitted-id",1);
         var heading =me.TgtsFiles.getNode("orientation/true-heading-deg",1);
         
         

        altTree.setValue(me.Alt.getValue());
        latTree.setValue(me.lat.getValue());
        lonTree.setValue(me.lon.getValue());
        me.validTree.setValue(me.Valid.getValue());
        radarBearing.setValue(me.Bearing.getValue());
        radarRange.setValue(me.Range.getValue());
        elevation.setValue(me.Elevation.getValue());
        velocities.setValue(me.Speed.getValue());
        if(me.TransponderID != nil){
          if(me.TransponderID.getValue() != nil){
            transpondeur.setValue(me.TransponderID.getValue());
          }
        }
        heading.setValue(me.Heading.getValue());


    },

    set_all: func(myAircraftCoord){
        me.RdrProp.getNode("in-range").setValue("true");
        me.MyCallsign.setValue(me.get_Callsign());
        me.BHeading.setValue(me.Heading.getValue());
        me.BBearing.setValue(me.get_bearing_from_Coord(myAircraftCoord));
    },

    remove: func(){
        #me.validTree = 0;
        if(me.validTree != 0){me.validTree.setValue(0);}
        me.InstrTgts.removeChild(me.type, me.index);
    },

    set_nill: func(){
        # Suppression of the HUD display :
        # The property is initialised when the target is in range of "instrumentation/radar/range"
        # But nothing is done when "It's no more in range"
        # So this is a little hack for HUD.
        if(me.validTree != 0){me.validTree.setValue(0);}
        me.RdrProp.getNode("in-range").setValue("false");
        
        var Tempo_TgtsFiles = me.InstrTgts.getNode(me.shortstring, 1);
        var Property_list   = Tempo_TgtsFiles.getChildren();
        foreach(var myProperty ; Property_list)
        {
            #print(myProperty.getName());
            if(myProperty.getName() != "closure-last-time")
            {
                myProperty.setValue("");
            }
        }
    },

    get_Validity: func(){
        var n = 0;
        if(getprop(me.InstrString ~ "/" ~ me.shortstring ~ "/closure-last-time") != nil)
        {
            n = 1;
        }
        return n;
    },

    get_TimeLast: func(){
        var n = 0;
        if(getprop(me.InstrString ~ "/" ~ me.shortstring ~ "/closure-last-time") != nil )
        {
            #print(me.InstrString ~ "/" ~ me.shortstring ~ "/closure-last-time");
            #print(getprop(me.InstrString ~ "/" ~ me.shortstring ~ "/closure-last-time"));
            n = getprop(me.InstrString ~ "/" ~ me.shortstring ~ "/closure-last-time");
        }
        return n;
    },

    get_Coord: func(){
        TgTCoord  = geo.Coord.new();
        TgTCoord.set_latlon(me.lat.getValue(), me.lon.getValue(), me.Alt.getValue() * FT2M);
        me.set_latlon(me.lat.getValue(), me.lon.getValue(), me.Alt.getValue() * FT2M);
        return TgTCoord;
    },
    
    get_model: func {
        return me.ModelType;
    },

    get_Callsign: func(){
        var n = me.Callsign.getValue();
        if(size(n) < 1)
        {
            n = me.name.getValue();
        }
        if(n == nil or size(n) < 1)
        {
            n = "UFO";
        }
        return n;
    },

    get_Speed: func(){
        var n = me.Speed.getValue();
        #var alt = me.Alt.getValue();
        #n = n / (0.632 ^ (-(alt / 25066))); # Calcul of Air Speed based on ground speed. the function ^ doesn't work !!
        return n;
    },

    get_Longitude: func(){
        var n = me.lon.getValue();
        return n;
    },

    get_Latitude: func(){
        var n = me.lat.getValue();
        return n;
    },

    get_Pitch: func(){
        var n = me.pitch.getValue();
        return n;
    },
    
    get_Roll: func(){
        var n = me.roll.getValue();
        return n;
    },

    get_heading : func(){
        var n = me.Heading.getValue();
        if(n == nil)
        {
            n = 0;
        }
        return n;
    },

    get_bearing: func(){
        var n = 0;
        n = me.Bearing.getValue();
        if(n == nil)
        {
            n = 0;
        }
        return n;
    },

    get_bearing_from_Coord: func(MyAircraftCoord){
        var myCoord = me.get_Coord();
        var myBearing = 0;
        if(myCoord.is_defined())
        {
            myBearing = MyAircraftCoord.course_to(myCoord);
        }
        #print("get_bearing_from_Coord :" ~ myBearing);
        return myBearing;
    },

    set_relative_bearing: func(n){
        if(n == nil)
        {
            n = 0;
        }
        me.RelBearing.setValue(n);
    },

    get_reciprocal_bearing: func(){
        return geo.normdeg(me.get_bearing() + 180);
    },

    get_deviation: func(true_heading_ref, coord){
        me.deviation =  - deviation_normdeg(true_heading_ref, me.get_bearing_from_Coord(coord));
        #print(me.deviation);
        return me.deviation;
    },

    get_altitude: func(){
        #Return Alt in feet
        return me.Alt.getValue();
    },

    get_Elevation_from_Coord: func(MyAircraftCoord){
        var myCoord = me.get_Coord();
        var myPitch = math.asin((myCoord.alt() - MyAircraftCoord.alt()) / myCoord.direct_distance_to(MyAircraftCoord)) * R2D;
        return myPitch;
    },

    get_total_elevation_from_Coord: func(own_pitch, MyAircraftCoord){
        var myTotalElevation =  - deviation_normdeg(own_pitch, me.get_Elevation_from_Coord(MyAircraftCoord));
        return myTotalElevation;
    },
    
    get_total_elevation: func(own_pitch){
        me.deviation =  - deviation_normdeg(own_pitch, me.Elevation.getValue());
        return me.deviation;
    },

    get_range: func(){
        #print("me.Range.getValue() :" ~ me.Range.getValue());
        return me.Range.getValue();
    },

    get_range_from_Coord: func(MyAircraftCoord){
        var myCoord = me.get_Coord();
        var myDistance = 0;
        if(myCoord.is_defined())
        {
            myDistance = MyAircraftCoord.direct_distance_to(myCoord) * M2NM;
        }
        #print("get_range_from_Coord :" ~ myDistance);
        return myDistance;
    },

    get_horizon: func(own_alt){
    #Own alt in meters
        var tgt_alt = me.get_altitude();#It's in feet
        if(debug.isnan(tgt_alt))
        {
            return(0);
        }
        if(tgt_alt < 0 or tgt_alt == nil)
        {
            tgt_alt = 0;
        }
        if(own_alt < 0 or own_alt == nil)
        {
            own_alt = 0;
        }
        # Return the Horizon in NM
        return(2.2 * ( math.sqrt(own_alt) + math.sqrt(tgt_alt * FT2M)));
    },

    get_engineTree: func(){
        return me.engineTree;
    },

    check_carrier_type: func(){
        var type = "none";
        var carrier = 0;
        if(me.AcType != nil)
        {
            type = me.AcType.getValue();
        }
        if(type == "MP-Nimitz"
            or type == "MP-Eisenhower"
            or type == "MP-Vinson"
            or type == "Nimitz"
            or type == "Eisenhower"
            or type == "Vinson"
        )
        {
            carrier = 1;
        }
        if(me.type == "carrier")
        {
            carrier = 1;
        }
        # This works only after the mp-carrier model has been loaded. Before that it is seen like a common aircraft.
        if(me.get_Validity())
        {
            setprop(me.InstrString ~ "/" ~ me.shortstring ~ "/carrier", carrier);
        }
        return carrier;
    },

    get_rdr_standby: func(){
        var s = 0;
        if(me.RadarStandby != nil)
        {
            s = me.RadarStandby.getValue();
            if(s == nil)
            {
                s = 0;
            }
            elsif(s != 1)
            {
                s = 0;
            }
        }
        return s;
    },

    get_display: func(){
        return me.Display.getValue();
    },

    set_display: func(n){
        me.Display.setBoolValue(n);
    },

    get_fading: func(){
        var fading = me.Fading.getValue();
        if(fading == nil)
        {
            fading = 0;
        }
        return fading;
    },

    set_fading: func(n){
        me.Fading.setValue(n);
    },

    set_ddd_draw_range_nm: func(n){
        me.DddDrawRangeNm.setValue(n);
    },

    set_hud_draw_horiz_dev: func(n){
        me.HudDrawHorizDev.setValue(n);
    },

    set_tid_draw_range_nm: func(n){
        me.TidDrawRangeNm.setValue(n);
    },

    set_rounded_alt: func(n){
        me.RoundedAlt.setValue(n);
    },

    get_closure_rate: func(){
        var dt = ElapsedSec.getValue() - me.TimeLast.getValue();
        var rng = me.Range.getValue();
        var lrng = me.RangeLast.getValue();
        if(debug.isnan(rng) or debug.isnan(lrng))
        {
            print("####### get_closure_rate(): rng or lrng = nan ########");
            me.ClosureRate.setValue(0);
            me.RangeLast.setValue(0);
            return(0);
        }
        var t_distance = lrng - rng;
        var cr = (dt > 0) ? t_distance / dt * 3600 : 0;
        me.ClosureRate.setValue(cr);
        me.RangeLast.setValue(rng);
        return(cr);
    },

    get_closure_rate_from_Coord: func(MyAircraftCoord) {
        # First step : find the target heading.
        var myHeading = me.Heading.getValue();
        
        # Second What would be the aircraft heading to go to us
        var myCoord = me.get_Coord();
        var projectionHeading = myCoord.course_to(MyAircraftCoord);
        
        # Calculate the angle difference
        var myAngle = myHeading - projectionHeading; #Should work even with negative values
        
        # take the "ground speed"
        # velocities/true-air-speed-kt
        var mySpeed = me.Speed.getValue();
        var myProjetedHorizontalSpeed = mySpeed*math.cos(myAngle*D2R); #in KTS
        
        #print("Projetted Horizontal Speed:"~ myProjetedHorizontalSpeed);
        
        # Now getting the pitch deviation
        var myPitchToAircraft = - me.Elevation.getValue();
        #print("My pitch to Aircraft:"~myPitchToAircraft);
        
        # Get V speed
        if(me.VSpeed.getValue() == nil)
        {
            return 0;
        }
        var myVspeed = me.VSpeed.getValue()*FPS2KT;
        # This speed is absolutely vertical. So need to remove pi/2
        
        var myProjetedVerticalSpeed = myVspeed * math.cos(myPitchToAircraft-90*D2R);
        
        # Control Print
        #print("myVspeed = " ~myVspeed);
        #print("Total Closure Rate:" ~ (myProjetedHorizontalSpeed+myProjetedVerticalSpeed));
        
        # Total Calculation
        var cr = myProjetedHorizontalSpeed+myProjetedVerticalSpeed;
        
        # Setting Essential properties
        var rng = me. get_range_from_Coord(MyAircraftCoord);
        var newTime= ElapsedSec.getValue();
        if(me.get_Validity())
        {
            setprop(me.InstrString ~ "/" ~ me.shortstring ~ "/closure-last-range-nm", rng);
            setprop(me.InstrString ~ "/" ~ me.shortstring ~ "/closure-rate-kts", cr);
        }
        
        return cr;
    },

    get_shortring:func(){
        return me.shortstring;
    },

    list : [],
};

# Utilities.
var deviation_normdeg = func(our_heading, target_bearing){
    var dev_norm = our_heading - target_bearing;
    while(dev_norm < -180)
    {
        dev_norm += 360;
    }
    while(dev_norm > 180)
    {
        dev_norm -= 360;
    }
    return(dev_norm);
}

var rounding1000 = func(n){
    var a = int(n / 1000);
    var l = (a + 0.5) * 1000;
    n = (n >= l) ? ((a + 1) * 1000) : (a * 1000);
    return(n);
}


