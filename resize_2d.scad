include<common.scad>
use<envelope_2d.scad>



module square_resize(size=1, expansion=0, cut=false, 3d=false, max_envelope=_envelope_tools_default_max_envelope)
{
    width = is_list(size) ? size.x : size;
    height = is_list(size) ? size.y : size;

    min_dimension = min(width, height);
    x_ratio = min_dimension/width;
    y_ratio = min_dimension/height;

    difference()
    {
        resize([width, height])
            square_envelope(aspect=[1, 1], 3d=3d, max_envelope=max_envelope)
            scale([x_ratio, y_ratio])
            children();
        resize([width, height])
            square_negative(aspect=[1, 1], 3d=3d, max_envelope=max_envelope)
            scale([x_ratio, y_ratio])
            children();
    }
}



module circle_resize(r=1, d=undef, expansion=0, cut=false, 3d=false)
{
    width = is_undef(d) ? r*2 : d;
    height = width;

    difference()
    {
        resize([width, height])
            circle_envelope(expansion=expansion, cut=cut, 3d=3d)
            children();
        resize([width, height])
            circle_negative(expansion=expansion, cut=cut, 3d=3d)
            children();
    }
}



//----------------------------------------------------------------------------
// Test code
echo("EnvelopeTools: If this message is showing up in your model, you need to <use> the library rather than <include> it");

include<test/_test_grid.scad>

2d_Model_File = "test/test.svg";
Cell_Size = [75, 75];

_envelope_tools_grid_layout(Cell_Size, labels=["original", "square_resize([50, 50])", "square_resize([25, 50])", "square_resize([50, 25])", "square_resize([10, 50])", "circle_resize(d=50)"])
{
    _envelope_tools_row_layout(Cell_Size, 2d_Model_File)
    {
        import(2d_Model_File);
        group() {square_resize([50, 50]) import(2d_Model_File); %square([50, 50], center=true);}
        group() {square_resize([25, 50]) import(2d_Model_File); %square([25, 50], center=true);}
        group() {square_resize([50, 25]) import(2d_Model_File); %square([50, 25], center=true);}
        group() {square_resize([10, 50]) import(2d_Model_File); %square([10, 50], center=true);}
        group() {circle_resize(d=50) import(2d_Model_File); %circle(d=50);}
    }
}
