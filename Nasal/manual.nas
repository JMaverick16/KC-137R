#######################################################################################
#		Lake of Constance Hangar :: M.Kraus
#		Boeing 707 for Flightgear Septemper 2013
#		This file is licenced under the terms of the GNU General Public Licence V2 or later
#######################################################################################
var manual = func{
  var page = getprop("/b707/manual/page") or 0;
  var nt = getprop("/b707/manual/content/title["~page~"]") or "";
  var st1 = getprop("/b707/manual/content/subtitle1["~page~"]") or "";
  var t1 = getprop("/b707/manual/content/text1["~page~"]") or "";
  var st2 = getprop("/b707/manual/content/subtitle2["~page~"]") or "";
  var t2 = getprop("/b707/manual/content/text2["~page~"]") or "";
  var st3 = getprop("/b707/manual/content/subtitle3["~page~"]") or "";
  var t3 = getprop("/b707/manual/content/text3["~page~"]") or "";
  var st4 = getprop("/b707/manual/content/subtitle4["~page~"]") or "";
  var t4 = getprop("/b707/manual/content/text4["~page~"]") or "";
  setprop("/b707/manual/title", nt);
  setprop("/b707/manual/subtitle1", st1);
  setprop("/b707/manual/text1", t1);
  setprop("/b707/manual/subtitle2", st2);
  setprop("/b707/manual/text2", t2);
  setprop("/b707/manual/subtitle3", st3);
  setprop("/b707/manual/text3", t3);
  setprop("/b707/manual/subtitle4", st4);
  setprop("/b707/manual/text4", t4);
}
