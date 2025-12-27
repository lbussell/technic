
// Basic unit measurements (in mm)
LEGO_UNIT = 8.0;           // Standard LEGO grid unit (8mm)
LEGO_UNIT_TOLERANCE = 0.1; // Tolerance between two pieces

// Helper functions
// Compute the exact distance between studs
function studs(units) = units*LEGO_UNIT;
// Compute the size of a piece accounting for tolerance
function size(studs) = studs*LEGO_UNIT - 2*LEGO_UNIT_TOLERANCE;
