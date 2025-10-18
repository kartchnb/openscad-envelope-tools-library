/* [Test Parameters] */
// The test cell size (width and height)
Cell_Size = 300;
// The 2D model file to use
Model_File_2D = "../test/test.svg";
// The 3D model file to use
Model_File_3D = "../test/test.stl";
// The value to use for iota
Iota = 5;
// The render quality
Render_Quality = 32;

/* [Test Code] */
$fn = $fn > 0 ? $fn : Render_Quality;
include<../test/_test_grid.scad>

module _envelope_tools_generate_col(model_file, cell_size, model_is_3d)
{
    _envelope_tools_row_layout(cell_size, model_file)
    {
        import(model_file);
        group() { any_projection(model_is_3d=model_is_3d, iota=Iota) import(model_file); %import(model_file); }
        group() { linear_extrude(20) any_projection(model_is_3d=model_is_3d, iota=Iota) import(model_file); %import(model_file); }
        group() { axis_projection(axes=[1, 1, 1], model_is_3d=model_is_3d, iota=Iota) import(model_file); %import(model_file); }
        group() { axis_projection(axes=[1, 1, 1], expansion=50, model_is_3d=model_is_3d, iota=Iota) import(model_file); %import(model_file); }
        group() { maximum_axis_projection(axes=[1, 1, 1], model_is_3d=model_is_3d, iota=Iota) import(model_file); %import(model_file); }
        group() { minimum_axis_projection(axes=[1, 1, 0], model_is_3d=model_is_3d, iota=Iota) import(model_file); %import(model_file); }
    }
}

_envelope_tools_grid_layout([Cell_Size, Cell_Size], labels=["original", "any_projection()", "linear_extrusion(10) any_projection()", "axis_projection([1, 1, 1])", "axis_projection([1, 1, 1] expansion=50)", "maximum_axis_projection([1, 1, 1])", "minimum_axis_projection([1, 1, 0])"])
{
    _envelope_tools_generate_col(Model_File_2D, [Cell_Size, Cell_Size], model_is_3d=false);
    _envelope_tools_generate_col(Model_File_3D, [Cell_Size, Cell_Size], model_is_3d=true);
}



// This module creates a projection of its child geometry, whether they are 2D 
// or 3D
// The standard projection() module ignores 2D geometry, which makes sense, 
// but this library benefits from having a more agnostic projection module and
// create projections of 2D or 3D geometry.
//
// parameters: 
//  cut - the same as the "cut" parameter in the standard projection module
//      (defaults to false, same as the standard cut module)
//  model_is_3d - Used to manually specify whether the children of this module 
//      are 3-dimensional
//      WARNING: Setting this incorrectly for the underlying geometry will
//      break the function
//      When in doubt, leave it unset
//      (defaults to undef, which will handle any geometry but will always
//      display a warning)
//  iota - a tiny value used for extruding 2D geometry
//      (defaults to 0.001)
//
// NOTE: This module will function correctly in every instance if 
// model_is_3d is left unset.
//
// However, if 2D geometry is passed in without setting model_is_3d to false,
// the following warnings will be displayed:
//      "Mixing 2D and 3D objects is not supported"
//      "Ignoring 2D child object for 3D operation"
//
// And, if 3D geometry is passed in without setting model_is_3d to true, the 
// following warning will be displayed:
//      "Ignoring 3D child object for 2D operation"
//
// These warnings are harmless, but clutter the error window.
//
// WARNING: Trying to use this with 2D geometry and model_is_3d set to true, or 
// 3D geometry with model_is_3d set to false will NOT work.
// 
// If in doubt, leave model_is_3d unset and ignore the error messages.
module any_projection(cut=false, model_is_3d=undef, iota=0.001)
{
    // Conditionally extrudes geometry into a 3D object so that it can be
    // projected
    //
    // Obviously, 2D geometry is already a projection
    // However, a new projection is made here so that 3D geometry will not be
    // ignored if model_is_3d is set to undef
    module make_3d()
    {
        if (model_is_3d != true)
        {
            linear_extrude(iota)
                children();
        }

        if (model_is_3d != false)
        {
            children();
        }
    }



    // Create the projection
    projection()
        make_3d()
        children();
}



// This module creates a 2-dimensional "projection line" along one or more axes. 
// The projection lines are, essentially, projections of the underlying 
// children  against the requested axes.
// These lines will have the same dimension (height, length,  or width) as the
// child geometry along that axis.
//
// This is the magic sauce that ultimately allows an envelope to be generated 
// around the children.
// 
// parameters:
//  axes - the axes to generate for in the order [X, Y, Z]
//      Setting any axis value to 1 will cause the axis projection line to be 
//      generated for that axis
//      Requesting a Z axis projection of 2D geometry will result in the
//      following error being displayed:
//          "Scaling a 2D object with 0 - removing object"
//      This warning is harmless but can be ignored
//      (defaults to just the x-axis)
//  expansion - the amount to extend the line beyond the bounds of the child 
//      geometry
//      So, for example, if expansion is set to 2 and a cube of size 20 is
//      passed in, the projected lines will each have a dimension of 24
//      If this value is negative, the projected line will be shorter than the
//      corresponding dimension of the child geometry
//      (defaults to 0)
//  solid - When set to true, the generated line will be solid otherwise, the
//      line may have gaps depending on the child geometry
//      This is most relevant to removing spaces between letters when used with
//      text
//      (defaults to true)
//  cut - the same as the "cut" parameter in the standard projection module
//      (defaults to false, same as the standard cut module)
//  model_is_3d - Used to manually specify whether the children of this module 
//      are 3-dimensional
//      WARNING: Setting this incorrectly for the underlying geometry will
//      break the function
//      When in doubt, leave it unset
//      (defaults to undef, which will handle any geometry but will always
//      display a warning)
//  iota - a tiny value used for extruding 2D geometry
//      (defaults to 0.001)
module axis_projection(axes=[1, 0, 0], expansion=0, solid=true, cut=false, model_is_3d=undef, iota=0.001)
{
    // Uses hull to fill in gaps in projection lines, if requested
    module solidify(solid=false)
    {
        // Solidify the line, if that has been requested
        if (solid)
        {
            hull() 
                children();
        }
        else
        {
            children();
        }
    }

    // Extends (or shrinks) the projected line a certain amount beyond the 
    // dimensions of the child geometry
    module expand(expansion=0)
    {
        // Handle positive expansion
        if (expansion >= 0)
        {
            for(x_offset = [-expansion, expansion])
            {
                translate([x_offset, 0])
                    children();
            }
        }

        // Handle negative expansion (shrinking of the line)
        else
        {
            intersection_for(x_offset = [expansion, -expansion])
            {
                translate([x_offset, 0])
                    children();
            }
        }
    }

    // Iterate over each possible axis
    for (params = 
        [
            [axes.x > 0, [0, 0, 0]], 
            [axes.y > 0, [0, 0, 90]], 
            [axes.z > 0 && model_is_3d != false, [0, 90, 0]]
        ])
    {
        axis_requested = params[0];
        rotation = params[1];

        // Create the projection against the requested axis
        if (axis_requested)
        {
            // Rotate the line back to the correct axis
            rotate(-rotation)
                // Solidify the projection line, if requested
                solidify(solid)
                // Extend (or shrink) the projection line, if requested
                expand(expansion)
                // Generate the projected line
                projection()
                // Rotate the extrusion perpendicular with the horizontal plane
                rotate([270, 0, 0])
                // Extrude the projection to make it 3D
                linear_extrude(iota)
                // Create a projection of the underlying geometry
                any_projection(cut=cut, model_is_3d=model_is_3d, iota=iota)
                // Rotate the child geometry to lay the requested axis along the
                // global x-axis
                rotate(rotation)
                // Generate the child geometry
                children();
        }
    }
}



// Generates a line the length of the longest dimension of the child object.
// The line is drawn along the x axis.
//
// parameters:
//  axes - the axes to generate for in the order [X, Y, Z]
//      Setting any axis value to 1 will cause the axis projection line to be 
//      generated for that axis
//      Requesting a Z axis projection of 2D geometry will result in the
//      following error being displayed:
//          "Scaling a 2D object with 0 - removing object"
//      This warning is harmless but can be ignored
//      (defaults to just the x-axis)
//  expansion - the amount to extend the line beyond the bounds of the child 
//      geometry
//      So, for example, if expansion is set to 2 and a cube of size 20 is
//      passed in, the projected lines will each have a dimension of 24
//      If this value is negative, the projected line will be shorter than the
//      corresponding dimension of the child geometry
//      (defaults to 0)
//  solid - When set to true, the generated line will be solid otherwise, the
//      line may have gaps depending on the child geometry
//      This is most relevant to removing spaces between letters when used with
//      text
//      (defaults to true)
//  cut - the same as the "cut" parameter in the standard projection module
//      (defaults to false, same as the standard cut module)
//  model_is_3d - Used to manually specify whether the children of this module 
//      are 3-dimensional
//      WARNING: Setting this incorrectly for the underlying geometry will
//      break the function
//      When in doubt, leave it unset
//      (defaults to undef, which will handle any geometry but will always
//      display a warning)
//  iota - a tiny value used for extruding 2D geometry
//      (defaults to 0.001)
module maximum_axis_projection(axes=[1, 0, 0], expansion=0, solid=true, cut=false, model_is_3d=undef, iota=0.001)
{
    // Iterate over each possible axis
    for (params = 
        [
            [axes.x > 0, [0, 0, 0]], 
            [axes.y > 0, [0, 0, -90]], 
            [axes.z > 0 && model_is_3d != false, [0, 90, 0]]
        ])
    {
        axis_requested = params[0];
        rot = params[1];

        // Generate the projection line of the requested axis and align it to 
        // the x-axis
        if (axis_requested)
        {
            axis_projection([1, 0, 0], expansion=expansion, solid=solid, cut=cut, model_is_3d=model_is_3d, iota=iota) rotate(rot) children();
        }
    }
}



// Generates a line the length of the shortest dimension of the child object.
// The line is drawn along the x axis.
//
// parameters:
//  axes - the axes to generate for in the order [X, Y, Z]
//      Setting any axis value to 1 will cause the axis projection line to be 
//      generated for that axis
//      Requesting a Z axis projection of 2D geometry will result in the
//      following error being displayed:
//          "Scaling a 2D object with 0 - removing object"
//      This warning is harmless but can be ignored
//      (defaults to just the x-axis)
//  expansion - the amount to extend the line beyond the bounds of the child 
//      geometry
//      So, for example, if expansion is set to 2 and a cube of size 20 is
//      passed in, the projected lines will each have a dimension of 24
//      If this value is negative, the projected line will be shorter than the
//      corresponding dimension of the child geometry
//      (defaults to 0)
//  solid - When set to true, the generated line will be solid otherwise, the
//      line may have gaps depending on the child geometry
//      This is most relevant to removing spaces between letters when used with
//      text
//      (defaults to true)
//  cut - the same as the "cut" parameter in the standard projection module
//      (defaults to false, same as the standard cut module)
//  model_is_3d - Used to manually specify whether the children of this module 
//      are 3-dimensional
//      WARNING: Setting this incorrectly for the underlying geometry will
//      break the function
//      When in doubt, leave it unset
//      (defaults to undef, which will handle any geometry but will always
//      display a warning)
//  iota - a tiny value used for extruding 2D geometry
//      (defaults to 0.001)
module minimum_axis_projection(axes=[1, 0, 0], expansion=0, solid=true, cut=false, model_is_3d=undef, iota=0.001)
{
    // Iterate over each possible axis
    intersection_for (params = 
        [
            [axes.x > 0, [0, 0, 0]], 
            [axes.y > 0, [0, 0, -90]], 
            [axes.z > 0 && model_is_3d != false, [0, 90, 0]]
        ])
    {
        axis_requested = params[0];
        rot = params[1];

        // Generate the projection line of the requested axis and align it to the x-axis
        if (axis_requested)
        {
            axis_projection([1, 0, 0], expansion=expansion, solid=solid, cut=cut, model_is_3d=model_is_3d, iota=iota) 
                rotate(rot) 
                children();
        }
    }
}
