include <../lib/consts.scad>
include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/gears.scad>

axle_outer_diameter = 5.52;
axle_fillet_radius = 0.55;
axle_cross_width = 1.87;

pin_inner_diameter = 5.10;
pin_outer_diameter = 6.20;
pin_inset_depth = 0.80;

wall_thickness = 0.8;

clutch_teeth_length = 0.8;

center_tube_outer_diameter = max(axle_outer_diameter, pin_inner_diameter) + 2*wall_thickness;

driving_ring_wall_thickness = 1.6;
driving_ring_clearance = 0.15;

interface_inner_diameter = center_tube_outer_diameter + driving_ring_clearance*2;
interface_outer_diameter = interface_inner_diameter + clutch_teeth_length*2;

driving_ring_inner_diameter = interface_outer_diameter + driving_ring_clearance*2;
driving_ring_outer_diameter = driving_ring_inner_diameter + driving_ring_wall_thickness*2;

module driving_ring(depth_studs=1)
{
    depth = cstuds(depth_studs);
    diff()
    {
        cyl(d=driving_ring_outer_diameter, h=depth);

        tag("remove")
            linear_extrude(height=depth+fudge, center=true)
            offset(delta=driving_ring_clearance)
            driving_ring_interface_2d();
    }
}

module driving_ring_adapter(depth_studs=1)
{
    depth = cstuds(depth_studs);

    diff()
    {
        linear_extrude(height=depth, center=true)
            driving_ring_interface_2d();

        down(depth/2 + fudge/2)
            axle_cross(depth+fudge);
    }
}

module driving_ring_interface_2d()
{
    difference()
    {
        circle(d=interface_outer_diameter);
        teeth(inner_diameter=interface_inner_diameter,
            outer_diameter=interface_outer_diameter);
    }
}

module gear(num_teeth=16, depth_studs=1, type="axle")
{
    inside_diameter = num_teeth - 5;

    // Clutch gears have fixed depth
    is_clutch = type == "clutch";
    total_depth = is_clutch ? cstuds(1) : cstuds(depth_studs);
    gear_depth = is_clutch ? studs(0.5) : total_depth;
    clutch_angle = 20;

    diff("remove")
    {
        up(gear_depth/2)
            base_gear();
        cyl(h=gear_depth + (total_depth-gear_depth)/2, d=driving_ring_inner_diameter, center=false);
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
            linear_extrude(height=center_depth)
            teeth(
                inner_diameter=center_tube_outer_diameter,
                outer_diameter=center_tube_outer_diameter + 2*clutch_teeth_length,
                angle=15);
            pin_hole(center_depth, inset=false);
        }

        module center() cylinder(h=center_depth, d=center_tube_outer_diameter);
    }

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

module teeth(inner_diameter=1, outer_diameter=2, angle=20)
    zrot_copies(n=4, sa=45)
    offset(delta=0.01)
    difference()
    {
        circle(d=outer_diameter);
        zrot(-angle/2) right(50) square([100,100], center=true);
        zrot(angle/2) left(50) square([100,100], center=true);
        circle(d=inner_diameter);
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
