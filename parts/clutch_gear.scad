include <../lib/gears.scad>

// Parameters
num_teeth = 14; // [12:1:20]

/* [Hidden] */
$fn=50;

gear(num_teeth=num_teeth, depth_studs=1, type="clutch");
