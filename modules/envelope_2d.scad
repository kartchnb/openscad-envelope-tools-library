/* [Test Parameters] */
// The size of each test cell
Cell_Size = 400;
// The 2D model file
Model_File_2D = "../test/test.svg";
// The render quality
Render_Quality = 32;

/* [Test Code] */
$fn = $fn != 0 ? $fn : Render_Quality;
include<../test/_test_grid.scad>

_envelope_tools_grid_layout([Cell_Size, Cell_Size], labels=["original", "square_envelope()", "square_envelope(aspect=[1, 1])", "square_envelope(aspect=[2, 1])", "square_envelope(aspect=[1, 2])", "square_envelope(expansion=[0, 50])", "square_envelope(expansion=[50, 0])", "square_negative()", "square_frame()", "circle_envelope()", "circle_envelope(expansion=50)", "circle_negative()", "circle_frame()"])
{
    _envelope_tools_row_layout([Cell_Size, Cell_Size], Model_File_2D)
    {
        import(Model_File_2D);
        group() { square_envelope() import(Model_File_2D); %import(Model_File_2D); }
        group() { square_envelope(aspect=[1, 1]) import(Model_File_2D); %import(Model_File_2D); }
        group() { square_envelope(aspect=[2, 1]) import(Model_File_2D); %import(Model_File_2D); }
        group() { square_envelope(aspect=[1, 2]) import(Model_File_2D); %import(Model_File_2D); }
        group() { square_envelope(expansion=[0, 50]) import(Model_File_2D); %import(Model_File_2D); }
        group() { square_envelope(expansion=[50, 0]) import(Model_File_2D); %import(Model_File_2D); }
        group() { square_negative() import (Model_File_2D); %import(Model_File_2D); }
        group() { square_frame(frame=10) import(Model_File_2D); %import(Model_File_2D); }
        group() { circle_envelope() import(Model_File_2D); %import(Model_File_2D); }
        group() { circle_envelope(expansion=50) import(Model_File_2D); %import(Model_File_2D); }
        group() { circle_negative() import (Model_File_2D); %import(Model_File_2D); }
        group() { circle_frame(frame=10) import(Model_File_2D); %import(Model_File_2D); }
    }
}



include<common.scad>
use<axis_projection.scad>



// Generate a rectangular envelope surrounding the child geometry
// An optional aspect can be specified to force the envelope to take a different 
// aspect ratio rather than stricly follow the child geometry
//
// parameters:
//  aspect - An optional aspect ratio to enforce on the envelope
//      if set, the envelope will be resized to the requested ratio
//      if left undefined, the envelope will wrap the underlying geometry
//      (defaults to undef)
//  expansion - an additional amount to add to the envelope
//      a single value can be passed for all sides, or a list can be 
//      used to give different x and y expansion values
//      (defaults to 0)
//  cut - serves the same purpose as the cut option in the projection() function
//      (defaults to false)
//  model_is_3d - Used to manually specify that the children of this module are 3-dimensional
//      (defaults to false)
//  max_envelope - a maximum length for a single size of the envelope
//      this should not normally need to be changed unless you are generating
//      *very* large models
module square_envelope(aspect=undef, expansion=0, cut=false, model_is_3d=false, max_envelope=_envelope_tools_default_max_envelope)
{
    // Calculate the aspect ratio
    x_aspect = is_undef(aspect) ? undef 
        : is_list(aspect) ? aspect.x : aspect;
    y_aspect = is_undef(aspect) ? undef 
        : is_list(aspect) ? aspect.y : aspect;
    min_dimension = is_undef(aspect) ? undef : min(x_aspect, y_aspect);
    x_ratio = is_undef(aspect) ? undef : x_aspect / min_dimension;
    y_ratio = is_undef(aspect) ? undef : y_aspect / min_dimension;

    // Calculate the expansion to add to the envelope
    x_expansion = is_list(expansion) ? expansion.x : expansion;
    y_expansion = is_list(expansion) ? expansion.y : expansion;

    module generate_axis_projection(aspect, expansion, cut, model_is_3d)
    {
        // If no aspect is being enforced (aspect is undefined), 
        // return the axis projection as-is
        if (is_undef(aspect)) 
        {
            axis_projection([1, 0, 0], expansion=expansion, cut=cut, model_is_3d=model_is_3d) children();
        }
        
        // If an aspect is being enforced, maximum or minimum of the x and y axial projections
        else
        {
            maximum_axis_projection([1, 1, 0], expansion=expansion, cut=cut, model_is_3d=model_is_3d) children();
        }
    }

    module scale_projection(ratio)
    {
        // Scale the axis projection (passed as a child), if needed
        if (!is_undef(ratio))
        {
            scale([ratio, 1]) children();
        }
        
        // Otherwise, leave the projection as-is
        else 
        {
            children();
        }
    }

    intersection_for(params = [[0, x_ratio, x_expansion], [90, y_ratio, y_expansion]])
    {
        z_rot = params[0];
        ratio = params[1];
        expansion = params[2];

        // Rotate the horizontal plane to run along the correct axis
        rotate([0, 0, -z_rot])
        // Project the plane into a 2d surface
        projection()
        // Rotate the vertical plane to run along the y axis
        rotate([90, 0, 0])
        // Extrude the axial projection up and down into a vertical plane
        linear_extrude(max_envelope, center=true)
        // Resize the axis projection to match the requested aspect
        scale_projection(ratio)
        // Generate an axis projection of the child geometry along the x axis
        generate_axis_projection(aspect, expansion, cut, model_is_3d)
        // Rotate so the desired axis of the child geometry is laying along the x axis
        rotate([0, 0, z_rot])
            // generate the child geometry
            children();
    }
}



// Generate a negative of the underlying child geometry within a rectangular envelope
// An optional aspect can be specified to force the envelope to take a different 
// aspect ratio rather than stricly follow the child geometry
//
// parameters:
//  aspect - An optional aspect ratio to enforce on the envelope
//      if set, the envelope will be resized to the requested ratio
//      if left undefined, the envelope will wrap the underlying geometry
//      (defaults to undef)
//  expansion - an additional amount to add to the envelope
//      a single value can be passed for all sides, or a list can be 
//      used to give different x and y expansion values
//      (defaults to 0)
//  cut - serves the same purpose as the cut option in the projection() function
//      (defaults to false)
//  model_is_3d - Used to manually specify that the children of this module are 3-dimensional
//      (defaults to false)
//  max_envelope - a maximum length for a single size of the envelope
//      this should not normally need to be changed unless you are generating
//      *very* large models
module square_negative(aspect=undef, expansion=0, cut=false, model_is_3d=false, max_envelope=_envelope_tools_default_max_envelope)
{
    difference()
    {
        square_envelope(aspect=aspect, expansion=expansion, cut=cut, model_is_3d=model_is_3d, max_envelope=max_envelope)
            children();
        any_projection(cut=cut, model_is_3d=model_is_3d)
            children();
    }
}



// Generates a 2-dimensional frame (like a picture frame) around the underlying geometry.
// 
// parameters:
//  aspect - An optional aspect ratio to enforce on the envelope
//      if set, the envelope will be resized to the requested ratio
//      if left undefined, the envelope will wrap the underlying geometry
//      (defaults to undef)
//  expansion - an additional amount to add to the envelope
//      a single value can be passed for all sides, or a list can be 
//      used to give different x and y expansion values
//      (defaults to 0)
//  frame - an additional frame to add to the envelope
//      a single value can be passed for all framee, or a list can be 
//      used to give different x and y frame values
//      (defaults to 1)
//  cut - serves the same purpose as the cut option in the projection() function
//      (defaults to false)
//  model_is_3d - Used to manually specify that the children of this module are 3-dimensional
//      (defaults to false)
//  max_envelope - a maximum length for a single size of the envelope
//      this should not normally need to be changed unless you are generating
//      *very* large models
module square_frame(aspect=undef, frame=1, expansion=0, cut=false, model_is_3d=false, max_envelope=_envelope_tools_default_max_envelope)
{
    frame_x = is_list(frame) ? frame.x : frame;
    frame_y = is_list(frame) ? frame.y : frame;
    expansion_x = is_list(expansion) ? expansion.x : expansion;
    expansion_y = is_list(expansion) ? expansion.y : expansion;

    inner_expansion = [expansion_x, expansion_y];
    outer_expansion = inner_expansion + [frame_x, frame_x];

    difference()
    {
        square_envelope(aspect=aspect, expansion=outer_expansion, cut=cut, model_is_3d=model_is_3d, max_envelope=max_envelope) 
            children();
        square_envelope(aspect=aspect, expansion=inner_expansion, cut=cut, model_is_3d=model_is_3d, max_envelope=max_envelope) 
            children();
    }
}



// Generate a circular envelope surrounding the child geometry
// For now, the envelope must be a strict circle
//
// parameters:
//  expansion - an additional amount to add to the envelope
//      unlike square_envelope, this must be a single value
//      (defaults to 0)
//  cut - serves the same purpose as the cut option in the projection() function
//      (defaults to false)
//  model_is_3d - Used to manually specify that the children of this module are 3-dimensional
//      (defaults to false)
module circle_envelope(expansion=0, cut=false, model_is_3d=false)
{
    hull()
    for (z_rot = [0: $fa: 360 - $fa])
    rotate([0, 0, z_rot])
    for (x_offset = [-expansion, expansion])
    translate([x_offset, 0])
    any_projection(cut=cut, model_is_3d=model_is_3d)
        children();
}



// Generate a negative of the underyling children in a circular envelope
// For now, the envelope must be a strict circle
//
// parameters:
//  expansion - an additional amount to add to the envelope
//      unlike square_envelope, this must be a single value
//      (defaults to 0)
//  cut - serves the same purpose as the cut option in the projection() function
//      (defaults to false)
//  model_is_3d - Used to manually specify that the children of this module are 3-dimensional
//      (defaults to false)
module circle_negative(expansion=0, cut=false, model_is_3d=false)
{
    difference()
    {
        circle_envelope(expansion=expansion, cut=cut, model_is_3d=model_is_3d)
            children();
        children();
    }
}



// Generate a 2-dimensional circular frame around the underyling children
// For now, the envelope must be a strict circle
//
// parameters:
//  frame - the width of the frame
//      (defaults to 1)
//  expansion - an additional amount to add to the envelope
//      unlike square_envelope, this must be a single value
//      (defaults to 0)
//  cut - serves the same purpose as the cut option in the projection() function
//      (defaults to false)
//  model_is_3d - Used to manually specify that the children of this module are 3-dimensional
//      (defaults to false)
module circle_frame(frame=1, expansion=0, cut=false, model_is_3d=false)
{
    frame = is_list(frame) ? frame.x : frame;
    expansion = is_list(expansion) ? expansion.x : expansion;

    inner_expansion = expansion;
    outer_expansion = inner_expansion + frame;

    difference()
    {
        circle_envelope(expansion=outer_expansion, cut=cut, model_is_3d=model_is_3d)
            children();
        circle_envelope(expansion=inner_expansion, cut=cut, model_is_3d=model_is_3d)
            children();
    }
}

