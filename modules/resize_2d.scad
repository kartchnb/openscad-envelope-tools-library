/* [Test Parameters] */
// The test cell size (width and height)
Cell_Size = 75;
// The model file to use
Model_File_2D = "../test/test.svg";
// The model file to use
Model_File_3D = "../test/test.stl";
// The value to use for iota
Iota = 1;
// The value to use for omega
Omega = 9999;
// The render quality
Render_Quality = 32;

/* [Test Code] */
$fn = $fn != 0 ? $fn : Render_Quality;
include<../test/_test_grid.scad>

Labels =
[
    "original", 
    "square_resize([50, 50])", 
    "square_resize([25, 50])", 
    "square_resize([50, 25])", 
    "square_resize([10, 50])",
    "square_resize([10, 50], expansion=20)",
    "circle_resize(d=50)", 
];

_envelope_tools_grid_layout([Cell_Size, Cell_Size], labels=Labels)
{
    _envelope_tools_row_layout([Cell_Size, Cell_Size], Model_File_2D)
    {
        import(Model_File_2D);
        group() {square_resize([50, 50], model_is_3d=false, iota=Iota, omega=Omega) import(Model_File_2D); %square([50, 50], center=true);}
        group() {square_resize([25, 50], model_is_3d=false, iota=Iota, omega=Omega) import(Model_File_2D); %square([25, 50], center=true);}
        group() {square_resize([50, 25], model_is_3d=false, iota=Iota, omega=Omega) import(Model_File_2D); %square([50, 25], center=true);}
        group() {square_resize([10, 50], model_is_3d=false, iota=Iota, omega=Omega) import(Model_File_2D); %square([10, 50], center=true);}
        group() {square_resize([50, 50], model_is_3d=false, iota=Iota, omega=Omega, expansion=20) import(Model_File_2D); %square([50, 50], center=true);}
        group() {circle_resize(d=50, model_is_3d=false, iota=Iota) import(Model_File_2D); %circle(d=50);}
    }
    _envelope_tools_row_layout([Cell_Size, Cell_Size], Model_File_3D, extrusion=1)
    {
        import(Model_File_3D);
        group() {square_resize([50, 50], model_is_3d=true, iota=Iota, omega=Omega) import(Model_File_3D); %square([50, 50], center=true);}
    }
}



use<envelope_2d.scad>



// Resizes the underlying geometry to fit within the provided rectangular area
// The geometry will be shrunk to fit within the area, whether that requires
// it to meet the width or length.
//
// parameters:
//  size - the size of the area to resize the geometry to
//      This can be specified as list with width and height or a single value
//      that will be used for both dimensions
//      (defaults to 1)
//  cut - the same as the "cut" parameter in the standard projection module
//      (defaults to false, same as the standard cut module)
//  model_is_3d - Used to manually specify whether the children of this module 
//      are 3-dimensional
//      WARNING: Setting this incorrectly for the underlying geometry will
//      break the function
//      When in doubt, leave it unset
//      (defaults to undef, which will handle any geometry but will always
//      display a warning)
//  iota - a small value used to extrude 2D geometry
//      (defaults to 0.001)
//  omega - the largest allowable value
//      This should not need to be changed unless working with very large 
//      geometries
//      (defaults to 9999)
module square_resize(size=1, expansion=0, cut=false, model_is_3d=undef, iota=0.001, omega=9999)
{
    width = is_list(size) ? size.x : size;
    height = is_list(size) ? size.y : size;

    min_dimension = min(width, height);
    x_ratio = min_dimension/width;
    y_ratio = min_dimension/height;

    difference()
    {
        resize([width, height])
            square_envelope(aspect=1, expansion=expansion, cut=cut, model_is_3d=model_is_3d, iota=iota, omega=omega)
            scale([x_ratio, y_ratio])
            children();
        resize([width, height])
            square_negative(aspect=1, expansion=expansion, cut=cut, model_is_3d=model_is_3d, iota=iota, omega=omega)
            scale([x_ratio, y_ratio])
            children();
    }
}



// Resizes the underlying geometry to fit within the provided circular area
// The geometry will be shrunk to fit within the area, whether that requires
// it to meet the width or length.
//
// parameters:
//  r - the radius of the area to fit within
//      (defaults to 1)
//  d - the diameter of the area to fit within
//      (defaults to undef and the radius will be used)
//  cut - the same as the "cut" parameter in the standard projection module
//      (defaults to false, same as the standard cut module)
//  model_is_3d - Used to manually specify whether the children of this module 
//      are 3-dimensional
//      WARNING: Setting this incorrectly for the underlying geometry will
//      break the function
//      When in doubt, leave it unset
//      (defaults to undef, which will handle any geometry but will always
//      display a warning)
//  iota - a small value used to extrude 2D geometry
//      (defaults to 0.001)
module circle_resize(r=1, d=undef, expansion=0, cut=false, model_is_3d=undef, iota=0.001)
{
    width = is_undef(d) ? r*2 : d;
    height = width;

    difference()
    {
        resize([width, height])
            circle_envelope(expansion=expansion, cut=cut, model_is_3d=model_is_3d, iota=iota)
            children();
        resize([width, height])
            circle_negative(expansion=expansion, cut=cut, model_is_3d=model_is_3d, iota=iota)
            children();
    }
}
