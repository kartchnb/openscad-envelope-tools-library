/* [Test Parameters] */
// The size of each test cell
Cell_Size = 125;
// The 2D model file
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
    "prism_envelope()", 
    "prism_negative()", 
    "cylinder_envelope()", 
    "cylinder_negative()",
    "prism_envelope(aspect=[1, 1])",
];

_envelope_tools_grid_layout([Cell_Size, Cell_Size], labels=Labels, extrusion=1)
{
    _envelope_tools_row_layout([Cell_Size, Cell_Size], label=Model_File_3D, extrusion=1)
    {
        import(Model_File_3D);
        group() { prism_envelope(model_is_3d=true) import(Model_File_3D); %import(Model_File_3D); }
        intersection() { prism_negative(model_is_3d=true) import(Model_File_3D); translate([0, -Omega/2, 0]) cube(Omega); %import(Model_File_3D); }        group() { cylinder_envelope(model_is_3d=true) import(Model_File_3D); %import(Model_File_3D); }
        intersection() { cylinder_negative(model_is_3d=true) import(Model_File_3D); translate([0, -Omega/2, 0]) cube(Omega); %import(Model_File_3D); }
        group() { prism_envelope(aspect=[1,1], model_is_3d=true) import(Model_File_3D); %import(Model_File_3D); }
        group() { prism_envelope(aspect=[1,2], model_is_3d=true) import(Model_File_3D); %import(Model_File_3D); }
    }
}



use<envelope_2d.scad>



// Generate a prismatic (3d rectangle) envelope surrounding the child geometry
// An optional aspect can be specified to force the envelope to take a different 
// aspect ratio rather than stricly follow the child geometry
//
// parameters:
//  aspect - An optional aspect ratio to enforce on the envelope
//      if set, the envelope will be resized to the requested ratio
//      if left undefined, the envelope will wrap the underlying geometry
//      (defaults to undef)
//  expansion - the amount to extend the envelope beyond the bounds of the child 
//      geometry
//      So, for example, if expansion is set to 2 and a cube of size 20 is
//      passed in, the envelope will each have dimensions of 24
//      If this value is negative, the envelope will be smaller than the
//      dimensions of the child geometry
//      A single value can be passed for all sides, or a list can be 
//      used to give different x and y expansion values
//      (defaults to 0)
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
module prism_envelope(aspect=undef, expansion=0, cut=false, model_is_3d=undef, iota=0.001, omega=9999)
{
    // Calculate the aspect ratio
    x_aspect = is_undef(aspect) ? undef : 
        is_list(aspect) ? aspect.x : aspect;
    y_aspect = is_undef(aspect) ? undef : 
        is_list(aspect) ? aspect.y : aspect;
    z_aspect = is_undef(aspect) ? undef : 
        is_list(aspect) ? is_undef(aspect.z) ? undef : aspect.z : aspect;

    min_dimension = is_undef(x_aspect) || is_undef(y_aspect) ? undef :
        is_undef(z_aspect) ? min(x_aspect, y_aspect) :
        min(x_aspect, y_aspect, z_aspect);
    x_ratio = is_undef(x_aspect) || is_undef(min_dimension) ? undef : x_aspect / min_dimension;
    y_ratio = is_undef(y_aspect) || is_undef(min_dimension)  ? undef : y_aspect / min_dimension;
    z_ratio = is_undef(z_aspect) || is_undef(min_dimension)  ? undef : z_aspect / min_dimension;

    // Calculate the expansion to add to the envelope
    x_expansion = is_list(expansion) ? expansion.x : expansion;
    y_expansion = is_list(expansion) ? expansion.y : expansion;
    z_expansion = is_list(expansion) ? expansion.z : expansion;

    intersection()
    {
        linear_extrude(omega, center=true)
            square_envelope(aspect=[x_aspect, y_aspect], expansion=[x_expansion, y_expansion], cut=cut, model_is_3d=model_is_3d, iota=iota, omega=omega)
            children();

        union()
        {
            rotate([-90, 0, 00])
                linear_extrude(omega, center=true)
                square_envelope(expansion=[x_expansion, y_expansion], cut=cut, model_is_3d=model_is_3d, iota=iota, omega=omega)
                rotate([90, 0, 0])
                children();

            rotate([0, -90, 00])
                linear_extrude(omega, center=true)
                square_envelope(expansion=[x_expansion, y_expansion], cut=cut, model_is_3d=model_is_3d, iota=iota, omega=omega)
                rotate([0, 90, 0])
                children();
        }
    }
}



// Generate a prismatic (3d rectangle) negative surrounding the child geometry
// An optional aspect can be specified to force the envelope to take a different 
// aspect ratio rather than stricly follow the child geometry
//
// parameters:
//  aspect - An optional aspect ratio to enforce on the envelope
//      if set, the envelope will be resized to the requested ratio
//      if left undefined, the envelope will wrap the underlying geometry
//      (defaults to undef)
//  expansion - the amount to extend the envelope beyond the bounds of the child 
//      geometry
//      So, for example, if expansion is set to 2 and a cube of size 20 is
//      passed in, the envelope will each have dimensions of 24
//      If this value is negative, the envelope will be smaller than the
//      dimensions of the child geometry
//      A single value can be passed for all sides, or a list can be 
//      used to give different x and y expansion values
//      (defaults to 0)
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
module prism_negative(aspect=undef, expansion=0, cut=false, model_is_3d=undef, iota=0.001, omega=9999)
{
    difference()
    {
        prism_envelope(aspect=aspect, expansion=expansion, cut=cut, model_is_3d=model_is_3d, iota=iota, omega=omega)
            children();
        children();
    }
}



// Generate a cylindrical envelope surrounding the child geometry
// An optional aspect can be specified to force the envelope to take a different 
// aspect ratio rather than stricly follow the child geometry
//
// parameters:
//  aspect - An optional aspect ratio to enforce on the envelope
//      if set, the envelope will be resized to the requested ratio
//      if left undefined, the envelope will wrap the underlying geometry
//      (defaults to undef)
//  expansion - the amount to extend the envelope beyond the bounds of the child 
//      geometry
//      So, for example, if expansion is set to 2 and a cube of size 20 is
//      passed in, the envelope will each have dimensions of 24
//      If this value is negative, the envelope will be smaller than the
//      dimensions of the child geometry
//      A single value can be passed for all sides, or a list can be 
//      used to give different x and y expansion values
//      (defaults to 0)
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
module cylinder_envelope(aspect=undef, expansion=0, cut=false, model_is_3d=undef, iota=0.001, omega=9999)
{
    module max_vertical_envelope()
    {
        square_envelope(expansion=expansion, cut=cut, model_is_3d=model_is_3d, iota=iota, omega=omega)
            rotate([90, 0, 0])
            children();

        square_envelope(expansion=expansion, cut=cut, model_is_3d=model_is_3d, iota=iota, omega=omega)
            rotate([90, 0, 0])
            rotate([0, 0, 90])
            children();
    }

    intersection()
    {
        linear_extrude(omega, center=true)
            circle_envelope(expansion=expansion, cut=cut, model_is_3d=model_is_3d, iota=iota)
            children();

        rotate([-90, 0, 0])
            linear_extrude(omega, center=true)
            scale([1+sqrt(2), 1])
            max_vertical_envelope()
            children();
    }
}



// Generate a cylindrical negative surrounding the child geometry
// An optional aspect can be specified to force the envelope to take a different 
// aspect ratio rather than stricly follow the child geometry
//
// parameters:
//  aspect - An optional aspect ratio to enforce on the envelope
//      if set, the envelope will be resized to the requested ratio
//      if left undefined, the envelope will wrap the underlying geometry
//      (defaults to undef)
//  expansion - the amount to extend the envelope beyond the bounds of the child 
//      geometry
//      So, for example, if expansion is set to 2 and a cube of size 20 is
//      passed in, the envelope will each have dimensions of 24
//      If this value is negative, the envelope will be smaller than the
//      dimensions of the child geometry
//      A single value can be passed for all sides, or a list can be 
//      used to give different x and y expansion values
//      (defaults to 0)
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
module cylinder_negative(aspect=undef, expansion=0, cut=false, model_is_3d=undef, iota=0.001, omega=9999)
{
    difference()
    {
        cylinder_envelope(aspect=aspect, expansion=expansion, cut=cut, model_is_3d=model_is_3d, iota=iota, omega=omega)
            children();
        children();
    }
}
