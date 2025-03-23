/* [Test Parameters] */
// The size of each test cell
Cell_Size = 125;
// The 2D model file
Model_File_3D = "../test/test.stl";
// The render quality
Render_Quality = 32;

/* [Test Code] */
$fn = $fn != 0 ? $fn : Render_Quality;
include<../test/_test_grid.scad>

_envelope_tools_grid_layout([Cell_Size, Cell_Size], labels=["original", "prism_envelope()", "prism_negative()", "cylinder_envelope()", "cylinder_negative()"], extrusion=1)
{
    _envelope_tools_row_layout([Cell_Size, Cell_Size], label=Model_File_3D, extrusion=1)
    {
        import(Model_File_3D);
        group() { prism_envelope(model_is_3d=true) import(Model_File_3D); %import(Model_File_3D); }
        intersection() { prism_negative(model_is_3d=true) import(Model_File_3D); cube(_envelope_tools_default_max_envelope); }
        group() { cylinder_envelope(model_is_3d=true) import(Model_File_3D); %import(Model_File_3D); }
        intersection() { cylinder_negative(model_is_3d=true) import(Model_File_3D); cube(_envelope_tools_default_max_envelope); }
    }
}



include<common.scad>
use<envelope_2d.scad>



module prism_envelope(aspect=undef, expansion=0, cut=false, model_is_3d=true, max_envelope=_envelope_tools_default_max_envelope)
{
    x_expansion = is_list(expansion) ? expansion.x : expansion;
    y_expansion = is_list(expansion) ? expansion.y : expansion;
    z_expansion = is_list(expansion) ? expansion.z : expansion;

    intersection()
    {
        linear_extrude(max_envelope, center=true)
            square_envelope(aspect=aspect, expansion=[x_expansion, y_expansion], cut=cut, model_is_3d=model_is_3d, max_envelope=max_envelope)
            children();

        rotate([-90, 0, 0])
            linear_extrude(max_envelope, center=true)
            square_envelope(expansion=[x_expansion, z_expansion], cut=cut, model_is_3d=model_is_3d, max_envelope=max_envelope)
            rotate([90, 0, 0])
            children();
    }
}



module prism_negative(aspect=undef, expansion=0, cut=false, model_is_3d=true, max_envelope=_envelope_tools_default_max_envelope)
{
    difference()
    {
        prism_envelope(aspect=aspect, expansion=expansion, cut=cut, model_is_3d=model_is_3d, max_envelope=max_envelope)
            children();
        children();
    }
}



module cylinder_envelope(aspect=undef, expansion=0, cut=false, model_is_3d=true, max_envelope=_envelope_tools_default_max_envelope)
{
    module max_vertical_envelope(expansion, cut, model_is_3d, max_envelope)
    {
        square_envelope(expansion=expansion, cut=cut, model_is_3d=model_is_3d, max_envelope=max_envelope)
        rotate([90, 0, 0])
            children();

        square_envelope(expansion=expansion, cut=cut, model_is_3d=model_is_3d, max_envelope=max_envelope)
        rotate([90, 0, 0])
        rotate([0, 0, 90])
            children();
    }

    intersection()
    {
        linear_extrude(max_envelope, center=true)
        circle_envelope(expansion=expansion, cut=cut, model_is_3d=model_is_3d)
            children();

        rotate([-90, 0, 0])
        linear_extrude(max_envelope, center=true)
        scale([1+sqrt(2), 1])
        max_vertical_envelope(expansion, cut, model_is_3d, max_envelope)
            children();
    }
}



module cylinder_negative(aspect=undef, expansion=0, cut=false, model_is_3d=true, max_envelope=_envelope_tools_default_max_envelope)
{
    difference()
    {
        cylinder_envelope(aspect=aspect, expansion=expansion, cut=cut, model_is_3d=model_is_3d, max_envelope=max_envelope)
            children();
        children();
    }
}
