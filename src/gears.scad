include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/gears.scad>
include <common.scad>

gear(16, s_thickness=0.5);

module gear(n=16, s_thickness=1)
{
    spur_gear(mod=1, teeth=n, thickness=size(s_thickness));
}
