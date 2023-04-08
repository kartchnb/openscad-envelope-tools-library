// Generate a border around the underlying children geometries
//
module border(thickness=1, corner="standard")
{
    module expand(thickness, corner)
    {
        if (corner == "round")
        {
            offset(r=thickness)
                children();
        }
        else if (corner == "chamfered")
        {
            offset(delta=thickness, chamfer=true)
                children();
        }
        else
        {
            offset(delta=thickness)
                children();
        }
    }

    if (thickness > 0)
        difference()
        {
            expand(thickness=thickness, corner=corner)
                children();
        }

    children();
}



//----------------------------------------------------------------------------
// Test code
echo("EnvelopeTools: If this message is showing up in your model, you need to <use> the library rather than <include> it");

include<../test/_test_grid.scad>

2d_Model_File = "../test/test.svg";
Cell_Size = [75, 75];

_envelope_tools_grid_layout(Cell_Size, labels=[""])
{
    _envelope_tools_row_layout(Cell_Size, 2d_Model_File)
    {
        import(2d_Model_File);
        group() {border(10) import(2d_Model_File);}
//        group() {square_resize([50, 50]) import(2d_Model_File); %square([50, 50], center=true);}
    }
}
