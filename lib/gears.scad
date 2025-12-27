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

clutch_teeth_length = 1;
clutch_teeth_width = 0.5;
clutch_depth = studs(0.25);

driving_ring_wall_thickness = 1.5;
driving_ring_clearance = 0.15;

center_tube_outer_diameter = max(axle_outer_diameter, pin_inner_diameter) + wall_thickness;

module driving_ring(depth_studs=1)
{
    depth = cstuds(depth_studs);
    clearance = 2*driving_ring_clearance;

    // Inside, where the clutch teeth meet up
    driving_ring_inner_diameter =
        center_tube_outer_diameter
        + clutch_teeth_length*2
        + clearance;

    driving_ring_outer_wall_thickness = 1;
    driving_ring_outer_diameter =
        driving_ring_inner_diameter
        + 2*driving_ring_outer_wall_thickness;

    diff("remove", "keep")
    {
        cyl(h=depth, d=driving_ring_outer_diameter)
        {
            xrot_copies(n=2) attach(TOP) tag("keep") clutch_teeth();
            xrot_copies(n=2) clutch_inset();
        }

        // Inside inside, for the driving ring adapter
        tag("remove")
            linear_extrude(height=depth+fudge, center=true)
            offset(delta=driving_ring_clearance)
            driving_ring_interface_2d();
    }

    module clutch_teeth()
    {
        clutch_outer_r = driving_ring_inner_diameter/2 + clearance/2;
        clutch_inner_r = clutch_outer_r - clutch_teeth_length;

        down(clutch_depth/2)
        zrot_copies(n=4, r=clutch_outer_r)
        left(clutch_teeth_length/2)
        cuboid([clutch_teeth_length, clutch_teeth_width, clutch_depth]);
    }

    module clutch_inset()
        align(TOP, inside=true, shiftout=fudge)
            cyl(h=clutch_depth, d=driving_ring_inner_diameter + clearance);
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
    radius = 1.8;
    inset_amount = 1.3;

    offset_amount = center_tube_outer_diameter/2 + radius/inset_amount;

    diff("remove2d")
    {
        circle(d=center_tube_outer_diameter);

        zrot_copies(n=4, r=offset_amount, sa=45)
            tag("remove2d")
            circle(r=radius);
    }
}

module gear(num_teeth=16, depth_studs=1, type="axle")
{
    inside_diameter = num_teeth - 5;

    // Clutch gears have fixed depth
    is_clutch = type == "clutch";
    total_depth = is_clutch ? cstuds(0.75) : cstuds(depth_studs);
    gear_depth = is_clutch ? cstuds(0.5) : total_depth;

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
