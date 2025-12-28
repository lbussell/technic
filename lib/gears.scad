include <../lib/consts.scad>
include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/gears.scad>

fudge = 0.01;

axle_outer_diameter = 5.52;
axle_fillet_radius = 0.55;
axle_cross_width = 1.90;

pin_inner_diameter = 5.10;
pin_outer_diameter = 6.20;
pin_inset_depth = 0.80;

wall_thickness = 0.8;

clutch_teeth_length = 0.8;

center_tube_outer_diameter = max(axle_outer_diameter, pin_inner_diameter) + 2*wall_thickness;
adapter_small_outer_diameter = pin_inner_diameter + 2*wall_thickness;

gear_clearance = 0.15;
gear_wall_inner_diameter = adapter_small_outer_diameter + 2*gear_clearance; // some clearance
gear_wall_outer_diameter = gear_wall_inner_diameter + wall_thickness*2;

driving_ring_wall_thickness = 1.6;
driving_ring_clearance = 0.15;

interface_inner_diameter = gear_wall_outer_diameter + driving_ring_clearance*2;
interface_outer_diameter = interface_inner_diameter + clutch_teeth_length*2;

driving_ring_inner_diameter = interface_outer_diameter + driving_ring_clearance*2;
driving_ring_outer_diameter = driving_ring_inner_diameter + driving_ring_wall_thickness*3;

shift_fork_depth = 1.0;
shift_fork_width = 2.0;
shift_fork_inset_depth = studs(1/2);
shift_fork_inset_inner_diameter = driving_ring_outer_diameter - shift_fork_width;
shift_fork_inset_outer_diameter = driving_ring_outer_diameter+fudge;
shift_fork_outer_diameter = shift_fork_inset_outer_diameter + wall_thickness*2;

module driving_ring(depth_studs=1)
{
    depth = cstuds(depth_studs);
    diff()
    {
        cyl(d=driving_ring_outer_diameter, h=depth);

        tag("remove")
        {
            linear_extrude(height=depth+fudge, center=true)
            offset(delta=driving_ring_clearance)
            driving_ring_interface_2d();
            offset3d(driving_ring_clearance) shift_fork_ring();
        }
    }
}

module shift_fork()
{
    difference()
    {
        shift_fork_ring();
        pie_slice(h=shift_fork_inset_depth+fudge, d=shift_fork_outer_diameter+fudge, ang=150, center=true);
    }
}

module shift_fork_ring()
{
    difference()
    {
        cyl(d=shift_fork_outer_diameter, h=shift_fork_inset_depth);

        union()
        {
            down(shift_fork_inset_depth/4) cyl(d1=shift_fork_inset_outer_diameter, d2=shift_fork_inset_inner_diameter, h=shift_fork_inset_depth/2+fudge);
            up(shift_fork_inset_depth/4) cyl(d1=shift_fork_inset_inner_diameter, d2=shift_fork_inset_outer_diameter, h=shift_fork_inset_depth/2+fudge);
        }
    }
}

module driving_ring_adapter()
{
    diff()
    {
        // linear_extrude(height=studs(1), center=true) driving_ring_interface_2d();
        driving_ring_interface_3d();
        cyl(d=adapter_small_outer_diameter, h=cstuds(3));

        up(studs(1/2)) axle_cross(studs(1));
        down(studs(3/2)) axle_cross(studs(1));
    }
}

module driving_ring_interface_3d(height=studs(1), center=true)
{
    difference()
    {
        cyl(d=interface_outer_diameter, h=height, chamfer=1.7, chamfang=30, center=center);
        linear_extrude(height=height, center=center)
            teeth(inner_diameter=interface_inner_diameter,
                outer_diameter=interface_outer_diameter);

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
        center_tube();
    }

    module center_tube()
    {
        center_depth = type == "clutch" ? total_depth : gear_depth;

        if (type == "axle")
        {
            center();
            axle_cross(gear_depth+fudge);
        }

        if (type == "pin")
        {
            center();
            pin_hole(gear_depth);
        }

        if (type == "clutch")
        {
            cyl(d=gear_wall_outer_diameter, h=center_depth, center=false);
            tag("remove") down(fudge/2) cyl(d=gear_wall_inner_diameter, h=center_depth+fudge, center=false);

            clutch_teeth_outer_diameter = gear_wall_outer_diameter + 2*clutch_teeth_length;
            // Block the driving ring from going to far onto the gear
            cyl(h=gear_depth + (total_depth-gear_depth)/2, d=clutch_teeth_outer_diameter, center=false);

            linear_extrude(height=center_depth)
                teeth(inner_diameter=gear_wall_outer_diameter,
                    outer_diameter=clutch_teeth_outer_diameter,
                    angle=15);
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
