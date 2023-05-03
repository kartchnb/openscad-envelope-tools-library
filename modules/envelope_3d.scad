include<common.scad>
use<envelope_2d.scad>



module prism_envelope(aspect=undef, expansion=0, cut=false, 3d=true, max_envelope=_envelope_tools_default_max_envelope)
{
    x_expansion = is_list(expansion) ? expansion.x : expansion;
    y_expansion = is_list(expansion) ? expansion.y : expansion;
    z_expansion = is_list(expansion) ? expansion.z : expansion;

    intersection()
    {
        linear_extrude(max_envelope, center=true)
            square_envelope(aspect=aspect, expansion=[x_expansion, y_expansion], cut=cut, 3d=3d, max_envelope=max_envelope)
            children();

        rotate([-90, 0, 0])
            linear_extrude(max_envelope, center=true)
            square_envelope(expansion=[x_expansion, z_expansion], cut=cut, 3d=3d, max_envelope=max_envelope)
            rotate([90, 0, 0])
            children();
    }
}



module prism_negative(aspect=undef, expansion=0, cut=false, 3d=true, max_envelope=_envelope_tools_default_max_envelope)
{
    difference()
    {
        prism_envelope(aspect=aspect, expansion=expansion, cut=cut, 3d=3d, max_envelope=max_envelope)
            children();
        children();
    }
}



module cylinder_envelope(aspect=undef, expansion=0, cut=false, 3d=true, max_envelope=_envelope_tools_default_max_envelope)
{
    module max_vertical_envelope(expansion, cut, 3d, max_envelope)
    {
        square_envelope(expansion=expansion, cut=cut, 3d=3d, max_envelope=max_envelope)
        rotate([90, 0, 0])
            children();

        square_envelope(expansion=expansion, cut=cut, 3d=3d, max_envelope=max_envelope)
        rotate([90, 0, 0])
        rotate([0, 0, 90])
            children();
    }

    intersection()
    {
        linear_extrude(max_envelope, center=true)
        circle_envelope(expansion=expansion, cut=cut, 3d=3d)
            children();

        rotate([-90, 0, 0])
        linear_extrude(max_envelope, center=true)
        scale([1+sqrt(2), 1])
        max_vertical_envelope(expansion, cut, 3d, max_envelope)
            children();
    }
}



module cylinder_negative(aspect=undef, expansion=0, cut=false, 3d=true, max_envelope=_envelope_tools_default_max_envelope)
{
    difference()
    {
        cylinder_envelope(aspect=aspect, expansion=expansion, cut=cut, 3d=3d, max_envelope=max_envelope)
            children();
        children();
    }
}



//----------------------------------------------------------------------------
// Test code
echo("EnvelopeTools: If this message is showing up in your model, you need to <use> the library rather than <include> it");

include<../test/_test_grid.scad>

3d_Model_File = "../test/test.stl";
Cell_Size = [125, 125];

_envelope_tools_grid_layout(Cell_Size, labels=["original", "prism_envelope()", "prism_negative()", "cylinder_envelope()", "cylinder_negative()"], extrusion=1)
{
    _envelope_tools_row_layout(cell_size=Cell_Size, label=3d_Model_File, extrusion=1)
    {
        import(3d_Model_File);
        group() { prism_envelope(3d=true) import(3d_Model_File); %import(3d_Model_File); }
        intersection() { prism_negative(3d=true) import(3d_Model_File); cube(_envelope_tools_default_max_envelope); }
        group() { cylinder_envelope(3d=true) import(3d_Model_File); %import(3d_Model_File); }
        intersection() { cylinder_negative(3d=true) import(3d_Model_File); cube(_envelope_tools_default_max_envelope); }
    }
}
