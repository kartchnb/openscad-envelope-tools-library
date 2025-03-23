/* [Test Parameters] */
// The test cell size (width and height)
Cell_Size = 75;
// The model file to use
Model_File_3D = "../test/test.stl";
// The render quality
Render_Quality = 32;

/* [Test Code] */
$fn = $fn != 0 ? $fn : Render_Quality;
include<../test/_test_grid.scad>

_envelope_tools_grid_layout([Cell_Size, Cell_Size], labels=["original", "prism_resize([50, 50])"], extrusion=1)
{
    _envelope_tools_row_layout([Cell_Size, Cell_Size], Model_File_3D, extrusion=1)
    {
        import(Model_File_3D);
        group() {prism_resize([Cell_Size*.75, Cell_Size*.75], model_is_3d=true) import(Model_File_3D);}
    }
}



include<common.scad>
use<axis_projection.scad>
use<envelope_2d.scad>
use<envelope_3d.scad>



module prism_resize(size=1, expansion=0, cut=false, model_is_3d=true)
{
    iota = 0.001;

    width = is_list(size) ? size.x : size;
    height = is_list(size) ? size.y : size;

    difference()
    {
        resize([width, height, 0], auto=true)
        {
            mirror([0, 0, 1])
            linear_extrude(iota)
            for (z_rot = [0, 90])
            rotate([0, 0, z_rot])
            overlapped_axis_projection([1, 1, 0], thickness=iota, expansion=expansion, cut=cut, model_is_3d=model_is_3d)
                children();
            
            children();
        }

        mirror([0, 0, 1])
            cube([width*2, height*2, iota*2], center=true);
    }
}
