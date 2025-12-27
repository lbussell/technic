include <../lib/consts.scad>
include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/gears.scad>

// Parameters
num_teeth = 16; // [12:1:20]
thickness_studs = 1.00; // [0.25:0.25:4.00]
type = "axle"; // ["axle","pin"]

/* [Hidden] */
$fn=50;
fudge = 0.01;
inside_diameter = num_teeth - 5;

gear(
    num_teeth=num_teeth,
    depth_studs=thickness_studs,
    inside_diameter=inside_diameter,
    type=type);

module gear(num_teeth=16, depth_studs=1, inside_diameter=1, type="axle")
{
    axle_outer_diameter = 5.52;
    axle_fillet_radius = 0.55;
    axle_cross_width = 1.87;

    pin_inner_diameter = 5.10;
    pin_outer_diameter = 6.20;
    pin_inset_depth = 0.80;

    wall_thickness = 2;

    center_tube_diameter = max(axle_outer_diameter, pin_inner_diameter) + wall_thickness;
    depth = cstuds(depth_studs);

    diff("remove")
    {
        hollow_gear();
        walls();
        center_tube();
    }

    module center_tube()
    {
        cylinder(h=depth, d=center_tube_diameter, center=true)

        if (type == "axle") axle_cross(depth+fudge);
        if (type == "pin") pin_hole(depth+fudge);
    }

    module walls()
        zrot_copies([0, 90])
        cube(size=[wall_thickness, inside_diameter, depth], center=true);

    module pin_hole(height)
        tag("remove")
        {
            linear_extrude(height=height, center=true)
            pin_hole_2d();

            xrot_copies(n=2)
            down(height/2)
            cylinder(h=pin_inset_depth, d=pin_outer_diameter);
        }

    module pin_hole_2d()
        circle(d=pin_inner_diameter);

    module axle_cross(height)
        tag("remove")
        linear_extrude(height=height, center=true)
        axle_cross_2d();

    module axle_cross_2d()
    {
        intersection()
        {
            circle(d=axle_outer_diameter);

            union()
            {
                zrot_copies([0, 90])
                square([axle_cross_width, axle_outer_diameter], center=true);

                zrot_copies(n=4)
                right(axle_cross_width/2)
                back(axle_cross_width/2)
                mask2d_roundover(r=axle_fillet_radius);
            }
        }
    }

    module hollow_gear()
    {
        difference()
        {
            base_gear();
            gear_hollow_inside();
        }
    }

    module base_gear()
        spur_gear(
            mod=1,
            teeth=num_teeth,
            thickness=depth);

    module gear_hollow_inside()
        cylinder(
            h=cstuds(depth_studs)+2,
            d=num_teeth-5,
            center=true);
}
