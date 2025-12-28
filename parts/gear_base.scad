include <../lib/gears.scad>

// Parameters
num_teeth = 16; // [12:1:20]
thickness_studs = 1.00; // [0.25:0.25:4.00]
type = "axle"; // ["axle","pin","clutch"]

distribute = $t; // [0:10]
distribute_studs = 0.5 * studs(distribute);

/* [Hidden] */
$fn=50;
fudge = 0.01;

up(distribute_studs*3) driving_ring();
up(distribute_studs*1) driving_ring_adapter();
up(distribute_studs*0) down(studs(1.5)) this_gear();

module this_gear()
    gear(
        num_teeth=num_teeth,
        depth_studs=thickness_studs,
        type=type);
