include <../lib/gears.scad>

// Parameters
// num_teeth = 16; // [12:1:20]
// thickness_studs = 1.00; // [0.25:0.25:4.00]
// type = "axle"; // ["axle","pin"]

/* [Hidden] */
$fn=50;
fudge = 0.01;

// gear(
//     num_teeth=num_teeth,
//     depth_studs=thickness_studs,
//     type=type);

driving_ring();
