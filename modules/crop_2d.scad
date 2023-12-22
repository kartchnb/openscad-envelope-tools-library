/* [Test Parameters] */
// The test cell size (width and height)
Cell_Size = 75;
// The model file to use
2d_Model_File = "../test/test.svg";
// The render quality
Render_Quality = 32;

/* [Test Code] */
$fn = $fn != 0 ? $fn : Render_Quality;
include<../test/_test_grid.scad>

/*
_envelope_tools_grid_layout([Cell_Size, Cell_Size], labels=["original", "square_resize([50, 50])", "square_resize([25, 50])", "square_resize([50, 25])", "square_resize([10, 50])", "square_resize([25, 50], maximize=true)", "circle_resize(d=50)", "square_resize([10, 50], expansion=20)"])
{
    _envelope_tools_row_layout([Cell_Size, Cell_Size], 2d_Model_File)
    {
        import(2d_Model_File);
        group() {square_resize([50, 50]) import(2d_Model_File); %square([50, 50], center=true);}
        group() {square_resize([25, 50]) import(2d_Model_File); %square([25, 50], center=true);}
        group() {square_resize([50, 25]) import(2d_Model_File); %square([50, 25], center=true);}
        group() {square_resize([10, 50]) import(2d_Model_File); %square([10, 50], center=true);}
        group() {square_resize([25, 50], maximize=true) import(2d_Model_File); %square([25, 50], center=true);}
        group() {circle_resize(d=50) import(2d_Model_File); %circle(d=50);}
        group() {square_resize([50, 50], expansion=20) import(2d_Model_File); %square([50, 50], center=true);}
    }
}
*/



use <envelope_2d.scad>



module square_crop(aspect=undef, cut=false, 3d=false, max_envelope=_envelope_tools_default_max_envelope)
{
    intersection()
    {
        children();
        square_envelope(aspect=aspect, cut=cut, 3d=3d, max_envelope=max_envelope)
            children();
    }
}