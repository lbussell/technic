include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/gears.scad>
include <../lib/consts.scad>
include <../lib/colors.scad>
include <../lib/3d/beams.scad>

$fn=50;

gear_teeth = 8;
thickness = cstuds(0.5);
backing = 2;
mod=technic_gear_module;


// Same number of teeth as part 87761
rack_teeth = 14;

// Grid for debugging
// #grid();

// xbeam(len=4);
diff("remove-here") {
    beam_grid(tex=[
        [1, 0, 1, 0, 1, 0, 1],
        [0, 1, 1, 1, 1, 1, 0],
        [1, 1, 1, 1, 1, 1, 1],
        [0, 1, 1, 1, 1, 1, 0],
        [1, 1, 1, 1, 1, 1, 1],
        [0, 1, 1, 1, 1, 1, 0],
        [1, 0, 1, 0, 1, 0, 1],
    ]);

    side_pin_holes(); // top
    down(studs(6)) side_pin_holes(); // bottom
    yrot(90) side_pin_holes(); // left
    right(studs(6)) yrot(90) side_pin_holes(); // left
}

module side_pin_holes()
    right(studs(3))
        xrot(90)
        xcopies(n=3, spacing=studs(2))
        force_tag("remove-here")
        pin_hole();


// diff("remove") {
//     install_gear_and_rack() hull() {
//         left(studs(1)) beam_one();
//         right(studs(1)) beam_one();
//         left(studs(1)) down(studs(1)) beam_one();
//         right(studs(1)) down(studs(1)) beam_one();
//     }

//     left(studs(3)) down(studs(1)) {
//         solid_beam_one();
//         tag("remove") pin_hole();
//     }
//     right(studs(3)) down(studs(1)) solid_beam_one();
// }

module beam_one() difference() { solid_beam_one(); pin_hole(); }

module solid_beam_one() ycyl(h=cstuds(1), d=cstuds(1));

module install_gear_and_rack() {
    union() {
        gear_and_rack();
        difference() {
            children();
            cutout();
        }
    }
}

module cutout() {
    xcopies(n=3, spacing=studs(1)) pin_hole();
    cube([studs(3), studs(0.5), studs(1)], center=true)
        align(BOTTOM) cube([cstuds(3), studs(0.5), 4]);
}

// module pin_hole() {
//     module ridge() ycyl(h=technic_hole_ridge_depth, d=technic_hole_ridge_diameter);
//     ycyl(h=studs(1), d=technic_hole_diameter) {
//         align(FRONT, inside=true) ridge();
//         align(BACK, inside=true) ridge();
//     }
// }

module gear_and_rack() {
    d = gear_dist(
        mod=mod,
        teeth1=gear_teeth,
        teeth2=0
    );
    yrot(180) xrot(90) spur_gear(
        mod=mod,
        teeth=gear_teeth,
        thickness=thickness
    );
    xrot(90) fwd(d) rack(
        mod=mod,
        teeth=rack_teeth,
        thickness=thickness,
        backing=backing,
        orient=BACK
    );
}

module grid() {
    up(studs(0.5)) right(studs(0.5)) grid_copies(n=10, studs(1), axes="xz")
    {
        sphere(d=1);
    }
}
