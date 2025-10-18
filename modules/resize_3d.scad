/* [Test Parameters] */
// The test cell size (width and height)
Cell_Size = 300;
// The model file to use
Model_File_3D = "../test/test.stl";
// The value to use for iota
Iota = 1;
// The render quality
Render_Quality = 32;

/* [Test Code] */
$fn = $fn != 0 ? $fn : Render_Quality;
include<../test/_test_grid.scad>

Labels =
[
    "original", 
    "prism_resize([50, 50])"
];

_envelope_tools_grid_layout([Cell_Size, Cell_Size], labels=Labels, extrusion=1)
{
    _envelope_tools_row_layout([Cell_Size, Cell_Size], Model_File_3D, extrusion=1)
    {
        import(Model_File_3D);
        group() {prism_resize([Cell_Size*.75, Cell_Size*.75], model_is_3d=true, iota=Iota) import(Model_File_3D);}
    }
}



use<axis_projection.scad>
use<envelope_2d.scad>
use<envelope_3d.scad>



// Resizes the underlying geometry to fit within the provided rectangular area
// The geometry will be shrunk to fit within the area, whether that requires
// it to meet the width or length.
//
// parameters:
//  size - the size of the area to resize the geometry to
//      This can be specified as list with width and height or a single value
//      that will be used for both dimensions
//      (defaults to 1)
//  aspect - An optional aspect ratio to enforce on the envelope
//      if set, the envelope will be resized to the requested ratio
//      if left undefined, the envelope will wrap the underlying geometry
//      (defaults to undef)
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
module prism_resize(size=1, expansion=0, cut=false, model_is_3d=undef, iota=0.001)
{
    width = is_list(size) ? size.x : size;
    height = is_list(size) ? size.y : size;

    difference()
    {
        resize([width, height, 0], auto=true)
        {
            mirror([0, 0, 1])
            linear_extrude(iota)
            for (z_rot = [0, 90])
            {
                rotate([0, 0, z_rot])
                maximum_axis_projection([1, 1, 0], expansion=expansion, cut=cut, model_is_3d=model_is_3d, iota=iota)
                    children();
            }
            
            children();
        }

        mirror([0, 0, 1])
            cube([width*2, height*2, iota*2], center=true);
    }
}
