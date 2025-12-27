include <../lib/consts.scad>
include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/gears.scad>

axle_outer_diameter = 5.52;
axle_fillet_radius = 0.55;
axle_cross_width = 1.87;

pin_inner_diameter = 5.10;
pin_outer_diameter = 6.20;
pin_inset_depth = 0.80;

wall_thickness = 2;

center_tube_outer_diameter = max(axle_outer_diameter, pin_inner_diameter) + wall_thickness;

module driving_ring(num_teeth=4)
{
    depth = cstuds(2);

    diff("remove")
    {
        outer();
        inner();
    }

    module outer() cylinder(h=depth, d=center_tube_outer_diameter + wall_thickness, center=true);
    module inner() tag("remove") cylinder(h=depth+fudge, d=center_tube_outer_diameter, center=true);
}

module gear(num_teeth=16, depth_studs=1, type="axle")
{
    inside_diameter = num_teeth - 5;

    // Clutch gears have fixed depth
    is_clutch = type == "clutch";
    total_depth = is_clutch ? cstuds(0.75) : cstuds(depth_studs);
    gear_depth = is_clutch ? cstuds(0.5) : total_depth;
    clutch_depth = studs(0.25);
    clutch_teeth_length = 1;
    clutch_teeth_width = 1;

    diff("remove")
    {
        hollow_gear();
        walls();
        center_tube();
    }

    module center_tube()
    {
        center_depth = type == "clutch" ? total_depth : gear_depth;

        center();
        if (type == "axle") axle_cross(gear_depth+fudge);
        if (type == "pin") pin_hole(gear_depth);

        if (type == "clutch")
        {
            clutch_teeth();
            pin_hole(center_depth, inset=false);
        }

        module center() cylinder(h=center_depth, d=center_tube_outer_diameter);
    }

    module clutch_teeth()
        zrot_copies([0, 90])
        up(gear_depth + clutch_depth/2)
        cuboid([clutch_teeth_width, 2*clutch_teeth_length + center_tube_outer_diameter, clutch_depth]);

    module walls()
        zrot_copies([0, 90])
        up(gear_depth/2)
        cube(size=[wall_thickness, inside_diameter, gear_depth], center=true);

    module hollow_gear()
    {
        up(gear_depth/2)
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
            thickness=gear_depth);

    module gear_hollow_inside()
        cylinder(
            h=gear_depth+fudge,
            d=num_teeth-5,
            center=true);
}

module pin_hole(height, inset=true)
    tag("remove")
    {
        down(fudge)
        linear_extrude(height=height+2*fudge)
        pin_hole_2d();

        if (inset)
            up(height/2)
            xrot_copies(n=2)
            down((height+fudge)/2)
            cylinder(h=pin_inset_depth, d=pin_outer_diameter);
    }

module pin_hole_2d()
    circle(d=pin_inner_diameter);

module axle_cross(height)
    tag("remove")
    linear_extrude(height=height)
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
