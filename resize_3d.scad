include<common.scad>
use<axis_projection.scad>
use<envelope_2d.scad>
use<envelope_3d.scad>



module prism_resize(size=1, expansion=0, cut=false, 3d=false)
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
            overlapped_axis_projection([1, 1, 0], thickness=iota, expansion=expansion, cut=cut, 3d=3d)
                children();
            
            children();
        }

        mirror([0, 0, 1])
            cube([width*2, height*2, iota*2], center=true);
    }
}



//----------------------------------------------------------------------------
// Test code
echo("EnvelopeTools: If this message is showing up in your model, you need to <use> the library rather than <include> it");

include<test/_test_grid.scad>

3d_Model_File = "test/test.stl";
Cell_Size = [75, 75];

_envelope_tools_grid_layout(Cell_Size, labels=["original", "prism_resize([50, 50])"], extrusion=1)
{
    _envelope_tools_row_layout(Cell_Size, 3d_Model_File, extrusion=1)
    {
        import(3d_Model_File);
        group() {prism_resize([50, 50], 3d=true) import(3d_Model_File);}
    }
}
