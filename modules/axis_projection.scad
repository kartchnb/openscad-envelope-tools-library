/* [Test Parameters] */
// The test cell size (width and height)
Cell_Size = 300;
// The 2D model file to use
Model_File_2D = "../test/test.svg";
// The 3D model file to use
Model_File_3D = "../test/test.stl";
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
        group() { any_projection(model_is_3d=model_is_3d) import(model_file); %import(model_file); }
        group() { linear_extrude(20) any_projection(model_is_3d=model_is_3d) import(model_file); %import(model_file); }
        group() { axis_projection([1, 1, 1], model_is_3d=model_is_3d) import(model_file); %import(model_file); }
        group() { maximum_axis_projection([1, 1, 1], model_is_3d=model_is_3d) import(model_file); %import(model_file); }
        group() { minimum_axis_projection([1, 1, 0], model_is_3d=model_is_3d) import(model_file); %import(model_file); }
    }
}

_envelope_tools_grid_layout([Cell_Size, Cell_Size], labels=["original", "any_projection()", "linear_extrusion(10) any_projection()", "axis_projection([1, 1, 1])", "maximum_axis_projection([1, 1, 1])", "minimum_axis_projection([1, 1, 0])"])
{
    _envelope_tools_generate_col(Model_File_2D, [Cell_Size, Cell_Size], model_is_3d=false);
    _envelope_tools_generate_col(Model_File_3D, [Cell_Size, Cell_Size], model_is_3d=true);
}



include<common.scad>



// This module creates a projection of its child geometry, whether they are 2D or model_is_3d
// The standard projection() module ignores 2D geometry, which makes sense, 
// but this library benefits from having a more agnostic projection module
// so it can process 2D and model_is_3d geometry similarly.
// The downside to this is that a warning will be displayed when this module is
// used with model_is_3d children:
//  "Ignoring model_is_3d child object for 2D operation"
// This is harmless, but can be avoided by setting the model_is_3d parameter to true for 
// operations involving model_is_3d children
//
// parameters: 
//  cut - the same as the "cut" parameter in the standard projection module
//      (defaults to false)
//  model_is_3d - Used to manually specify that the children of this module are 3-dimensional
//      The operation will work either way, but if 3-dimensional children are
//      passed without model_is_3d being set to true, OpenSCAD will display a warning
//      The warning is harmless but may be annoying
//      (defaults to false)
module any_projection(cut=false, model_is_3d=false)
{
    // The standard projection command works for model_is_3d geometry
    projection(cut=cut)
        children();

    // Special projection for 2D geometry
    // If used with model_is_3d children, this operation will result in the following warning:
    //  "Ignoring model_is_3d child object for 2D operation"
    // This is not really a problem, other than it pollutes the error console
    if (model_is_3d == false)
        projection(cut=cut)
            linear_extrude(1) // Just need to extrude an arbitrary amount here
            children();
}



// This module creates a 2-dimensional "projection line" along the requested axis
// The projection line is, essentially, a projection of the underlying children 
// against the requested axis and will have the same height (or length, width)
// as the child geometry on that axis.  The thickness of the line can be specified.
//
// This is the magic sauce that ultimately allows an envelope to be generated 
// around the children.
// 
// parameters:
//  axes - the axes to generate for in the order [X, Y, Z]
//      Setting any axis value to 1 will cause the axis projection line to be 
//      generated for that axis
//      (defaults to just the x-axis)
//  thickness - the thickness of the line along the plane
//      (defaults to 1)
//  expansion - the distance to expand the line beyond the bounds of the child geometry
//      (defaults to 0)
//  solid - When set to true, the generated line will be solid
//      otherwise, the line may have gaps depending on the child geometry (especially text)
//      (defaults to true)
//  cut - the same as the "cut" parameter in the standard projection module
//      (defaults to false)
//  model_is_3d - Used to manually specify that the children of this module are 3-dimensional
//      (defaults to false)
module axis_projection(axes=[1, 0, 0], thickness=1, expansion=0, solid=true, cut=false, model_is_3d=false)
{
    module solidify(solid)
    {
        // Solidify the line, if that has been requested
        if (solid) hull() children();
        else children();
    }

    module expand(expansion)
    {
        // Handle positive expansion
        if (expansion >= 0)
            for(x_offset = [-expansion, expansion])
            translate([x_offset, 0])
            children(0);

        // Handle negative expansion (shrinking of the line)
        else
            intersection_for(x_offset = [expansion, -expansion])
            translate([x_offset, 0])
            children(0);
    }

    // Iterate over each possible axis
    for (params = [[axes.x, [0, 0, 0]], [axes.y, [0, 0, 90]], [axes.z, [0, 90, 0]]])
    {
        axis_requested = params[0];
        rot = params[1];

        // Create the projection against the requested axis
        if (!is_undef(axis_requested) && axis_requested > 0)
            rotate(-rot)                    // Rotate back into position
            solidify(solid)                 // Solidy the projection line, if requested
            expand(expansion)               // Expand the projection line, if requested
            projection()                    // Generate a 2d projection
            rotate([270, 0, 0])             // Rotate the extrusion perpendicular with the horizontal plane
            linear_extrude(thickness)       // Extrude the projection to make it model_is_3d
            any_projection(cut=cut, model_is_3d=model_is_3d)  // Create a projection whether the children are 2D or model_is_3d
            rotate(rot)                     // Rotate the child geometry to lay its requested axis along the x-axis
            children();                     // Generate the child geometry
    }
}



// Generates a line the length of the longest dimension of the child object.
// The line is drawn along the x axis.
//
// parameters:
//  axes - the axes to generate for in the order [X, Y, Z]
//      Setting any axis value to 1 will cause the axis projection line to be 
//      generated for that axis
//      (defaults to just the x-axis)
//  thickness - the thickness of the line along the plane
//      (defaults to 1)
//  expansion - the distance to expand the line beyond the bounds of the child geometry
//      (defaults to 0)
//  solid - When set to true, the generated line will be solid
//      otherwise, the line may have gaps depending on the child geometry (especially text)
//      (defaults to true)
//  cut - the same as the "cut" parameter in the standard projection module
//      (defaults to false)
//  model_is_3d - Used to manually specify that the children of this module are 3-dimensional
//      (defaults to false)
module maximum_axis_projection(axes=[1, 0, 0], thickness=1, expansion=0, solid=true, cut=false, model_is_3d=false)
{
    // Iterate over each possible axis
    for (params = [[axes.x, [0, 0, 0]], [axes.y, [0, 0, 90]], [axes.z, [0, 90, 0]]])
    {
        axis_requested = params[0];
        rot = params[1];

        // Generate the projection line of the requested axis and align it to the x-axis
        if (!is_undef(axis_requested) && axis_requested > 0)
            axis_projection([1, 0, 0], thickness=thickness, expansion=expansion, solid=solid, cut=cut, model_is_3d=model_is_3d) rotate(rot) children();
    }
}



// Retained for backwards compatibility
module overlapped_axis_projection(axes=[1, 0, 0], thickness=1, expansion=0, solid=true, cut=false, model_is_3d=false)
{
    echo("WARNING: This module is depricated and should be replaced with maximum_axis_projection")
    maximum_axis_projection(axes=axes, thickness=thickness, expansion=expansion, solid=solid, cut=cut, model_is_3d=model_is_3d);
}



// Generates a line the length of the shortest dimension of the child object.
// The line is drawn along the x axis.
//
// parameters:
//  axes - the axes to generate for in the order [X, Y, Z]
//      Setting any axis value to 1 will cause the axis projection line to be 
//      generated for that axis
//      (defaults to just the x-axis)
//  thickness - the thickness of the line along the plane
//      (defaults to 1)
//  expansion - the distance to expand the line beyond the bounds of the child geometry
//      (defaults to 0)
//  solid - When set to true, the generated line will be solid
//      otherwise, the line may have gaps depending on the child geometry (especially text)
//      (defaults to true)
//  cut - the same as the "cut" parameter in the standard projection module
//      (defaults to false)
//  model_is_3d - Used to manually specify that the children of this module are 3-dimensional
//      (defaults to false)
module minimum_axis_projection(axes=[1, 0, 0], thickness=1, expansion=0, solid=true, cut=false, model_is_3d=false)
{
    // Iterate over each possible axis
    intersection_for (params = [[axes.x, [0, 0, 0]], [axes.y, [0, 0, 90]], [axes.z, [0, 90, 0]]])
    {
        axis_requested = params[0];
        rot = params[1];

        // Generate the projection line of the requested axis and align it to the x-axis
        if (!is_undef(axis_requested) && axis_requested > 0)
            axis_projection([1, 0, 0], thickness=thickness, expansion=expansion, solid=solid, cut=cut, model_is_3d=model_is_3d) rotate(rot) children();
    }
}
