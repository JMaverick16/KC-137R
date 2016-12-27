var clamp = func(v, min, max) { v < min ? min : v > max ? max : v }
var encode3bits = func(first, second, third) {
  var integer = first;
  integer = integer + 2 * second;
  integer = integer + 4 * third;
  return integer;
}


var AIR = 0;
var MARINE = 1;
var SURFACE = 2;
var ORDNANCE = 3;

var Contact = {
    # For now only used in guided missiles, to make it compatible with Mirage 2000-5.
    new: func(c, class) {
        var obj             = { parents : [Contact]};
#debug.benchmark("radar process1", func {
        obj.rdrProp         = c.getNode("radar");
        obj.oriProp         = c.getNode("orientation");
        obj.velProp         = c.getNode("velocities");
        obj.posProp         = c.getNode("position");
        obj.heading         = obj.oriProp.getNode("true-heading-deg");
#});
#debug.benchmark("radar process2", func {
        obj.alt             = obj.posProp.getNode("altitude-ft");
        obj.lat             = obj.posProp.getNode("latitude-deg");
        obj.lon             = obj.posProp.getNode("longitude-deg");
#});
#debug.benchmark("radar process3", func {
        #As it is a geo.Coord object, we have to update lat/lon/alt ->and alt is in meters
        obj.coord = geo.Coord.new();
        obj.coord.set_latlon(obj.lat.getValue(), obj.lon.getValue(), obj.alt.getValue() * FT2M);
#});
#debug.benchmark("radar process4", func {
        obj.pitch           = obj.oriProp.getNode("pitch-deg");
        obj.speed           = obj.velProp.getNode("true-airspeed-kt");
        obj.vSpeed          = obj.velProp.getNode("vertical-speed-fps");
        obj.callsign        = c.getNode("callsign", 1);
        obj.shorter         = c.getNode("model-shorter");
        obj.orig_callsign   = obj.callsign.getValue();
        obj.name            = c.getNode("name");
        obj.sign            = c.getNode("sign",1);
        obj.valid           = c.getNode("valid");
        obj.painted         = c.getNode("painted");
        obj.unique          = c.getNode("unique");
        obj.validTree       = 0;
#});
#debug.benchmark("radar process5", func {        
        #obj.transponderID   = c.getNode("instrumentation/transponder/transmitted-id");
#});
#debug.benchmark("radar process6", func {                
        obj.acType          = c.getNode("sim/model/ac-type");
        obj.type            = c.getName();
        obj.index           = c.getIndex();
        obj.string          = "ai/models/" ~ obj.type ~ "[" ~ obj.index ~ "]";
        obj.shortString     = obj.type ~ "[" ~ obj.index ~ "]";
#});
#debug.benchmark("radar process7", func {
        obj.range           = obj.rdrProp.getNode("range-nm");
        obj.bearing         = obj.rdrProp.getNode("bearing-deg");
        obj.elevation       = obj.rdrProp.getNode("elevation-deg");
#});        
        obj.deviation       = nil;

        obj.node            = c;
        obj.class           = class;

        obj.polar           = [0,0];
        obj.cartesian       = [0,0];
        
        return obj;
    },

    isValid: func () {
      var valid = me.valid.getValue();
      if (valid == nil) {
        valid = FALSE;
      }
      if (me.callsign.getValue() != me.orig_callsign) {
        valid = FALSE;
      }
      return valid;
    },

    isPainted: func () {
      if (me.painted == nil) {
        me.painted = me.node.getNode("painted");
      }
      if (me.painted == nil) {
        return nil;
      }
      var p = me.painted.getValue();
      return p;
    },

    getUnique: func () {
      if (me.unique == nil) {
        me.unique = me.node.getNode("unique");
      }
      if (me.unique == nil) {
        return nil;
      }
      var u = me.unique.getValue();
      return u;
    },

    getElevation: func() {
        var e = 0;
        e = me.elevation.getValue();
        if(e == nil or e == 0) {
            # AI/MP has no radar properties
            var self = geo.aircraft_position();
            me.get_Coord();
            var angleInv = clamp(self.distance_to(me.coord)/self.direct_distance_to(me.coord), -1, 1);
            e = (self.alt()>me.coord.alt()?-1:1)*math.acos(angleInv)*R2D;
        }
        return e;
    },

    getNode: func () {
      return me.node;
    },

    getFlareNode: func () {
      return me.node.getNode("sim/multiplay/generic/string[10]");
    },

    setPolar: func(dist, angle) {
      me.polar = [dist,angle];
    },

    setCartesian: func(x, y) {
      me.cartesian = [x,y];
    },

    remove: func(){
        if(me.validTree != 0){
          me.validTree.setValue(0);
        }
    },

    get_Coord: func(){
        me.coord.set_latlon(me.lat.getValue(), me.lon.getValue(), me.alt.getValue() * FT2M);
        var TgTCoord  = geo.Coord.new(me.coord);
        return TgTCoord;
    },

    get_Callsign: func(){
        var n = me.callsign.getValue();
        if(n != "" and n != nil) {
            return n;
        }
        if (me.name == nil) {
          me.name = me.getNode().getNode("name");
        }
        if (me.name == nil) {
          n = "";
        } else {
          n = me.name.getValue();
        }
        if(n != "" and n != nil) {
            return n;
        }
        n = me.sign.getValue();
        if(n != "" and n != nil) {
            return n;
        }
        return "UFO";
    },

    get_model: func(){
        var n = "";
        if (me.shorter == nil) {
          me.shorter = me.node.getNode("model-shorter");
        }
        if (me.shorter != nil) {
          n = me.shorter.getValue();
        }
        if(n != "" and n != nil) {
            return n;
        }
        n = me.sign.getValue();
        if(n != "" and n != nil) {
            return n;
        }
        if (me.name == nil) {
          me.name = me.getNode().getNode("name");
        }
        if (me.name == nil) {
          n = "";
        } else {
          n = me.name.getValue();
        }
        if(n != "" and n != nil) {
            return n;
        }
        return me.get_Callsign();
    },

    get_Speed: func(){
        # return true airspeed
        var n = me.speed.getValue();
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

    get_heading : func(){
        var n = me.heading.getValue();
        if(n == nil)
        {
            n = 0;
        }
        return n;
    },

    get_bearing: func(){
        var n = 0;
        n = me.bearing.getValue();
        if(n == nil or n == 0) {
            # AI/MP has no radar properties
            n = me.get_bearing_from_Coord(geo.aircraft_position());
        }
        return n;
    },

    get_bearing_from_Coord: func(MyAircraftCoord){
        me.get_Coord();
        var myBearing = 0;
        if(me.coord.is_defined()) {
            myBearing = MyAircraftCoord.course_to(me.coord);
        }
        return myBearing;
    },

    get_reciprocal_bearing: func(){
        return geo.normdeg(me.get_bearing() + 180);
    },

    get_deviation: func(true_heading_ref, coord){
        me.deviation =  - deviation_normdeg(true_heading_ref, me.get_bearing_from_Coord(coord));
        return me.deviation;
    },

    get_altitude: func(){
        #Return Alt in feet
        return me.alt.getValue();
    },

    get_Elevation_from_Coord: func(MyAircraftCoord) {
        me.get_Coord();
        var value = (me.coord.alt() - MyAircraftCoord.alt()) / me.coord.direct_distance_to(MyAircraftCoord);
        if (math.abs(value) > 1) {
          # warning this else will fail if logged in as observer and see aircraft on other side of globe
          return 0;
        }
        var myPitch = math.asin(value) * R2D;
        return myPitch;
    },

    get_total_elevation_from_Coord: func(own_pitch, MyAircraftCoord){
        var myTotalElevation =  - deviation_normdeg(own_pitch, me.get_Elevation_from_Coord(MyAircraftCoord));
        return myTotalElevation;
    },
    
    get_total_elevation: func(own_pitch) {
        me.deviation =  - deviation_normdeg(own_pitch, me.getElevation());
        return me.deviation;
    },

    get_range: func() {
        var r = 0;
        if(me.range == nil or me.range.getValue() == nil or me.range.getValue() == 0) {
            # AI/MP has no radar properties
            me.get_Coord();
            r = me.coord.direct_distance_to(geo.aircraft_position()) * M2NM;
        } else {
          r = me.range.getValue();
        }
        return r;
    },

    get_range_from_Coord: func(MyAircraftCoord) {
        var myCoord = me.get_Coord();
        var myDistance = 0;
        if(myCoord.is_defined()) {
            myDistance = MyAircraftCoord.direct_distance_to(myCoord) * M2NM;
        }
        return myDistance;
    },

    get_type: func () {
      return me.class;
    },

    get_cartesian: func() {
      return me.cartesian;
    },

    get_polar: func() {
      return me.polar;
    },
};

var isNotBehindTerrain = func( mp ) {

###########
	var pos = mp.getNode("position");
	var alt = pos.getNode("altitude-ft").getValue();
	var lat = pos.getNode("latitude-deg").getValue();
	var lon = pos.getNode("longitude-deg").getValue();
	if(alt == nil or lat == nil or lon == nil) {
		return isVisible = 0;
	}
	var aircraftPos = geo.Coord.new().set_latlon(lat, lon, alt*0.3048);
#################


    var isVisible = 0;
    var MyCoord = geo.aircraft_position();
    
    # Because there is no terrain on earth that can be between these 2
    if(MyCoord.alt() < 8900 and aircraftPos.alt() < 8900)
    {
        # Temporary variable
        # A (our plane) coord in meters
        var a = MyCoord.x();
        var b = MyCoord.y();
        var c = MyCoord.z();
        # B (target) coord in meters
        var d = aircraftPos.x();
        var e = aircraftPos.y();
        var f = aircraftPos.z();
        var x = 0;
        var y = 0;
        var z = 0;
        var RecalculatedL = 0;
        var difa = d - a;
        var difb = e - b;
        var difc = f - c;
        # direct Distance in meters
        var myDistance = aircraftPos.direct_distance_to(MyCoord);
        var Aprime = geo.Coord.new();
        
        # Here is to limit FPS drop on very long distance
        var L = 500;
        if(myDistance > 50000)
        {
            L = myDistance / 15;
        }
        var step = L;
        var maxLoops = int(myDistance / L);
        
        isVisible = 1;
        # This loop will make travel a point between us and the target and check if there is terrain
        for(var i = 0 ; i < maxLoops ; i += 1)
        {
            L = i * step;
            var K = (L * L) / (1 + (-1 / difa) * (-1 / difa) * (difb * difb + difc * difc));
            var DELTA = (-2 * a) * (-2 * a) - 4 * (a * a - K);
            
            if(DELTA >= 0)
            {
                # So 2 solutions or 0 (1 if DELTA = 0 but that 's just 2 solution in 1)
                var x1 = (-(-2 * a) + math.sqrt(DELTA)) / 2;
                var x2 = (-(-2 * a) - math.sqrt(DELTA)) / 2;
                # So 2 y points here
                var y1 = b + (x1 - a) * (difb) / (difa);
                var y2 = b + (x2 - a) * (difb) / (difa);
                # So 2 z points here
                var z1 = c + (x1 - a) * (difc) / (difa);
                var z2 = c + (x2 - a) * (difc) / (difa);
                # Creation Of 2 points
                var Aprime1  = geo.Coord.new();
                Aprime1.set_xyz(x1, y1, z1);
                
                var Aprime2  = geo.Coord.new();
                Aprime2.set_xyz(x2, y2, z2);
                
                # Here is where we choose the good
                if(math.round((myDistance - L), 2) == math.round(Aprime1.direct_distance_to(aircraftPos), 2))
                {
                    Aprime.set_xyz(x1, y1, z1);
                }
                else
                {
                    Aprime.set_xyz(x2, y2, z2);
                }
                var AprimeLat = Aprime.lat();
                var Aprimelon = Aprime.lon();
                var AprimeTerrainAlt = geo.elevation(AprimeLat, Aprimelon);
                if(AprimeTerrainAlt == nil)
                {
                    AprimeTerrainAlt = 0;
                }
                
                if(AprimeTerrainAlt > Aprime.alt())
                {
                    isVisible = 0;
					return;
                }
            }
        }
    }
    else
    {
        isVisible = 1;
    }
    return isVisible;
}