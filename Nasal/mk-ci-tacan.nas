# ==========================
# Course Inidcator for TACAN
# ==========================
var mod = func(n, m) {
    var x = n - m * int(n/m);      # int() truncates to zero, not -Inf
    return x < 0 ? x + abs(m) : x; # ...so must handle negative n's
}

var indiBearingDeg = func(a,b){
  var diff = b-a;
  var newAngle = 0.0;
  if(diff > 180)
  {
      newAngle = mod((diff + 180),360) - 180;
  }
  elsif(diff < -180)
  {
      newAngle = mod((diff - 180),360) + 180;
  }
  else
  {
      newAngle = mod(diff, 360);
  }

  return (360 - newAngle);
};


setlistener("/instrumentation/tacan/indicated-bearing-true-deg", func(tacanDegree) {
      var tacanDegree = tacanDegree.getValue() or 0;
      var aircraftDirDeg = getprop("/orientation/heading-deg");
      var inRange = getprop("/instrumentation/tacan/in-range") or 0;

      var indiDeg = indiBearingDeg(aircraftDirDeg,tacanDegree);

      if (inRange){
        setprop("/instrumentation/tacan/display/correction", indiDeg);
      }else{
        setprop("/instrumentation/tacan/display/correction", 0);
      }
});


