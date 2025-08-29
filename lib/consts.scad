
stud_spacing = 8;

// The clearance on either side of an element when it's meant to be placed
// next to another element. i.e. a 1 stud wide beam would be 7.8mm wide.
stud_clearance = 0.1;

technic_hole_diameter = 4.85 + 0.2; // Additional clearance added for 3D printing
technic_hole_ridge_diameter = 6.3;
technic_hole_ridge_depth = 0.7;

// Module of 1 means that a 16 tooth gear has a 16mm diameter (convenient!)
technic_gear_module = 1;

// Spacing between n studs
function studs(n) = n * stud_spacing;

// The size of an element n studs large, with room for clearance on either side
// of the element
function cstuds(n) = (n * stud_spacing) - (2 * stud_clearance);
