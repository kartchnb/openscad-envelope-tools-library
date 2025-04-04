/* [Test Parameters] */
// The test cell size (width and height)
Cell_Size = 75;
// The model file to use
Model_File_2D = "../test/test.svg";
// The render quality
Render_Quality = 32;

/* [Test Code] */
$fn = $fn != 0 ? $fn : Render_Quality;
include<../test/_test_grid.scad>

_envelope_tools_grid_layout([Cell_Size, Cell_Size], labels=["original", "square_resize([50, 50])", "square_resize([25, 50])", "square_resize([50, 25])", "square_resize([10, 50])"/*, "square_resize([25, 50], maximize=true)"*/, "circle_resize(d=50)", "square_resize([10, 50], expansion=20)"])
{
    _envelope_tools_row_layout([Cell_Size, Cell_Size], Model_File_2D)
    {
        import(Model_File_2D);
        group() {square_resize([50, 50]) import(Model_File_2D); %square([50, 50], center=true);}
        group() {square_resize([25, 50]) import(Model_File_2D); %square([25, 50], center=true);}
        group() {square_resize([50, 25]) import(Model_File_2D); %square([50, 25], center=true);}
        group() {square_resize([10, 50]) import(Model_File_2D); %square([10, 50], center=true);}
        group() {square_resize([25, 50], maximize=true) import(Model_File_2D); %square([25, 50], center=true);}
        group() {circle_resize(d=50) import(Model_File_2D); %circle(d=50);}
        group() {square_resize([50, 50], expansion=20) import(Model_File_2D); %square([50, 50], center=true);}
    }
}



include<common.scad>
use<envelope_2d.scad>



module square_resize(size=1, expansion=0, cut=false, model_is_3d=false, max_envelope=_envelope_tools_default_max_envelope)
{
    width = is_list(size) ? size.x : size;
    height = is_list(size) ? size.y : size;

    min_dimension = min(width, height);
    x_ratio = min_dimension/width;
    y_ratio = min_dimension/height;

    difference()
    {
        resize([width, height])
            square_envelope(aspect=[1, 1], expansion=expansion, cut=cut, model_is_3d=model_is_3d, max_envelope=max_envelope)
            scale([x_ratio, y_ratio])
            children();
        resize([width, height])
            square_negative(aspect=[1, 1], expansion=expansion, cut=cut, model_is_3d=model_is_3d, max_envelope=max_envelope)
            scale([x_ratio, y_ratio])
            children();
    }
}



module circle_resize(r=1, d=undef, expansion=0, cut=false, model_is_3d=false)
{
    width = is_undef(d) ? r*2 : d;
    height = width;

    difference()
    {
        resize([width, height])
            circle_envelope(expansion=expansion, cut=cut, model_is_3d=model_is_3d)
            children();
        resize([width, height])
            circle_negative(expansion=expansion, cut=cut, model_is_3d=model_is_3d)
            children();
    }
}
