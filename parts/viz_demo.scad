
$fn=100;
difference()
{
    sphere(d=1);
    cyl();
    rotate([90,0,0]) cyl();
    rotate([0,90,0]) cyl();
}

module cyl() cylinder(h=1, r=0.25, center=true);
