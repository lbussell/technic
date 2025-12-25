
module xbeam(len=1, thickness=1, solid=false) {
    for (i = [0 : len - 1]) {
        diff() conv_hull("remove") {
            right(studs(i)) beam_part(thickness=thickness);
            if (i < len - 1) {
                right(studs(i + 1)) beam_part(thickness=thickness);
            }
        }
    }
}

module beam_grid(tex=[[1]], thickness=1)
    diff() conv_hull("remove")
        for (y = [0 : len(tex) - 1])
        for (x = [0 : len(tex[y]) - 1])
            if (tex[y][x])
                right(studs(x))
                down(studs(y))
                beam_part(thickness=thickness);

module pin_hole(thickness=1) {
    module ridge() ycyl(
        h=technic_hole_ridge_depth,
        d=technic_hole_ridge_diameter
    );

    tag("remove") ycyl(h=studs(thickness), d=technic_hole_diameter) {
        align(FRONT, inside=true) ridge();
        align(BACK, inside=true) ridge();
    }
}

module beam_part(thickness=1) {
    ycyl(h=cstuds(thickness), d=cstuds(1));
    pin_hole(thickness=thickness);
}
