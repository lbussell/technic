include <../lib/gears.scad>

/* [Hidden] */
$fn=50;
fudge = 0.01;

assembly(t1=14, t2=16);
up(studs(3.5)) assembly(18, 20);

module assembly(t1=16, t2=20)
{
    driving_ring();
    shift_fork();
    driving_ring_adapter();

    down(studs(1.5)) clutch_gear(t1);
    down(studs(1.5)) right(studs(2)) axle_gear(num_teeth=32-t1);

    up(studs(1.5)) xrot(180) clutch_gear(t2);
    up(studs(1)) right(studs(2)) axle_gear(num_teeth=32-t2);
}

module clutch_gear(num_teeth) zrot(45) gear(num_teeth, type="clutch");
module axle_gear(num_teeth) gear(num_teeth, depth_studs=0.5, type="axle");
