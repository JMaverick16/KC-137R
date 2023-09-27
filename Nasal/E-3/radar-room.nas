
#  ██      ███████ ███████ ████████     ███████  ██████ ██████  ███████ ███████ ███    ██ 
#  ██      ██      ██         ██        ██      ██      ██   ██ ██      ██      ████   ██ 
#  ██      █████   █████      ██        ███████ ██      ██████  █████   █████   ██ ██  ██ 
#  ██      ██      ██         ██             ██ ██      ██   ██ ██      ██      ██  ██ ██ 
#  ███████ ███████ ██         ██        ███████  ██████ ██   ██ ███████ ███████ ██   ████ 
#                                                                                         
#                                                                                         

var colorBackgroundOld = [0.01, 0.105, 0];
var colorBackgroundNew = [0.2, 0.2, 0.4];
var colorGreen = [0.3,1,0.3];
var colorLightGreen = [0.16,0.8,0.13];
var colorBG = [0.4,0.48,0.4];
var colorGrey = [0.5,0.5,0.5];
var colorLightGrey = [0.75,0.75,0.75];
var colorRed = [1,0,0];
var colorLightRed = [1,0.5,0.5];
var colorBlue = [0,0,1];
var colorLightBlue = [0.3,0.3,1];
var colorWhite = [1,1,1];
var colorYellow = [1,1,0];
var colorLightBrown = [0.71,0.40,0.11];

var rdrColorEcho                  = colorLightGrey;#
var rdrColorBackground            = colorBackgroundNew;#
var rdrColorGroundTrack           = colorWhite;
var rdrColorDatalink              = colorLightGreen;#
var rdrColorDatalinkDesignation   = colorLightRed;#
var rdrColorDesignation1          = colorLightGreen;
var rdrColorDesignation2          = colorYellow;
var rdrColorRangeText             = colorGrey;
var rdrColorBorderOutlines        = colorRed;#
#var rdrColorBorderFill            = colorLightBrown;#
var rdrColorIntercept             = colorYellow;
var rdrColorIffFriendly           = colorLightGreen;#
var rdrColorIffUnknown            = colorRed;
var rdrColorCompas                = colorWhite;

var zEcho                  = 10;
var zEchoSweep             = 20;
var zGroundTrack           = 25;
var zDatalink              = 25;
var zDatalinkDesignation   = 25;
var zDesignation1          = 25;
var zDesignation2          = 25;
var zRangeText             = 40;
var zBorderOutlines        =  5;
var zIntercept             = 30;
var zIffFriendly           = 35;
var zIffUnknown            = 36;
var zCompas                = 50;

var interceptTxt = "";

var cursor_pos = [0,0];
var cursor_time = 0;
var cursor_screen = -1;
var cursor_type = 0;

var setCursor = func (x, y, screen, type) {
    cursor_pos = [x*diam - diam*0.5,-y*diam+diam*0.5];
    cursor_time = systime();
    cursor_screen = screen;
    cursor_type = type;
    #printf("slew %d,%d on screen %d", cursor_pos[0],cursor_pos[1],screen+1);
};




RadarScreenLeft = {
    new: func (_ident, root, center, diameter) {
        var rdr1 = {parents: [RadarScreenLeft]};
        var radius = diameter/2;
        rdr1.radius = radius;
        var font = int(0.08*diameter);
        
        rdr1.stroke = 2;
        rdr1.rootCenter = root.createChild("group")
                .setTranslation(center[0],center[1])
                .set("font","B612/B612Mono-Bold.ttf");
        rdr1.outlineGrp = rdr1.rootCenter.createChild("group").set("z-index",zBorderOutlines);

        rdr1.caretLine = rdr1.rootCenter.createChild("path")
           .vert(-radius)
           .setStrokeLineWidth(rdr1.stroke)
           .setStrokeDashArray([25, 50])
           .set("z-index",zEchoSweep)
           .setColor(rdrColorEcho);


        rdr1.maxB = 150;
        rdr1.maxT =  15;
        rdr1.blep = setsize([],rdr1.maxB);
        rdr1.blepTriangle = setsize([],rdr1.maxT);
        rdr1.blepTriangleVel = setsize([],rdr1.maxT);
        rdr1.blepTriangleVelLine = setsize([],rdr1.maxT);
        rdr1.blepTriangleText = setsize([],rdr1.maxT);
        rdr1.blepTrianglePaths = setsize([],rdr1.maxT);
        rdr1.lnk = setsize([],rdr1.maxT);
        rdr1.lnkT = setsize([],rdr1.maxT+1);
        rdr1.lnkTA = setsize([],rdr1.maxT+1);
        rdr1.iff  = setsize([],rdr1.maxT);# friendly IFF response
        rdr1.iffU = setsize([],rdr1.maxT);# unknown IFF response
        for (var i = 0;i<rdr1.maxB;i+=1) {
                rdr1.blep[i] = rdr1.rootCenter.createChild("path")
                        .moveTo(0,0)
                        .vert(1)
                        .setStrokeLineWidth(6)
                        .setStrokeLineCap("round")
                        .set("z-index",zEcho)
                        .hide();
        }
        for (var i = 0;i<rdr1.maxT;i+=1) {
                rdr1.blepTriangle[i] = rdr1.rootCenter.createChild("group")
                                .set("z-index",zGroundTrack);
                rdr1.blepTriangleVel[i] = rdr1.blepTriangle[i].createChild("group");
                rdr1.blepTriangleText[i] = rdr1.blepTriangle[i].createChild("text")
                                .setAlignment("center-top")
                                .setFontSize(20, 1.0)
                                .setTranslation(0,20)
                                .setColor(rdrColorGroundTrack);
                rdr1.blepTriangleVelLine[i] = rdr1.blepTriangleVel[i].createChild("path")
                                .lineTo(0,-10)
                                .setTranslation(0,-16)
                                .setStrokeLineWidth(2)
                                .setColor(rdrColorGroundTrack);
                rdr1.blepTrianglePaths[i] = rdr1.blepTriangle[i].createChild("path")
                                .moveTo(-14,8)
                                .horiz(28)
                                .lineTo(0,-16)
                                .lineTo(-14,8)
                                .setColor(rdrColorGroundTrack)
                                .set("z-index",10)
                                .setStrokeLineWidth(2);
                rdr1.iff[i] = rdr1.rootCenter.createChild("path")
                                .moveTo(-8,0)
                                .arcSmallCW(8,8, 0,  8*2, 0)
                                .arcSmallCW(8,8, 0, -8*2, 0)
                                .setColor(rdrColorIffFriendly)
                                .hide()
                                .set("z-index",zIffFriendly)
                                .setStrokeLineWidth(3);
                rdr1.iffU[i] = rdr1.rootCenter.createChild("path")
                                .moveTo(-8,-8)
                                .vert(16)
                                .horiz(16)
                                .vert(-16)
                                .horiz(-16)
                                .setColor(rdrColorIffUnknown)
                                .hide()
                                .set("z-index",zIffUnknown)
                                .setStrokeLineWidth(3);
                rdr1.lnk[i] = rdr1.rootCenter.createChild("path")
                                .moveTo(-10,-10)
                                .vert(20)
                                .horiz(20)
                                .vert(-20)
                                .horiz(-20)
                                .moveTo(0,-10)
                                .vert(-10)
                                .setColor(rdrColorDatalink)
                                .hide()
                                .set("z-index",zDatalink)
                                .setStrokeLineWidth(3);

            rdr1.lnkT[i] = rdr1.rootCenter.createChild("text")
                .setAlignment("center-bottom")
                .setColor(rdrColorDatalink)
                .set("z-index",zDatalink)
                .setFontSize(20, 1.0);
            rdr1.lnkTA[i] = rdr1.rootCenter.createChild("text")
                                .setAlignment("center-top")
                                .set("z-index",zDatalink)
                                .setFontSize(20, 1.0);
        }
        rdr1.selection = rdr1.rootCenter.createChild("group")
                .set("z-index",zDesignation1);
        rdr1.selectionPath = rdr1.selection.createChild("path")
                .moveTo(-16, 0)
                .arcSmallCW(16, 16, 0, 16*2, 0)
                .arcSmallCW(16, 16, 0, -16*2, 0)
                .setColor(rdrColorDesignation1)
                .setStrokeLineWidth(2);
        rdr1.selection2 = rdr1.rootCenter.createChild("group")
                .set("z-index",zDesignation2);
        rdr1.selection2Path = rdr1.selection2.createChild("path")
                .moveTo(-16, 0)
                .arcSmallCW(16, 16, 0, 16*2, 0)
                .arcSmallCW(16, 16, 0, -16*2, 0)
                .setColor(rdrColorDesignation2)
                .setStrokeLineWidth(2);

        rdr1.lockInfo = rdr1.rootCenter.createChild("text")
                .setTranslation(-diam*0.25*1.5, diam*0.25)
                .setAlignment("left-center")
                .setColor(rdrColorDesignation1)
                .set("z-index",zDesignation1)
                .setFontSize(15, 1.0);
        rdr1.lockInfo2 = rdr1.rootCenter.createChild("text")
                .setTranslation(-diam*0.25*1.5, -diam*0.25)
                .setAlignment("left-center")
                .setColor(rdrColorDesignation2)
                .set("z-index",zDesignation2)
                .setFontSize(15, 1.0);
        rdr1.interceptText = rdr1.rootCenter.createChild("text")
                .setTranslation(-diam*0.25*1.5, diam*0.30)
                .setAlignment("left-center")
                .setColor(rdrColorIntercept)
                .set("z-index",zIntercept)
                .hide()
                .setFontSize(15, 1.0);
        rdr1.rangeInfo = rdr1.rootCenter.createChild("text")
                .setTranslation(-diam*0.25*1.5, diam*0.35)
                .setAlignment("left-center")
                .setColor(rdrColorRangeText)
                .set("z-index",zRangeText)
                .setFontSize(15, 1.0);

        rdr1.interceptCross = rdr1.rootCenter.createChild("path")
                            .moveTo(10,0)
                            .lineTo(-10,0)
                            .moveTo(0,-10)
                            .vert(20)
                            .setColor(rdrColorIntercept)
                            .set("z-index",zIntercept)
                            .setStrokeLineWidth(2);
        var tick_long = radius*0.25;
        var tick_short = tick_long*0.5;
        rdr1.compas1 = rdr1.rootCenter.createChild("path")# minor ticks
           .moveTo(radius*math.cos(30*D2R),radius*math.sin(-30*D2R))
           .lineTo((radius-tick_short)*math.cos(30*D2R),(radius-tick_short)*math.sin(-30*D2R))
           .moveTo(radius*math.cos(15*D2R),radius*math.sin(-15*D2R))
           .lineTo((radius-tick_short)*math.cos(15*D2R),(radius-tick_short)*math.sin(-15*D2R))
           .moveTo(radius*math.cos(45*D2R),radius*math.sin(-45*D2R))
           .lineTo((radius-tick_short)*math.cos(45*D2R),(radius-tick_short)*math.sin(-45*D2R))
           .moveTo(radius*math.cos(60*D2R),radius*math.sin(-60*D2R))
           .lineTo((radius-tick_short)*math.cos(60*D2R),(radius-tick_short)*math.sin(-60*D2R))
           .moveTo(radius*math.cos(75*D2R),radius*math.sin(-75*D2R))
           .lineTo((radius-tick_short)*math.cos(75*D2R),(radius-tick_short)*math.sin(-75*D2R))
           
           .moveTo(radius*math.cos(30*D2R),radius*math.sin(30*D2R))
           .lineTo((radius-tick_short)*math.cos(30*D2R),(radius-tick_short)*math.sin(30*D2R))
           .moveTo(radius*math.cos(15*D2R),radius*math.sin(15*D2R))
           .lineTo((radius-tick_short)*math.cos(15*D2R),(radius-tick_short)*math.sin(15*D2R))
           .moveTo(radius*math.cos(45*D2R),radius*math.sin(45*D2R))
           .lineTo((radius-tick_short)*math.cos(45*D2R),(radius-tick_short)*math.sin(45*D2R))
           .moveTo(radius*math.cos(60*D2R),radius*math.sin(60*D2R))
           .lineTo((radius-tick_short)*math.cos(60*D2R),(radius-tick_short)*math.sin(60*D2R))
           .moveTo(radius*math.cos(75*D2R),radius*math.sin(75*D2R))
           .lineTo((radius-tick_short)*math.cos(75*D2R),(radius-tick_short)*math.sin(75*D2R))

           .moveTo(-radius*math.cos(30*D2R),radius*math.sin(-30*D2R))
           .lineTo(-(radius-tick_short)*math.cos(30*D2R),(radius-tick_short)*math.sin(-30*D2R))
           .moveTo(-radius*math.cos(15*D2R),radius*math.sin(-15*D2R))
           .lineTo(-(radius-tick_short)*math.cos(15*D2R),(radius-tick_short)*math.sin(-15*D2R))
           .moveTo(-radius*math.cos(45*D2R),radius*math.sin(-45*D2R))
           .lineTo(-(radius-tick_short)*math.cos(45*D2R),(radius-tick_short)*math.sin(-45*D2R))
           .moveTo(-radius*math.cos(60*D2R),radius*math.sin(-60*D2R))
           .lineTo(-(radius-tick_short)*math.cos(60*D2R),(radius-tick_short)*math.sin(-60*D2R))
           .moveTo(-radius*math.cos(75*D2R),radius*math.sin(-75*D2R))
           .lineTo(-(radius-tick_short)*math.cos(75*D2R),(radius-tick_short)*math.sin(-75*D2R))
           
           .moveTo(-radius*math.cos(30*D2R),radius*math.sin(30*D2R))
           .lineTo(-(radius-tick_short)*math.cos(30*D2R),(radius-tick_short)*math.sin(30*D2R))
           .moveTo(-radius*math.cos(15*D2R),radius*math.sin(15*D2R))
           .lineTo(-(radius-tick_short)*math.cos(15*D2R),(radius-tick_short)*math.sin(15*D2R))
           .moveTo(-radius*math.cos(45*D2R),radius*math.sin(45*D2R))
           .lineTo(-(radius-tick_short)*math.cos(45*D2R),(radius-tick_short)*math.sin(45*D2R))
           .moveTo(-radius*math.cos(60*D2R),radius*math.sin(60*D2R))
           .lineTo(-(radius-tick_short)*math.cos(60*D2R),(radius-tick_short)*math.sin(60*D2R))
           .moveTo(-radius*math.cos(75*D2R),radius*math.sin(75*D2R))
           .lineTo(-(radius-tick_short)*math.cos(75*D2R),(radius-tick_short)*math.sin(75*D2R))
           .setStrokeLineWidth(rdr1.stroke*1.25)
           .set("z-index",zCompas)
           .setColor(rdrColorCompas);
        rdr1.compas2 = rdr1.rootCenter.createChild("path")# minor ticks
           .moveTo(radius,0)
           .lineTo((radius-tick_long),0)
           
           .moveTo(0,radius)
           .lineTo(0,(radius-tick_long))

           .moveTo(-radius,0)
           .lineTo(-(radius-tick_long),0)
           
           .moveTo(0,-radius)
           .lineTo(0,-(radius-tick_long))

           .moveTo(0,-radius)
           .lineTo(-tick_short,-(radius-tick_short))
           .moveTo(0,-radius)
           .lineTo(tick_short,-(radius-tick_short))

           .setStrokeLineWidth(rdr1.stroke*1)
           .set("z-index",zCompas)
           .setColor(rdrColorCompas);

        rdr1.initOutline();
        return rdr1;
    },
    initOutline: func {
        me.meta = [];
        me.metaCount = 0;
        me.canvasOutlines = {};
        me.zoomOld = 200;
        var filenameMeta = getprop("sim/aircraft-dir")~"/Outlines/world.e3meta";
        var text = nil;
        call(func{text=io.readfile(filenameMeta);},nil, var err = []);
        if (size(err)) {
            print("Border data not detected.");
            return;
        }

        var rings = split("\n",text);
        foreach (var ring; rings) {
            if (size(ring)<4) continue;
            var two = split("*",ring);
            var fileName = two[1];
            var limits = split(",",two[0]);
            var struct = {file:fileName,S:limits[0],N:limits[1],W:limits[2],E:limits[3]};
            append(me.meta, struct);
        }
    },
    testOutline: func {
        if (!size(me.meta)) return;
        me.ring = me.meta[me.metaCount];
        me.myLat = getprop("position/latitude-deg");
        me.myLon = getprop("position/longitude-deg");

        me.ok = 0;

        if (math.abs(me.myLat - me.ring.N) < 7 or math.abs(me.myLat - me.ring.S) < 7 or (me.myLat > me.ring.S and me.myLat < me.ring.N)) {
            if (math.abs(me.myLon - me.ring.W) < 7/math.cos(me.myLat*D2R) or math.abs(me.myLon - me.ring.E) < 7/math.cos(me.myLat*D2R)
                or (me.myLon > me.ring.W and me.myLon < me.ring.E) # inside the country
                or (me.myLon < me.ring.W and me.myLon > me.ring.E and me.ring.W < 0 and me.ring.E > 0 ) # inside USA 1 (W is low)
                or (me.myLon > me.ring.W and me.myLon < me.ring.E and me.ring.W < 0 and me.ring.E > 0 ) # inside USA 2 (W is low)
                ) {
                
                me.loadOutline();
                me.ok = 1;
            }
        }

        if (!me.ok and me.canvasOutlines[me.ring.file] != nil) {
            #print("Unloading outline for ", me.ring.file);
            delete(me.canvasOutlines, me.ring.file);
        }

        me.metaCount += 1;
        if (me.metaCount >= size(me.meta)) {
            me.metaCount = 0;
            #print("Finished checking for outlines to load.");
        }
    },
    loadOutline: func {
        me.ring = me.meta[me.metaCount];
        if (me.canvasOutlines[me.ring.file] != nil) return;
        #print("Loading outline for ", me.ring.file);
        var filenameMeta = getprop("sim/aircraft-dir")~"/Outlines/data/"~me.ring.file;
        me.outlineText = nil;
        call(func{me.outlineText=io.readfile(filenameMeta);},nil, var err = []);
        if (size(err)) {
            print("Loading ",me.ring.file," failed.");
            return;
        }
        me.outline = [];
        me.coords = split("|",me.outlineText);
        foreach (me.coord ; me.coords) {
            if (!size(me.coord)) continue;
            me.coordTexts = split(",",me.coord);
            me.lat = num(me.coordTexts[0]);
            me.lon = num(me.coordTexts[1]);
            me.myCoord = geo.Coord.new().set_latlon(me.lat,me.lon);
            append(me.outline, me.myCoord);
        }
        me.canvasOutlines[me.ring.file] = me.outline;
    },
    paintOutlines: func {
        me.myC = radar_system.self.getCoord();
        #me.myH = radar_system.self.getHeading();
        me.rdrPix = me.radius/(radar_system.apy1Radar.getRange()*NM2M);
        me.outlineGrp.removeAllChildren();
        foreach (me.key ; keys(me.canvasOutlines)) {
            me.p = me.outlineGrp.createChild("path").setColor(rdrColorBorderOutlines).setStrokeLineWidth(me.stroke*0.5);#.setColorFill(rdrColorBorderFill);
            me.first = 1;
            foreach(me.c ; me.canvasOutlines[me.key]) {
                me.distPixels = me.myC.distance_to(me.c)*me.rdrPix;
                me.devy = geo.normdeg180(me.myC.course_to(me.c));
                me.echoPos = me.calcPos(me.devy, me.distPixels);
                if (!me.first) {
                    me.p.lineTo(me.echoPos);
                } else {
                    me.p.moveTo(me.echoPos);
                }
                me.first = 0;
            }
        }
        #me.gspd = math.max(50, getprop("velocities/groundspeed-kt"))/(60*60));

        #timerOutlines.restart(20/me.gspd);# at this speed, when fly 20 nm more we redraw.
        timerOutlines.restart(30);
    },
    rotateOutlines: func {
        me.zoomNew = radar_system.apy1Radar.getRange();

        me.myH = radar_system.self.getHeading();
        me.outlineGrp.setRotation(-me.myH*D2R);

        if (me.zoomNew != me.zoomOld) {
            timerOutlines.restart(0.5);
        }
        me.zoomOld = me.zoomNew;
    },
    paintRdr: func (contact) {
          if (contact["iff"] != nil) {
              if (contact.iff > 0 and me.elapsed-contact.iff < 3.5) {
                  me.myiff = 1;
              } elsif (contact.iff < 0 and me.elapsed+contact.iff < 3.5) {
                  me.myiff = -1;
              } else {
                  me.myiff = 0;
              }
          } else {
              me.myiff = 0;
          }
          me.bleps = contact.getBleps();
          foreach(me.bleppy ; me.bleps) {
              if (me.i < me.maxB and me.elapsed - me.bleppy.getBlepTime() < radar_system.apy1Radar.currentMode.timeToFadeBleps and me.bleppy.getDirection() != nil) {
                  me.distPixels = me.bleppy.getRangeNow()*(me.radius/(radar_system.apy1Radar.getRange()*NM2M));
                  
                  me.echoPos = me.calcPos(geo.normdeg180(me.bleppy.getAZDeviation()), me.distPixels);
#                  me.echoPos = me.calcEXPPos(me.echoPos);
                  if (me.echoPos == nil) {
                      continue;
                  }
                  me.color = math.pow(1-(me.elapsed - me.bleppy.getBlepTime())/radar_system.apy1Radar.currentMode.timeToFadeBleps, 2.2);
                  me.blep[me.i].setTranslation(me.echoPos);
                  me.blep[me.i].setColor(rdrColorEcho[0]*me.color+rdrColorBackground[0]*(1-me.color), rdrColorEcho[1]*me.color+rdrColorBackground[1]*(1-me.color), rdrColorEcho[2]*me.color+rdrColorBackground[2]*(1-me.color));
                  me.blep[me.i].show();
                  me.blep[me.i].update();
                  if (contact.equalsFast(radar_system.apy1Radar.getPriorityTarget()) and me.bleppy == me.bleps[size(me.bleps)-1]) {
                      me.selectShowTemp = math.mod(me.elapsed,0.50)<0.25;#todo
                      me.selectShow = me.selectShowTemp and contact.getType() == radar_system.AIR;
                      me.selection.setTranslation(me.echoPos);
                      me.selection.setColor(rdrColorDesignation1);
                      me.printInfo(contact);
                      me.showLockInfo = 1;
                  } elsif (contact.equalsFast(radar_system.apy1Radar.currentMode.priorityTarget2) and me.bleppy == me.bleps[size(me.bleps)-1]) {
                      me.selectShowTemp = math.mod(me.elapsed,0.50)<0.25;#todo
                      me.selectShow2 = me.selectShowTemp and contact.getType() == radar_system.AIR;
                      me.selection2.setTranslation(me.echoPos);
                      me.selection2.setColor(rdrColorDesignation2);
                      me.printInfo2(contact);
                      me.showLockInfo2 = 1;
                  }
                  if (me.elapsed - me.bleppy.getBlepTime() < radar_system.apy1Radar.currentMode.timeToFadeBleps) {
                      me.calcClick(contact, me.echoPos);
                  }
                  me.i += 1;
              }
          }
          me.sizeBleps = size(me.bleps);
          if (contact["blue"] != 1 and me.ii < me.maxT and ((me.sizeBleps and contact.hadTrackInfo()) or contact["blue"] == 2) and me.myiff == 0) {
              # Paint bleps with tracks
              if (contact["blue"] != 2) me.bleppy = me.bleps[me.sizeBleps-1];
              if (contact["blue"] == 2 or (me.bleppy.hasTrackInfo() and me.elapsed - me.bleppy.getBlepTime() < radar_system.apy1Radar.timeToKeepBleps)) {
                  me.color = contact["blue"] == 2?rdrColorDatalinkDesignation:rdrColorGroundTrack;
                  if (contact["blue"] == 2) {
                      me.c_heading    = contact.getHeading();
                      me.c_devheading = contact.getDeviationHeading();
                      me.c_speed      = contact.getSpeed();
                      me.c_alt        = contact.getAltitude();
                      me.distPixels   = contact.getRange()*(me.radius/(radar_system.apy1Radar.getRange()*NM2M));
                  } else {
                      me.c_heading    = me.bleppy.getHeading();
                      me.c_devheading = me.bleppy.getAZDeviation();
                      me.c_speed      = me.bleppy.getSpeed();
                      me.c_alt        = me.bleppy.getAltitude();
                      me.distPixels   = me.bleppy.getRangeNow()*(me.radius/(radar_system.apy1Radar.getRange()*NM2M));
                  }
                  me.rot = 22.5*math.round((me.c_heading-radar_system.self.getHeading())/22.5);
                  me.blepTrianglePaths[me.ii].setRotation(me.rot*D2R);
                  me.blepTrianglePaths[me.ii].setColor(me.color);
                  me.echoPos = me.calcPos(geo.normdeg180(me.c_devheading), me.distPixels);
  #                me.echoPos = me.calcEXPPos(me.echoPos);
                  if (me.echoPos == nil) {
                      return;
                  }
                  if (contact["blue"] == 2 and me.iii < me.maxT) {
                      me.lnkT[me.iii].setColor(me.color);
                      me.lnkT[me.iii].setTranslation(me.echoPos[0],me.echoPos[1]-25);
                      me.lnkT[me.iii].setText(""~contact.blueIndex);
                      me.lnkT[me.iii].show();
                      me.iii += 1;
                  }
                  me.blepTriangle[me.ii].setTranslation(me.echoPos);
                  if (me.c_speed != nil and me.c_speed > 0) {
                      me.blepTriangleVelLine[me.ii].setScale(1,me.c_speed*0.0045);
                      me.blepTriangleVelLine[me.ii].setColor(me.color);
                      me.blepTriangleVel[me.ii].setRotation(me.rot*D2R);
                      me.blepTriangleVel[me.ii].update();
                      me.blepTriangleVel[me.ii].show();
                  } else {
                      me.blepTriangleVel[me.ii].hide();
                  }
                  if (me.c_alt != nil) {
                      me.blepTriangleText[me.ii].setText(""~math.round(me.c_alt*0.001));
                      me.blepTriangleText[me.ii].setColor(me.color);
                  } else {
                      me.blepTriangleText[me.ii].setText("");
                  }
                  me.blinkShow = 1;#radar_system.apy1Radar.currentMode.longName != radar_system.twsMode.longName or (me.elapsed - contact.getLastBlepTime() < radar_system.F16TWSMode.timeToBlinkTracks) or (math.mod(me.elapsed,0.50)<0.25);
                  if (contact.equalsFast(radar_system.apy1Radar.getPriorityTarget())) {
                      me.selectShow = me.blinkShow and contact.getType() == radar_system.AIR;
                      me.blepTriangle[me.ii].setVisible(me.selectShow);
                      me.selection.setTranslation(me.echoPos);
                      me.selection.setColor(rdrColorDesignation1);
                      me.printInfo(contact);
                      me.showLockInfo = 1;
                  } elsif (contact.equalsFast(radar_system.apy1Radar.currentMode.priorityTarget2)) {
                      me.selectShow2 = me.blinkShow and contact.getType() == radar_system.AIR;
                      me.blepTriangle[me.ii].setVisible(me.selectShow2);
                      me.selection2.setTranslation(me.echoPos);
                      me.selection2.setColor(rdrColorDesignation2);
                      me.printInfo2(contact);
                      me.showLockInfo2 = 1;
                  }
                  me.blepTriangle[me.ii].setVisible(me.blinkShow and contact.getType() == radar_system.AIR);
                  me.blepTriangle[me.ii].update();
                  me.calcClick(contact, me.echoPos);

                  me.ii += 1;
              }
          } elsif (me.myiff != 0 and contact["blue"] != 1 and contact.isVisible() and me.iiii < me.maxT and me.sizeBleps) {
              # Paint IFF symbols
              me.bleppy = me.bleps[me.sizeBleps-1];
              if (me.elapsed - me.bleppy.getBlepTime() < radar_system.apy1Radar.timeToKeepBleps) {
                  me.echoPos = me.calcPos(geo.normdeg180(me.bleppy.getAZDeviation()), me.distPixels);
#                  me.echoPos = me.calcEXPPos(me.echoPos);
                  if (me.echoPos == nil) {
                      return;
                  }
                  me.path = me.myiff == -1?me.iffU[me.iiii]:me.iff[me.iiii];
                  me.pathHide = me.myiff == 1?me.iffU[me.iiii]:me.iff[me.iiii];
                  me.pathHide.hide();
                  me.path.setTranslation(me.echoPos[0],me.echoPos[1]-18);
                  me.path.show();
                  me.iiii += 1;
              }
          }
      },
    paintDL: func (contact) {
        if (contact.blue != 1) return;
        if (contact["iff"] != nil) {
            if (contact.iff > 0 and me.elapsed-contact.iff < 3.5) {
                me.myiff = 1;
            } elsif (contact.iff < 0 and me.elapsed+contact.iff < 3.5) {
                me.myiff = -1;
            } else {
                me.myiff = 0;
            }
        } else {
            me.myiff = 0;
        }

        me.blueBearing = geo.normdeg180(contact.getDeviationHeading());
        if (me.myiff == 0 and contact.isVisible() and contact.getRange()*M2NM < 125 and me.iii < me.maxT and math.abs(me.blueBearing) < 60) {
            me.distPixels = contact.get_range()*(me.radius/(radar_system.apy1Radar.getRange()));
            me.echoPos = me.calcPos(geo.normdeg180(me.blueBearing), me.distPixels);
            if (me.echoPos == nil) {
                return;
            }
            me.lnkT[me.iii].setColor(rdrColorDatalink);
            me.lnkT[me.iii].setTranslation(me.echoPos[0],me.echoPos[1]-25);
            me.lnkT[me.iii].setText(""~contact.blueIndex);
            me.lnkT[me.iii].show();
            me.lnkTA[me.iii].setColor(rdrColorDatalink);
            me.lnkTA[me.iii].setTranslation(me.echoPos[0],me.echoPos[1]+20);
            me.lnkTA[me.iii].setText(""~math.round(contact.getAltitude()*0.001));
            me.lnkTA[me.iii].show();
            me.lnk[me.iii].setColor(rdrColorDatalink);
            me.lnk[me.iii].setTranslation(me.echoPos);
            me.lnk[me.iii].setRotation(D2R*22.5*math.round( geo.normdeg(contact.get_heading()-radar_system.self.getHeading())/22.5 ));#Show rotation in increments of 22.5 deg
            me.lnk[me.iii].show();
            me.lnk[me.iii].update();
            if (contact.equalsFast(radar_system.apy1Radar.getPriorityTarget())) {
                me.selectShow = contact.getType() == radar_system.AIR;
                me.selection.setTranslation(me.echoPos);
                me.selection.setColor(rdrColorDatalink);
                me.printInfo(contact);
            } elsif (contact.equalsFast(radar_system.apy1Radar.currentMode.priorityTarget2)) {
                me.selectShow2 = contact.getType() == radar_system.AIR;
                me.selection.setTranslation(me.echoPos);
                me.selection.setColor(rdrColorDatalink);
                me.printInfo2(contact);
            }
            me.calcClick(contact, me.echoPos);
            me.iii += 1;
        } elsif (me.myiff != 0 and contact.isVisible() and me.iiii < me.maxT) {
            me.distPixels = contact.get_range()*(me.radius/(radar_system.apy1Radar.getRange()));
            me.echoPos = me.calcPos(geo.normdeg180(me.blueBearing), me.distPixels);
            if (me.echoPos == nil) {
                return;
            }
            me.path = me.myiff == -1?me.iffU[me.iiii]:me.iff[me.iiii];
            me.pathHide = me.myiff == 1?me.iffU[me.iiii]:me.iff[me.iiii];
            me.pathHide.hide();
            me.path.setTranslation(me.echoPos[0],me.echoPos[1]-18);
            me.path.show();

            me.iiii += 1;
        }
    },
    calcPos: func (dev, distPixels) {
        me.echoPosition = [distPixels*math.sin(D2R*dev), -distPixels*math.cos(D2R*dev)];
        return me.echoPosition;
    },
    calcClick: func (contact, echoPos) {
        if (cursor_screen != 0) {
            return;
        }
        if (cursor_type == 0) {
          if (math.abs(cursor_pos[0] - echoPos[0]) < 10 and math.abs(cursor_pos[1] - echoPos[1]) < 11) {
              me.desig_new = contact;
          }
        } elsif (cursor_type == 1) {
          if (math.abs(cursor_pos[0] - echoPos[0]) < 10 and math.abs(cursor_pos[1] - echoPos[1]) < 11) {
              me.desig_new2 = contact;
          }
        }
    },
    printInfo: func (contact) {
        if (contact.getLastRangeDirect() != nil) {
            me.azimuth = sprintf("RN%3dNM", contact.getLastRangeDirect()*M2NM);
        } else {
            me.azimuth = "       ";
        }
        if (contact.getLastHeading() != nil) {
            me.magn = geo.normdeg(contact.getLastHeading()+radar_system.self.getHeadingMag()-radar_system.self.getHeading());
            me.heady = sprintf("HEA%3d", int(me.magn/10)*10);
        } else {
            me.heady = "      ";
        }
        if (contact.getLastClosureRate() != 0) {
            me.clos = sprintf("CLO%+5dKT",math.round(contact.getLastClosureRate()*0.1)*10);
        } else {
            me.clos = "         ";
        }
        if (contact.getLastSpeed() != nil) {
            me.spd = sprintf("SPD%4d",contact.getLastSpeed());
        } else {
            me.spd = "       ";
        }

        me.lockInfoText = sprintf("%s: %s %s %s %s", contact.getModel(), me.azimuth, me.heady, me.spd, me.clos);

        me.lockInfo.setText(me.lockInfoText);
        me.showLockInfo = 1;
    },
    printInfo2: func (contact) {
        if (contact.getLastRangeDirect() != nil) {
            me.azimuth = sprintf("RN%3dNM", contact.getLastRangeDirect()*M2NM);
        } else {
            me.azimuth = "       ";
        }
        if (contact.getLastHeading() != nil) {
            me.magn = geo.normdeg(contact.getLastHeading()+radar_system.self.getHeadingMag()-radar_system.self.getHeading());
            me.heady = sprintf("HEA%3d", int(me.magn/10)*10);
        } else {
            me.heady = "      ";
        }
        if (contact.getLastClosureRate() != 0) {
            me.clos = sprintf("CLO%+5dKT",math.round(contact.getLastClosureRate()*0.1)*10);
        } else {
            me.clos = "         ";
        }
        if (contact.getLastSpeed() != nil) {
            me.spd = sprintf("SPD%4d",contact.getLastSpeed());
        } else {
            me.spd = "       ";
        }

        me.lockInfoText = sprintf("%s: %s %s %s %s", contact.getModel(), me.azimuth, me.heady, me.spd, me.clos);

        me.lockInfo2.setText(me.lockInfoText);
        me.showLockInfo2 = 1;
    },
    update: func {
        me.testOutline();
        me.testOutline();
        me.rotateOutlines();
        radar_system.apy1Radar.currentMode.setRange(getprop("instrumentation/mptcas/display-factor-awacs")*400);
        me.caretPosition = radar_system.apy1Radar.getCaretLinePosition();
        me.caretLine.setRotation(me.caretPosition[0]*D2R);#print(me.caretPosition[0]);
        #me.mag_offset = radar_system.self.getHeadingMag() - radar_system.self.getHeading();
        me.compas1.setRotation(-radar_system.self.getHeadingMag()*D2R);
        me.compas2.setRotation(-radar_system.self.getHeadingMag()*D2R);
        me.elapsed = radar_system.elapsedProp.getValue();


        

        me.desig_new = nil;
        me.desig_new2 = nil;
        me.ijk = 0;
        me.intercept = nil;
        me.showDLT = 0;
        me.prio = radar_system.apy1Radar.getPriorityTarget();
        me.tracks = [];
        me.selectShow = 0;
        me.selectShow2 = 0;
        me.showLockInfo = 0;
        me.showLockInfo2 = 0;
        me.i = 0;
        me.ii = 0;
        me.iii = 0;
        me.iiii = 0;
        var callsign = "";
        if (me.prio != nil and me.prio.getCallsign() != nil) callsign = me.prio.getCallsign();
        me.rangeInfo.setText(sprintf("  RANGE: %3d NM      %s", radar_system.apy1Radar.getRange(),callsign));
        me.randoo = rand();
        if (radar_system.datalink_power.getBoolValue()) {
            foreach(contact; vector_aicontacts_links) {
                if (contact["blue"] != 1) continue;
                me.paintDL(contact);
                contact.randoo = me.randoo;
            }
        }
        if (radar_system.apy1Radar.enabled) {
            foreach(var contact; radar_system.apy1Radar.getActiveBleps()) {
                if (contact["randoo"] == me.randoo) continue;

                me.paintRdr(contact);
                contact.randoo = me.randoo;
            }
        }
        if (radar_system.datalink_power.getBoolValue()) {
            foreach(contact; vector_aicontacts_links) {
                me.paintRdr(contact);
                contact.randoo = me.randoo;
            }
        }
        me.selection.setVisible(me.selectShow);
        me.selection2.setVisible(me.selectShow2);
        me.selection.update();
        me.selection2.update();
        me.lockInfo.setVisible(me.showLockInfo);
        me.lockInfo2.setVisible(me.showLockInfo2);
        for (;me.i < me.maxB;me.i+=1) {
            me.blep[me.i].hide();
        }
        for (;me.ii < me.maxT;me.ii+=1) {
            me.blepTriangle[me.ii].hide();
        }
        for (;me.iii < me.maxT;me.iii+=1) {
            me.lnk[me.iii].hide();
            me.lnkT[me.iii].hide();
            me.lnkTA[me.iii].hide();
        }
        for (;me.iiii < me.maxT;me.iiii+=1) {
            me.iff[me.iiii].hide();
            me.iffU[me.iiii].hide();
        }

        #
        # Intercept steering point for designated targets
        #
        if (radar_system.apy1Radar.getPriorityTarget() != nil and radar_system.apy1Radar.currentMode.priorityTarget2 != nil) {
            me.from = radar_system.apy1Radar.getPriorityTarget();
            me.to   = radar_system.apy1Radar.currentMode.priorityTarget2;
            me.lastHead = me.to.getLastHeading();
            me.toSpeed = me.to.getLastSpeed();
            me.fromSpeed = me.from.getLastSpeed();
            if (me.fromSpeed != nil and me.toSpeed != nil and me.fromSpeed != 0 and me.toSpeed != 0 and me.lastHead != nil and me.from.getType() == radar_system.AIR and me.to.getType() == radar_system.AIR) {
                # we cheat a bit here with getting current properties:
                # bearingToRunner_deg, dist_m, runnerHeading_deg, runnerSpeed_mps, chaserSpeed_mps, chaserCoord, chaserHeading
                me.fromCoord = me.from.getLastCoord();
                me.toCoord = me.to.getLastCoord();
                me.bearingToRunner_deg = me.fromCoord.course_to(me.toCoord);
                me.dist_m              = me.fromCoord.distance_to(me.toCoord);

                me.intercept = get_intercept(
                  me.bearingToRunner_deg,
                  me.dist_m,
                  me.lastHead,
                  me.toSpeed*KT2MPS,
                  me.fromSpeed*KT2MPS,
                  me.fromCoord,
                  me.from.getLastHeading());
            }
        }
        if (me.intercept != nil) {
            me.interceptCoord = me.intercept[2];
            #me.interceptDist = me.intercept[3];
            me.fromCoord = radar_system.self.getCoord();
            me.dist_m    = me.fromCoord.distance_to(me.interceptCoord);
            me.course = me.fromCoord.course_to(me.interceptCoord);
            me.distPixels = me.dist_m*M2NM*(me.radius/radar_system.apy1Radar.getRange());
            me.echoPos = me.calcPos(geo.normdeg180(me.course - radar_system.self.getHeading()), me.distPixels);
            me.interceptCross.setTranslation(me.echoPos);
            me.interceptCross.setVisible(1);
            var mag_offset = getprop("/orientation/heading-magnetic-deg") - getprop("/orientation/heading-deg");
            me.txt = sprintf("INTERCEPT: HDG %d MAGN  %.1f MINUTES", geo.normdeg(me.intercept[1]+mag_offset), me.intercept[0]/60);
            interceptTxt = sprintf("INTERCEPT: HDG %d MAGN\n%.1f MINUTES", geo.normdeg(me.intercept[1]+mag_offset), me.intercept[0]/60) ~ sprintf("\n^\nBearing %d\nAt %.1f NM out.", geo.normdeg(me.bearingToRunner_deg+mag_offset), me.dist_m*M2NM);
            me.interceptText.setText(me.txt);
        } elsif (radar_system.apy1Radar.getPriorityTarget() != nil and radar_system.apy1Radar.currentMode.priorityTarget2 != nil) {
            me.interceptText.setText("NO INTERCEPT POSSIBLE");
            me.interceptCross.setVisible(0);
            interceptTxt = "";
        } else {
            me.interceptText.setText("");
            me.interceptCross.setVisible(0);
            interceptTxt = "";
        }

        if (radar_system.apy1Radar.getPriorityTarget() != nil) {
            if (me.elapsed - radar_system.apy1Radar.getPriorityTarget().getLastBlepTime() > 15) {
                radar_system.apy1Radar.currentMode.undesignate();
            }
        }
        if (radar_system.apy1Radar.currentMode.priorityTarget2 != nil) {
            if (me.elapsed - radar_system.apy1Radar.currentMode.priorityTarget2.getLastBlepTime() > 15) {
                radar_system.apy1Radar.currentMode.undesignate();
            }
        }

        if (cursor_screen == 0 and me.desig_new == nil and cursor_type == 0) {
            radar_system.apy1Radar.undesignate();
        } elsif (me.desig_new != nil) {
            radar_system.apy1Radar.designate(me.desig_new);
        }
        if (cursor_screen == 0 and me.desig_new2 == nil and cursor_type == 1) {
            radar_system.apy1Radar.currentMode.undesignate2();
        } elsif (me.desig_new2 != nil) {
            radar_system.apy1Radar.currentMode.designate2(me.desig_new2);
        }
        if (cursor_screen == 0) cursor_screen = -1;
        return;

    },
};




























#  ███    ███ ██ ██████  ██████  ██      ███████     ███████  ██████ ██████  ███████ ███████ ███    ██ 
#  ████  ████ ██ ██   ██ ██   ██ ██      ██          ██      ██      ██   ██ ██      ██      ████   ██ 
#  ██ ████ ██ ██ ██   ██ ██   ██ ██      █████       ███████ ██      ██████  █████   █████   ██ ██  ██ 
#  ██  ██  ██ ██ ██   ██ ██   ██ ██      ██               ██ ██      ██   ██ ██      ██      ██  ██ ██ 
#  ██      ██ ██ ██████  ██████  ███████ ███████     ███████  ██████ ██   ██ ███████ ███████ ██   ████ 
#                                                                                                      
#                                                                                                      


var COLOR_YELLOW     = [1.00,1.00,0.00];
var COLOR_BLUE_LIGHT = [0.50,0.50,1.00];
var COLOR_SKY_LIGHT  = [0.30,0.30,1.00];
var COLOR_RED        = [1.00,0.00,0.00];
var COLOR_WHITE      = [1.00,1.00,1.00];
var COLOR_BROWN      = [0.71,0.40,0.11];
var COLOR_BROWN_DARK = [0.56,0.32,0.09];
var COLOR_GRAY       = [0.25,0.25,0.25,0.50];
var COLOR_GRAY_LIGHT = [0.75,0.75,0.75,0.50];
var COLOR_SKY_DARK   = [0.15,0.15,0.60];
var COLOR_BLACK      = [0.00,0.00,0.00];

var MM2TEX = 2;
var texel_per_degree = 2*MM2TEX;
var KT2KMH = 1.85184;

# map setup

var tile_size = 256;

var type = "light_nolabels";

# index   = zoom level
# content = meter per pixel of tiles
#                   0                             5                               10                               15                      19
var meterPerPixel = [156412,78206,39103,19551,9776,4888,2444,1222,610.984,305.492,152.746,76.373,38.187,19.093,9.547,4.773,2.387,1.193,0.596,0.298];# at equator
var zoomsSEU      = [6, 7, 8, 9, 10, 11, 13];# south europe
var zooms         = zoomsSEU;
var zoomLevels = [320, 160, 80, 40, 20, 10, 2.5];
var zoom_init = 2;
var zoom_curr  = zoom_init;
var zoom = zooms[zoom_curr];

var M2TEX = 1/(meterPerPixel[zoom]*math.cos(getprop('/position/latitude-deg')*D2R));
var maps_base = getprop("/sim/fg-home") ~ '/cache/mapsE3';

# max zoom 18
# light_all,
# dark_all,
# light_nolabels,
# light_only_labels,
# dark_nolabels,
# dark_only_labels

var providers = {
    stamen_terrain_bg: {
                templateLoad: "https://stamen-tiles.a.ssl.fastly.net/terrain-background/{z}/{x}/{y}.png",
                templateStore: "/stamen-bg/{z}/{x}/{y}.png",
                attribution: "Map tiles by Stamen Design"},
    stamen_terrain_ln: {
                templateLoad: "https://stamen-tiles.a.ssl.fastly.net/terrain-lines/{z}/{x}/{y}.png",
                templateStore: "/stamen-ln/{z}/{x}/{y}.png",
                attribution: "Map tiles by Stamen Design"},
    arcgis_terrain: {
                templateLoad: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
                templateStore: "/arcgis/{z}/{y}/{x}.jpg",
                attribution: ""},            
};

var providerOption = 1;
var providerOptionLast = providerOption;
var providerOptions = [
# This one works on Linux and Windows only
["stamen_terrain_bg","stamen_terrain_bg","stamen_terrain_bg","stamen_terrain_bg","stamen_terrain_bg","stamen_terrain_bg","arcgis_terrain"],
# This one works on MacOS also, so is default
["arcgis_terrain","arcgis_terrain","arcgis_terrain","arcgis_terrain","arcgis_terrain","arcgis_terrain","arcgis_terrain"]
];

var zoom_provider = providerOptions[providerOption];

var makeUrl   = string.compileTemplate(providers[zoom_provider[zoom_curr]].templateLoad);
#var makeUrl   = string.compileTemplate('https://cartodb-basemaps-c.global.ssl.fastly.net/{type}/{z}/{x}/{y}.png');
#var makePath  = string.compileTemplate(maps_base ~ '/cartoL/{z}/{x}/{y}.png');
var makePath  = string.compileTemplate(maps_base ~ providers[zoom_provider[zoom_curr]].templateStore);
var num_tiles = [7, 7];# must be uneven, 7x7 will ensure we never see edge of map tiles when canvas is 1024px high.

var center_tile_offset = [(num_tiles[0] - 1) / 2,(num_tiles[1] - 1) / 2];#(width/tile_size)/2,(height/tile_size)/2];


var tiles = setsize([], num_tiles[0]);


var last_tile = [-1,-1];
var last_type = type;
var last_zoom = zoom;
var lastLiveMap = 1;#getprop("f16/displays/live-map");
var lastDay   = 1;

var CLEANMAP = 0;
var PLACES   = 1;

var COLOR_DAY   = "rgb(255,255,255)";#"rgb(128,128,128)";# color fill behind map which will modulate to make it darker.
var COLOR_NIGHT = "rgb(128,128,128)";

var lineWidth = {
    bullseye: 5,
    rangeRings: 8,
    ownship: 4,
    rangeArrows: 4,
    radarCone: 3,
    threatRings: 4,
    lines: 2,
    route: 3,
    pfd: 4,
    grid: 3,
    targets: 2,
    targetsDL: 3,
    gpsSpot: 5,
    crashCross: 12,
};

var font = {
    range: 30,
    pfdLadder: 20,
    pfdTapes: 20,
    ehsiExt: 45,
    attribution: 30,
    threatRings: 25,
    grid: 14,
    targets: 25,
    markpoints: 25,
    power: 25,
};

var symbolSize = {
    contacts: 112,
    bullseye: 50,
    gpsSpot: 25,
    ownship: 30,
};

var layer_z = {
    # How things are layered on top of each other, higher numbers are on top of lower numbers.
    display: {
        map: 1,
        mapOverlay: 7,
        buttonSymbols: 9,
        buttonSymbolsTop: 25,
        pfd: 20,
        pfdSky: 19,
        ehsi: 20,
        ehsiExt: 18,
        hud: 20,
        hud_bg: 19,
        attribution: 70,
        crashCross: 100,
        power: 20,
    },
    map: {
        tiles: 1,
        targets: 11,
        markpoints: 10,
        lines_and_route: 8,
        threatRings: 4,
        grid: 2,
        gridText: 3,
    },
    mapOverlay: {
        ownship: 10,
        radarCone: 11,
        rangeRings: 7,
    },
};

RadarScreenMiddle = {
    new: func (_ident, root2, center, diameter) {
        var rdr2 = {parents: [RadarScreenMiddle]};
        var radius = diameter/2;
        rdr2.radius = radius;

        # needed for map
        rdr2.canvasX = diameter;
        rdr2.canvasY = diameter;
        me.root = root2;

        return rdr2;
    },

    start: func {
        me.setupInstr();
        me.setupVariables();
        me.calcGeometry();
        me.calcZoomLevels();
        me.initMap();
        me.setupProperties();# before setup map
        me.setupMap();
        me.setupGrid();# after setupgrid
        #me.setupFunctions();#before symbols
        me.setupAttr();
        
        me.loadedCDU = 1;
    },

    update: func {
        if (!me.loadedCDU) {
            print("Unloaded CDU Looping");
            return;
        }
        if (me.day) {
            cv2.setColorBackground(0.3, 0.3, 0.3, 1.0);
        } else {
            cv2.setColorBackground(0.15, 0.15, 0.15, 1.0);
        }

        me.selfCoord = geo.aircraft_position();

        me.ownPosition = me.defaultOwnPosition;
        me.zoomAdjust();
        me.whereIsMap();
        me.updateMap();
        me.updateGrid();
        me.updateAttr();
        #print("CDU Looping ",me.loadedCDU);
    },

    setupVariables: func {
        me.mapShowPlaces = 1;
        me.mapSelfCentered = 1;
        me.day = 1;
        me.mapShowGrid = 0;
    },

    calcGeometry: func {
        me.max_x = me.canvasX;
        me.max_y = me.canvasY;
        me.defaultOwnPosition = 0.5 * me.max_y;
        me.ownPosition = me.defaultOwnPosition;
    },

    calcZoomLevels: func {
        me.M2TEXinit = 1/(meterPerPixel[zoomsSEU[zoom_init]]*math.cos(getprop('/position/latitude-deg')*D2R));
        if (zoomLevels[zoom_init]*NM2M*me.M2TEXinit > me.defaultOwnPosition * 2) {
            #print("Reduce zoom x4");
            forindex (var zoomLvl ; zoomLevels) {
                zooms[zoomLvl] = zoomsSEU[zoomLvl]-2;
            }
        } elsif (zoomLevels[zoom_init]*NM2M*me.M2TEXinit > me.defaultOwnPosition) {
            #print("Reduce zoom x2");
            forindex (var zoomLvl ; zoomLevels) {
                zooms[zoomLvl] = zoomsSEU[zoomLvl]-1;
            }
        } elsif (zoomLevels[zoom_init]*NM2M*me.M2TEXinit < me.defaultOwnPosition * 0.5) {
            #print("Increase zoom x2");
            forindex (var zoomLvl ; zoomLevels) {
                zooms[zoomLvl] = zoomsSEU[zoomLvl]+1;
            }
        } elsif (zoomLevels[zoom_init]*NM2M*me.M2TEXinit < me.defaultOwnPosition * 0.25) {
            #print("Increase zoom x4");
            forindex (var zoomLvl ; zoomLevels) {
                zooms[zoomLvl] = zoomsSEU[zoomLvl]+2;
            }
        }
        me.M2TEXinit = 1/(meterPerPixel[zooms[zoom_init]]*math.cos(getprop('/position/latitude-deg')*D2R));
    },

    setupProperties: func {
        me.input = {
            alt_ft:               "instrumentation/altimeter/indicated-altitude-ft",
            alt_true_ft:          "position/altitude-ft",
            #heading:              "instrumentation/heading-indicator/indicated-heading-deg",
            heading:              "orientation/heading-deg",
            radarStandby:         "instrumentation/radar/radar-standby",
            rad_alt:              "instrumentation/radar-altimeter/radar-altitude-ft",
            rad_alt_ready:        "instrumentation/radar-altimeter/ready",
            rmActive:             "autopilot/route-manager/active",
            rmDist:               "autopilot/route-manager/wp/dist",
            rmId:                 "autopilot/route-manager/wp/id",
            rmBearing:            "autopilot/route-manager/wp/true-bearing-deg",
            RMCurrWaypoint:       "autopilot/route-manager/current-wp",
            roll:                 "instrumentation/attitude-indicator/indicated-roll-deg",
            timeElapsed:          "sim/time/elapsed-sec",
            headTrue:             "orientation/heading-deg",
            fpv_up:               "instrumentation/fpv/angle-up-deg",
            fpv_right:            "instrumentation/fpv/angle-right-deg",
            roll:                 "orientation/roll-deg",
            pitch:                "orientation/pitch-deg",
            radar_serv:           "instrumentation/radar/serviceable",
            nav0InRange:          "instrumentation/nav[0]/in-range",
            APLockHeading:        "autopilot/locks/heading",
            APTrueHeadingErr:     "autopilot/internal/true-heading-error-deg",
            APnav0HeadingErr:     "autopilot/internal/nav1-heading-error-deg",
            APHeadingBug:         "autopilot/settings/heading-bug-deg",
            RMActive:             "autopilot/route-manager/active",
            nav0Heading:          "instrumentation/nav[0]/heading-deg",
            ias:                  "instrumentation/airspeed-indicator/indicated-speed-kt",
            tas:                  "instrumentation/airspeed-indicator/true-speed-kt",
            wow0:                 "fdm/jsbsim/gear/unit[0]/WOW",
            wow1:                 "fdm/jsbsim/gear/unit[1]/WOW",
            wow2:                 "fdm/jsbsim/gear/unit[2]/WOW",
            gearsPos:             "gear/gear/position-norm",
            latitude:             "position/latitude-deg",
            longitude:            "position/longitude-deg",
            elevCmd:              "fdm/jsbsim/fcs/elevator-cmd-norm",
            ailCmd:               "fdm/jsbsim/fcs/aileron-cmd-norm",
            instrNorm:            "controls/lighting/instruments-norm",
            linker:               "sim/va"~"riant-id",
            datalink:             "/instrumentation/datalink/on",
            weight:               "fdm/jsbsim/inertia/weight-lbs",
            max_approach_alpha:   "fdm/jsbsim/systems/flight/approach-alpha-base",
            calibrated:           "fdm/jsbsim/velocities/vc-kts",
            mach:                 "instrumentation/airspeed-indicator/indicated-mach",
            inhg:                 "instrumentation/altimeter/setting-inhg",
            alphaI:               "fdm/jsbsim/fcs/fly-by-wire/pitch/alpha-indicated",
            tacanCh:              "instrumentation/tacan/display/channel",
            ilsCh:                "instrumentation/nav[0]/frequencies/selected-mhz",
            crashSec:             "instrumentation/radar/time-till-crash",
            powerNonEssAc1:       "fdm/jsbsim/elec/bus/noness-ac-1",
            powerEmrgAc1:         "fdm/jsbsim/elec/bus/emergency-ac-1",
            powerNonEssAc2:       "fdm/jsbsim/elec/bus/noness-ac-2",
            powerEssAc:           "fdm/jsbsim/elec/bus/ess-ac",
            powerEmrgAc2:         "fdm/jsbsim/elec/bus/emergency-ac-2",
            powerNcNonEssAc:      "fdm/jsbsim/elec/bus/nacelle-noness-ac",
            powerNcEssAc:         "fdm/jsbsim/elec/bus/nacelle-ess-ac",
            powerEmrgDc1:         "fdm/jsbsim/elec/bus/emergency-dc-1",
            powerNonEssDc:        "fdm/jsbsim/elec/bus/noness-dc",
            powerEmrgDc2:         "fdm/jsbsim/elec/bus/emergency-dc-2",
            powerEssDc:           "fdm/jsbsim/elec/bus/ess-dc",
            powerBatt1:           "fdm/jsbsim/elec/bus/batt-1",
            powerBatt2:           "fdm/jsbsim/elec/bus/batt-2",
            powerNcNonEssDc1:     "fdm/jsbsim/elec/bus/nacelle-noness-dc-1",
            powerNcNonEssDc2:     "fdm/jsbsim/elec/bus/nacelle-noness-dc-2",
            powerHydrA:           "fdm/jsbsim/systems/hydraulics/sysa-psi",
            powerHydrB:           "fdm/jsbsim/systems/hydraulics/sysb-psi",
            servSpeed                 : "instrumentation/airspeed-indicator/serviceable",
            servStatic                : "systems/static/serviceable",
            servPitot                 : "systems/pitot/serviceable",
            servAtt                   : "instrumentation/attitude-indicator/serviceable",
            servHead                  : "instrumentation/heading-indicator/serviceable",
            servTurn                  : "instrumentation/turn-indicator/serviceable",
        };

        foreach(var name; keys(me.input)) {
            me.input[name] = props.globals.getNode(me.input[name], 1);
        }
    },


#  ███████ ██    ██ ███    ██  ██████ ████████ ██  ██████  ███    ██ ███████ 
#  ██      ██    ██ ████   ██ ██         ██    ██ ██    ██ ████   ██ ██      
#  █████   ██    ██ ██ ██  ██ ██         ██    ██ ██    ██ ██ ██  ██ ███████ 
#  ██      ██    ██ ██  ██ ██ ██         ██    ██ ██    ██ ██  ██ ██      ██ 
#  ██       ██████  ██   ████  ██████    ██    ██  ██████  ██   ████ ███████ 
#                                                                            
#                                                                            
    setupInstr: func {
        me.instrView = 0;
        me.instrConf = [
            {descr: "MAP", showMap: 1, ehsiScale: 1/1.25, showEhsi: 0, showPfd: 0, ehsiPosX: 0, ehsiPosY: 0, showExtEhsi: 0, showHud: 0, showPower: 0},
        ];
    },

    toggleDay: func {
        me.day = !me.day;
    },

    toggleGrid: func {
        if (!me.instrConf[me.instrView].showMap) return;
        me.mapShowGrid = !me.mapShowGrid;
    },

    toggleHdgUp: func {
        if (!me.instrConf[me.instrView].showMap) return;
        me.hdgUp = !me.hdgUp;
    },

    toggleMAP: func {
        if (!me.instrConf[me.instrView].showMap) return;
        providerOption += 1;
        if (providerOption > 1) providerOption = 0;
        zoom_provider = providerOptions[providerOption];
        me.changeProvider();
    },

    setupAttr: func {
        me.attrText = me.root.createChild("text")
            .set("z-index",layer_z.display.attribution)
            .setColor(COLOR_WHITE)
            .setFontSize(font.attribution, 1.0)
            .setText("")
            .setAlignment("center-center")
            .setTranslation(me.max_x*0.5,me.max_y*0.5)
            ;#.setFont("NotoMono-Regular.ttf");
    },

    updateAttr: func {
        # every once in a while display attribution for 4 seconds.
        if (math.mod(int(me.input.timeElapsed.getValue()*0.25), 120) == 0 and providers[zoom_provider[zoom_curr]].attribution != "") {
            me.attrText.setText(providers[zoom_provider[zoom_curr]].attribution);
            me.attrText.setVisible(1);
        } else {
            me.attrText.setText(interceptTxt);
            me.attrText.setVisible(interceptTxt != "");
        }
    },

    zoomAdjust: func() {
        if (!me.instrConf[me.instrView].showMap) return;
        var rng = radar_system.apy1Radar.getRange();

        if (rng > 320) zoom_curr = 0;
        elsif (rng > 160) zoom_curr = 1;
        elsif (rng >  80) zoom_curr = 2;
        elsif (rng >  40) zoom_curr = 3;
        elsif (rng >  20) zoom_curr = 4;
        else zoom_curr = 5;

        zoom = zooms[zoom_curr];
        M2TEX = 1/(meterPerPixel[zoom]*math.cos(getprop('/position/latitude-deg')*D2R));

        me.changeProvider();
    },

    zoomIn: func() {
        if (!me.instrConf[me.instrView].showMap) return;
        zoom_curr += 1;
        if (zoom_curr >= size(zooms)) {
            zoom_curr = size(zooms)-1;
            return;
            zoom_curr = 0;
        }
        zoom = zooms[zoom_curr];
        M2TEX = 1/(meterPerPixel[zoom]*math.cos(getprop('/position/latitude-deg')*D2R));
        me.setRangeInfo();
        me.changeProvider();
    },

    zoomOut: func() {
        if (!me.instrConf[me.instrView].showMap) return;
        zoom_curr -= 1;
        if (zoom_curr < 0) {
            zoom_curr = 0;
            return;
            zoom_curr = 4;
        }
        zoom = zooms[zoom_curr];
        M2TEX = 1/(meterPerPixel[zoom]*math.cos(getprop('/position/latitude-deg')*D2R));
        me.setRangeInfo();
        me.changeProvider();
    },

    changeProvider: func {
        makeUrl   = string.compileTemplate(providers[zoom_provider[zoom_curr]].templateLoad);
        makePath  = string.compileTemplate(maps_base ~ providers[zoom_provider[zoom_curr]].templateStore);
    },

    laloToTexel: func (la, lo) {
        me.coord = geo.Coord.new();
        me.coord.set_latlon(la, lo);
        me.coordSelf = geo.Coord.new();#TODO: dont create this every time method is called
        me.coordSelf.set_latlon(me.lat_own, me.lon_own);
        me.angle = (me.coordSelf.course_to(me.coord)-me.input.heading.getValue())*D2R;
        me.pos_xx        = -me.coordSelf.distance_to(me.coord)*M2TEX * math.cos(me.angle + math.pi/2);
        me.pos_yy        = -me.coordSelf.distance_to(me.coord)*M2TEX * math.sin(me.angle + math.pi/2);
        return [me.pos_xx, me.pos_yy];#relative to rootCenter
    },
    
    laloToTexelMap: func (la, lo) {
        me.coord = geo.Coord.new();
        me.coord.set_latlon(la, lo);
        me.coordSelf = geo.Coord.new();#TODO: dont create this every time method is called
        me.coordSelf.set_latlon(me.lat, me.lon);
        me.angle = (me.coordSelf.course_to(me.coord))*D2R;
        me.pos_xx        = -me.coordSelf.distance_to(me.coord)*M2TEX * math.cos(me.angle + math.pi/2);
        me.pos_yy        = -me.coordSelf.distance_to(me.coord)*M2TEX * math.sin(me.angle + math.pi/2);
        return [me.pos_xx, me.pos_yy];#relative to mapCenter
    },

    TexelToLaLoMap: func (x,y) {#relative to map center
        x /= M2TEX;
        y /= M2TEX;
        me.mDist  = math.sqrt(x*x+y*y);
        if (me.mDist == 0) {
            return [me.lat, me.lon];
        }
        me.acosInput = clamp(x/me.mDist,-1,1);
        if (y<0) {
            me.texAngle = math.acos(me.acosInput);#unit circle on TI
        } else {
            me.texAngle = -math.acos(me.acosInput);
        }
        #printf("%d degs %0.1f NM", me.texAngle*R2D, me.mDist*M2NM);
        me.texAngle  = -me.texAngle*R2D+90;#convert from unit circle to heading circle, 0=up on display
        me.headAngle = me.input.heading.getValue()+me.texAngle;#bearing
        #printf("%d bearing   %d rel bearing", me.headAngle, me.texAngle);
        me.coordSelf = geo.Coord.new();#TODO: dont create this every time method is called
        me.coordSelf.set_latlon(me.lat, me.lon);
        me.coordSelf.apply_course_distance(me.headAngle, me.mDist);

        return [me.coordSelf.lat(), me.coordSelf.lon()];
    },


#   ██████  ██████  ██ ██████  
#  ██       ██   ██ ██ ██   ██ 
#  ██   ███ ██████  ██ ██   ██ 
#  ██    ██ ██   ██ ██ ██   ██ 
#   ██████  ██   ██ ██ ██████  
#                              
#                              
    setupGrid: func {
        me.gridGroup = me.mapCenter.createChild("group")
            .set("z-index", layer_z.map.grid);
        me.gridGroupText = me.mapCenter.createChild("group")
            .set("z-index", layer_z.map.gridText);
        me.last_lat = 0;
        me.last_lon = 0;
        me.last_range = 0;
        me.last_result = 0;
        me.gridTextO = [];
        me.gridTextA = [];
        me.gridTextMaxA = -1;
        me.gridTextMaxO = -1;
    },

    updateGrid: func {
        #line finding algorithm taken from $fgdata mapstructure:
        var lines = [];
        if (!me.mapShowGrid) {
            me.gridGroup.hide();
            me.gridGroupText.hide();
            return;
        }
        if (zoomLevels[zoom_curr] == 160) {
            me.granularity_lon = 2;
            me.granularity_lat = 2;
        } elsif (zoomLevels[zoom_curr] == 80) {
            me.granularity_lon = 1;
            me.granularity_lat = 1;
        } elsif (zoomLevels[zoom_curr] == 40) {
            me.granularity_lon = 0.5;
            me.granularity_lat = 0.5;
        } elsif (zoomLevels[zoom_curr] == 20) {
            me.granularity_lon = 0.25;
            me.granularity_lat = 0.25;
        } else {
            me.gridGroup.hide();
            me.gridGroupText.hide();
            return;
        }
        
        var delta_lon = me.granularity_lon;
        var delta_lat = me.granularity_lat;

        # Find the nearest lat/lon line to the map position.  If we were just displaying
        # integer lat/lon lines, this would just be rounding.
        
        var lat = delta_lat * math.round(me.lat / delta_lat);
        var lon = delta_lon * math.round(me.lon / delta_lon);
        
        var range = 0.75*me.max_y*M2NM/M2TEX;#simplified
        #printf("grid range=%d %.3f %.3f",range,me.lat,me.lon);

        # Return early if no significant change in lat/lon/range - implies no additional
        # grid lines required
        if ((lat == me.last_lat) and (lon == me.last_lon) and (range == me.last_range)) {
            lines = me.last_result;
        } else {

            # Determine number of degrees of lat/lon we need to display based on range
            # 60nm = 1 degree latitude, degree range for longitude is dependent on latitude.
            var lon_range = 1;
            call(func{lon_range = geo.Coord.new().set_latlon(lat,lon,me.input.alt_ft.getValue()*FT2M).apply_course_distance(90.0, range*NM2M).lon() - lon;},nil, var err=[]);
            #courseAndDistance
            if (size(err)) {
                #printf("fail lon %.7f  lat %.7f  ft %.2f  ft %.2f",lon,lat,me.input.alt_ft.getValue(),range*NM2M);
                # typically this fail close to poles. Floating point exception in geo asin.
            }
            var lat_range = range/60.0;

            lon_range = delta_lon * math.ceil(lon_range / delta_lon);
            lat_range = delta_lat * math.ceil(lat_range / delta_lat);

            lon_range = math.clamp(lon_range,delta_lon,250);
            lat_range = math.clamp(lat_range,delta_lat,250);
            
            #printf("range lon %f  lat %f",lon_range,lat_range);
            for (var x = (lon - lon_range); x <= (lon + lon_range); x += delta_lon) {
                var coords = [];
                if (x>180) {
                #   x-=360;
                    continue;
                } elsif (x<-180) {
                #   x+=360;
                    continue;
                }
                # We could do a simple line from start to finish, but depending on projection,
                # the line may not be straight.
                for (var y = (lat - lat_range); y <= (lat + lat_range); y +=  delta_lat) {
                    append(coords, {lon:x, lat:y});
                }
                var ddLon = math.round(math.fmod(abs(x), 1.0) * 60.0);
                append(lines, {
                    id: x,
                    type: "lon",
                    text1: sprintf("%4d",int(x)),
                    text2: ddLon==0?"":ddLon~"",
                    path: coords,
                    equals: func(o){
                        return (me.id == o.id and me.type == o.type); # We only display one line of each lat/lon
                    }
                });
            }
            
            # Lines of latitude
            for (var y = (lat - lat_range); y <= (lat + lat_range); y += delta_lat) {
                var coords = [];
                if (y>90 or y<-90) continue;
                # We could do a simple line from start to finish, but depending on projection,
                # the line may not be straight.
                for (var x = (lon - lon_range); x <= (lon + lon_range); x += delta_lon) {
                    append(coords, {lon:x, lat:y});
                }

                var ddLat = math.round(math.fmod(abs(y), 1.0) * 60.0);
                append(lines, {
                    id: y,
                    type: "lat",
                    text: str(int(y))~(ddLat==0?"   ":" "~ddLat),
                    path: coords,
                    equals: func(o){
                        return (me.id == o.id and me.type == o.type); # We only display one line of each lat/lon
                    }
                });
            }
#printf("range %d  lines %d",range, size(lines));
        }
        me.last_result = lines;
        me.last_lat = lat;
        me.last_lon = lon;
        me.last_range = range;
        
        
        me.gridGroup.removeAllChildren();
        #me.gridGroupText.removeAllChildren();
        me.gridTextNoA = 0;
        me.gridTextNoO = 0;
        me.gridH = me.max_y*0.80;
        foreach (var line;lines) {
            var skip = 1;
            me.posi1 = [];
            foreach (var coord;line.path) {
                if (!skip) {
                    me.posi2 = me.laloToTexelMap(coord.lat,coord.lon);
                    me.aline.lineTo(me.posi2);
                    if (line.type=="lon") {
                        var arrow = [(me.posi1[0]*4+me.posi2[0])/5,(me.posi1[1]*4+me.posi2[1])/5];
                        me.aline.moveTo(arrow);
                        me.aline.lineTo(arrow[0]-7,arrow[1]+10);
                        me.aline.moveTo(arrow);
                        me.aline.lineTo(arrow[0]+7,arrow[1]+10);
                        me.aline.moveTo(me.posi2);
                        if (me.posi2[0]<me.gridH and me.posi2[0]>-me.gridH and me.posi2[1]<me.gridH and me.posi2[1]>-me.gridH) {
                            # sadly when zoomed in alot it draws too many crossings, this condition should help
                            me.setGridTextO(line.text1,[me.posi2[0]-20,me.posi2[1]+5]);
                            if (line.text2 != "") {
                                me.setGridTextO(line.text2,[me.posi2[0]+12,me.posi2[1]+5]);
                            }
                        }
                    } else {
                        me.posi3 = [(me.posi1[0]+me.posi2[0])*0.5, (me.posi1[1]+me.posi2[1])*0.5-5];
                        if (me.posi3[0]<me.gridH and me.posi3[0]>-me.gridH and me.posi3[1]<me.gridH and me.posi3[1]>-me.gridH) {
                            # sadly when zoomed in alot it draws too many crossings, this condition should help
                            me.setGridTextA(line.text,me.posi3);
                        }
                    }
                    me.posi1=me.posi2;
                } else {
                    me.posi1 = me.laloToTexelMap(coord.lat,coord.lon);
                    me.aline = me.gridGroup.createChild("path")
                        .moveTo(me.posi1)
                        .setStrokeLineWidth(lineWidth.grid)
                        .setColor(COLOR_YELLOW);
                }
                skip = 0;
            }
        }
        for (me.jjjj = me.gridTextNoO;me.jjjj<=me.gridTextMaxO;me.jjjj+=1) {
            me.gridTextO[me.jjjj].hide();
        }
        for (me.kkkk = me.gridTextNoA;me.kkkk<=me.gridTextMaxA;me.kkkk+=1) {
            me.gridTextA[me.kkkk].hide();
        }
        me.gridGroupText.update();
        me.gridGroup.update();
        me.gridGroupText.show();
        me.gridGroup.show();
    },

    setGridTextO: func (text, pos) {
        if (me.gridTextNoO > me.gridTextMaxO) {
                append(me.gridTextO,me.gridGroupText.createChild("text")
                        .setText(text)
                        .setColor(COLOR_YELLOW)
                        .setAlignment("center-top")
                        .setTranslation(pos)
                        .setFontSize(font.grid, 1));
            me.gridTextMaxO += 1;   
        } else {
            me.gridTextO[me.gridTextNoO].setText(text).setTranslation(pos);
        }
        me.gridTextO[me.gridTextNoO].show();
        me.gridTextNoO += 1;
    },
    
    setGridTextA: func (text, pos) {
        if (me.gridTextNoA > me.gridTextMaxA) {
                append(me.gridTextA,me.gridGroupText.createChild("text")
                        .setText(text)
                        .setColor(COLOR_YELLOW)
                        .setAlignment("center-bottom")
                        .setTranslation(pos)
                        .setFontSize(font.grid, 1));
            me.gridTextMaxA += 1;   
        } else {
            me.gridTextA[me.gridTextNoA].setText(text).setTranslation(pos);
        }
        me.gridTextA[me.gridTextNoA].show();
        me.gridTextNoA += 1;
    },

#  ███    ███  █████  ██████  
#  ████  ████ ██   ██ ██   ██ 
#  ██ ████ ██ ███████ ██████  
#  ██  ██  ██ ██   ██ ██      
#  ██      ██ ██   ██ ██      
#                             
#                             
    initMap: func {
        # map groups
        me.mapCentrum = me.root.createChild("group")
            .set("z-index", layer_z.display.map)
            .setTranslation(me.max_x*0.5,me.max_y*0.5);
        me.mapCenter = me.mapCentrum.createChild("group");
        me.mapRot = me.mapCenter.createTransform();
        me.mapFinal = me.mapCenter.createChild("group")
            .set("z-index",  layer_z.map.tiles);
        me.rootCenter = me.root.createChild("group")
            .setTranslation(me.max_x/2,me.max_y/2)
            .set("z-index",  layer_z.display.mapOverlay);

        me.hdgUp = 1;
    },

    updateMapNames: func {
        if (me.mapShowPlaces) {
            type = "light_all";
            makePath = string.compileTemplate(maps_base ~ '/cartoLN/{z}/{x}/{y}.png');
        } else {
            type = "light_nolabels";
            makePath = string.compileTemplate(maps_base ~ '/cartoL/{z}/{x}/{y}.png');
        }
    },

    setupMap: func {
        me.mapFinal.removeAllChildren();
        for(var x = 0; x < num_tiles[0]; x += 1) {
            tiles[x] = setsize([], num_tiles[1]);
            for(var y = 0; y < num_tiles[1]; y += 1) {
                tiles[x][y] = me.mapFinal.createChild("image", sprintf("map-tile-%03d-%03d",x,y)).set("z-index", 15);#.set("size", "256,256");
                if (me.day == 1) {
                    tiles[x][y].set("fill", COLOR_DAY);
                } else {
                    tiles[x][y].set("fill", COLOR_NIGHT);
                }
            }
        }
    },

    whereIsMap: func {
        # update the map position
        me.lat_own = me.input.latitude.getValue();
        me.lon_own = me.input.longitude.getValue();
        if (me.mapSelfCentered) {
            # get current position
            me.lat = me.lat_own;
            me.lon = me.lon_own;# TODO: USE GPS/INS here.
        }       
        M2TEX = 1/(meterPerPixel[zoom]*math.cos(me.lat*D2R));
    },

    updateMap: func {
        me.rootCenter.setVisible(me.instrConf[me.instrView].showMap);
        me.mapCentrum.setVisible(me.instrConf[me.instrView].showMap);
        if (!me.instrConf[me.instrView].showMap) {
            return;
        }
        # update the map
        if (lastDay != me.day or providerOptionLast != providerOption)  {
            me.setupMap();
        }
        me.rootCenterY = me.ownPosition;#me.canvasY*0.875-(me.canvasY*0.875)*me.ownPosition;
        if (!me.mapSelfCentered) {
            me.lat_wp   = me.input.latitude.getValue();
            me.lon_wp   = me.input.longitude.getValue();
            me.tempReal = me.laloToTexel(me.lat,me.lon);
            me.rootCenter.setTranslation(me.max_x/2-me.tempReal[0], me.rootCenterY-me.tempReal[1]);
            #me.rootCenterTranslation = [width/2-me.tempReal[0], me.rootCenterY-me.tempReal[1]];
        } else {
            me.tempReal = [0,0];
            me.rootCenter.setTranslation(me.max_x/2, me.rootCenterY);
            #me.rootCenterTranslation = [width/2, me.rootCenterY];
        }
        me.mapCentrum.setTranslation(me.max_x/2, me.rootCenterY);

        me.n = math.pow(2, zoom);
        me.center_tile_float = [
            me.n * ((me.lon + 180) / 360),
            (1 - math.ln(math.tan(me.lat * D2R) + 1 / math.cos(me.lat * D2R)) / math.pi) / 2 * me.n
        ];
        # center_tile_offset[1]
        me.center_tile_int = [math.floor(me.center_tile_float[0]), math.floor(me.center_tile_float[1])];

        me.center_tile_fraction_x = me.center_tile_float[0] - me.center_tile_int[0];
        me.center_tile_fraction_y = me.center_tile_float[1] - me.center_tile_int[1];
        #printf("\ncentertile: %d,%d fraction %.2f,%.2f",me.center_tile_int[0],me.center_tile_int[1],me.center_tile_fraction_x,me.center_tile_fraction_y);
        me.tile_offset = [math.floor(num_tiles[0]/2), math.floor(num_tiles[1]/2)];

        # 3x3 example: (same for both canvas-tiles and map-tiles)
        #  *************************
        #  * -1,-1 *  0,-1 *  1,-1 *
        #  *************************
        #  * -1, 0 *  0, 0 *  1, 0 *
        #  *************************
        #  * -1, 1 *  0, 1 *  1, 1 *
        #  *************************
        #
        # x goes from -180 lon to +180 lon (zero to me.n)
        # y goes from +85.0511 lat to -85.0511 lat (zero to me.n)
        #
        # me.center_tile_float is always positives, it denotes where we are in x,y (floating points)
        # me.center_tile_int is the x,y tile that we are in (integers)
        # me.center_tile_fraction is where in that tile we are located (normalized)
        # me.tile_offset is the negative buffer so that we show tiles all around us instead of only in x,y positive direction


        for(var xxx = 0; xxx < num_tiles[0]; xxx += 1) {
            for(var yyy = 0; yyy < num_tiles[1]; yyy += 1) {
                tiles[xxx][yyy].setTranslation(-math.floor((me.center_tile_fraction_x - xxx+me.tile_offset[0]) * tile_size), -math.floor((me.center_tile_fraction_y - yyy+me.tile_offset[1]) * tile_size));
            }
        }

        me.liveMap = 1;# TODO: Read from property if allow internet access
        me.zoomed = zoom != last_zoom;
        if(me.center_tile_int[0] != last_tile[0] or me.center_tile_int[1] != last_tile[1] or type != last_type or me.zoomed or me.liveMap != lastLiveMap or lastDay != me.day or providerOptionLast != providerOption)  {
            for(var x = 0; x < num_tiles[0]; x += 1) {
                for(var y = 0; y < num_tiles[1]; y += 1) {
                    # inside here we use 'var' instead of 'me.' due to generator function, should be able to remember it.
                    var xx = me.center_tile_int[0] + x - me.tile_offset[0];
                    if (xx < 0) {
                        # when close to crossing 180 longitude meridian line, make sure we see the tiles on the positive side of the line.
                        xx = me.n + xx;#print(xx~" from "~(xx-me.n));
                    } elsif (xx >= me.n) {
                        # when close to crossing 180 longitude meridian line, make sure we dont double load the tiles on the negative side of the line.
                        xx = xx - me.n;#print(xx~" from "~(xx+me.n));
                    }
                    var pos = {
                        z: zoom,
                        x: xx,
                        y: me.center_tile_int[1] + y - me.tile_offset[1],
                        type: type
                    };

                    (func {# generator function
                        var img_path = makePath(pos);
                        var tile = tiles[x][y];
                        logprint(LOG_DEBUG, 'showing ' ~ img_path);
                        if( io.stat(img_path) == nil and me.liveMap == 1) { # image not found, save in $FG_HOME
                            var img_url = makeUrl(pos);
                            logprint(LOG_DEBUG, 'requesting ' ~ img_url);
                            http.save(img_url, img_path)
                                .done(func(r) {
                                    logprint(LOG_DEBUG, 'received image ' ~ img_path~" " ~ r.status ~ " " ~ r.reason);
                                    logprint(LOG_DEBUG, ""~(io.stat(img_path) != nil));
                                    tile.set("src", img_path);# this sometimes fails with: 'Cannot find image file' if use me. instead of var.
                                    tile.update();
                                    })
                              #.done(func {logprint(LOG_DEBUG, 'received image ' ~ img_path); tile.set("src", img_path);})
                              .fail(func (r) {logprint(LOG_INFO, 'Failed to get image ' ~ img_path ~ ' ' ~ r.status ~ ': ' ~ r.reason);
                                            tile.set("src", "Aircraft/707/Nasal/E-3/emptyTile.png");
                                            tile.update();
                                            });
                        } elsif (io.stat(img_path) != nil) {# cached image found, reusing
                            logprint(LOG_DEBUG, 'loading ' ~ img_path);
                            tile.set("src", img_path);
                            tile.update();
                        } else {
                            # internet not allowed, so noise tile shown
                            tile.set("src", "Aircraft/707/Nasal/E-3/noiseTile.png");
                            tile.update();
                        }
                    })();
                }
            }

        last_tile = me.center_tile_int;
        last_type = type;
        last_zoom = zoom;
        lastLiveMap = me.liveMap;
        lastDay = me.day;
        providerOptionLast = providerOption;
        }

        if (me.hdgUp) me.mapCenter.setRotation(-me.input.heading.getValue()*D2R);
        else me.mapCenter.setRotation(0);
        #switched to direct rotation to try and solve issue with approach line not updating fast.
        me.mapCenter.update();
    },
    
};


#  ███████ ████████ ██    ██ ███████ ███████ 
#  ██         ██    ██    ██ ██      ██      
#  ███████    ██    ██    ██ █████   █████   
#       ██    ██    ██    ██ ██      ██      
#  ███████    ██     ██████  ██      ██      
#                                            
#                                            


var diam = 512;
var cv = canvas.new({
                     "name": "E-3 RDR LEFT",
                     "size": [diam,diam], 
                     "view": [diam,diam],
                     "mipmapping": 1
                    });  

cv.addPlacement({"node": "canvas1", "texture":"radarblade.png"});

cv.setColorBackground(rdrColorBackground);

var cv2 = canvas.new({
                     "name": "E-3 RDR MIDDLE",
                     "size": [diam,diam], 
                     "view": [diam,diam],
                     "mipmapping": 1
                    });  

cv2.addPlacement({"node": "dark", "texture":"radarframe.png"});

cv2.setColorBackground(0.01, 0.105, 0);

var cv3 = canvas.new({
                     "name": "E-3 RDR RIGHT",
                     "size": [diam,diam], 
                     "view": [diam,diam],
                     "mipmapping": 1
                    });  

cv3.addPlacement({"node": "dark2", "texture":"radarsup.png"});

var rwrImage = cv3.createGroup().createChild("image").set("src", "canvas://by-index/texture[3]").setTranslation(0,0);



var root = cv.createGroup();
var rdr1 = RadarScreenLeft.new("RadarScreenLeft", root, [diam/2,diam/2],diam);

var root2 = cv2.createGroup();
var rdr2 = RadarScreenMiddle.new("RadarScreenMiddle", root2, [diam/2,diam/2],diam);


var vector_aicontacts_links = [];
var DLRecipient = emesary.Recipient.new("DLRecipient");
var startDLListener = func {
    DLRecipient.radar = radar_system.dlnkRadar;
    DLRecipient.Receive = func(notification) {
        if (notification.NotificationType == "DatalinkNotification") {
            #printf("DL recv: %s", notification.NotificationType);
            if (me.radar.enabled == 1) {
                vector_aicontacts_links = notification.vector;
            }
            return emesary.Transmitter.ReceiptStatus_OK;
        }
        return emesary.Transmitter.ReceiptStatus_NotProcessed;
    };
    emesary.GlobalTransmitter.Register(DLRecipient);
}

var get_intercept = func(bearingToRunner, dist_m, runnerHeading, runnerSpeed, chaserSpeed, chaserCoord, chaserHeading) {
    # from Leto
    # needs: bearingToRunner_deg, dist_m, runnerHeading_deg, runnerSpeed_mps, chaserSpeed_mps, chaserCoord, chaserHeading
    #        dist_m > 0 and chaserSpeed > 0

    if (dist_m < 500) {
        return nil;
    }

    var trigAngle = 90-bearingToRunner;
    var RunnerPosition = [dist_m*math.cos(trigAngle*D2R), dist_m*math.sin(trigAngle*D2R),0];
    var ChaserPosition = [0,0,0];

    var VectorFromRunner = vector.Math.minus(ChaserPosition, RunnerPosition);
    var runner_heading = 90-runnerHeading;
    var RunnerVelocity = [runnerSpeed*math.cos(runner_heading*D2R), runnerSpeed*math.sin(runner_heading*D2R),0];

    var a = chaserSpeed * chaserSpeed - runnerSpeed * runnerSpeed;
    var b = 2 * vector.Math.dotProduct(VectorFromRunner, RunnerVelocity);
    var c = -dist_m * dist_m;

    if (a == 0) a = 1000;# Otherwise same speeds will produce no intercept even though possible.
    var dd = b*b-4*a*c;
    if (dd<0) {
      # intercept not possible
      return nil;
    }
#print(dd,"  sqrt:",math.sqrt(dd)," c:",c," b:",b," a:",a);
    var t1 = (-b+math.sqrt(dd))/(2*a);
    var t2 = (-b-math.sqrt(dd))/(2*a);

    if (t1 < 0 and t2 < 0) {
      # intercept not possible
      return nil;
    }

    var timeToIntercept = 0;
    if (t1 > 0 and t2 > 0) {
          timeToIntercept = math.min(t1, t2);
    } else {
          timeToIntercept = math.max(t1, t2);
    }

    # some feeble attempt to handle time being not a number:
    timeToIntercept = math.max(0.5, timeToIntercept);
    if (timeToIntercept < 1) {
          return nil;
    }
    


    var InterceptPosition = vector.Math.plus(RunnerPosition, vector.Math.product(timeToIntercept, RunnerVelocity));

    var ChaserVelocity = vector.Math.product(1/timeToIntercept, vector.Math.minus(InterceptPosition, ChaserPosition));
    var interceptAngle = 5;
call(func{
    interceptAngle = vector.Math.angleBetweenVectors([0,1,0], ChaserVelocity);
}, nil, nil, var err =[]);
    if (size(err)) {
      # If timeToIntercept is very big this will go into effect.
          return nil;
    }
    var interceptHeading = geo.normdeg(ChaserVelocity[0]<0?-interceptAngle:interceptAngle);

    var interceptDist = chaserSpeed*timeToIntercept;

    var interceptCoord = geo.Coord.new(chaserCoord);
    interceptCoord = interceptCoord.apply_course_distance(interceptHeading, interceptDist);
    var interceptRelativeBearing = geo.normdeg180(interceptHeading-chaserHeading);

    return [timeToIntercept, interceptHeading, interceptCoord, interceptDist, interceptRelativeBearing];
}

var timer = maketimer(0.05, func rdr1.update(););
timer.simulatedTime = 1;

var timerOutlines = maketimer(30, func rdr1.paintOutlines(););
timerOutlines.simulatedTime = 1;

var timer2 = maketimer(0.25, func rdr2.update(););
timer2.simulatedTime = 1;

var main_init_listener = setlistener("sim/signals/fdm-initialized", func {
    if (getprop("sim/signals/fdm-initialized") == 1) {
        removelistener(main_init_listener);
        timer.start();
        timerOutlines.start();
        rdr2.start();
        timer2.start();
        startDLListener();
      }
});

#setlistener("instrumentation/radar/knob", func {
#    fgcommand("reinit", props.Node.new( {"subsystem": "aircraft-model"} ));
#});