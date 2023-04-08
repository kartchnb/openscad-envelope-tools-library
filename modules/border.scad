// Generate a border around the underlying children geometries
//
module border(thickness=1, expansion=0, corner="standard")
{
    module expand(thickness, corner)
    {
        if (corner == "round")
            offset(r=thickness)
                children();

        else if (corner == "chamfer")
            offset(delta=thickness, chamfer=true)
                children();

        else
            offset(delta=thickness)
                children();
    }



    module process_children(expansion, corner)
    {
        if (corner == "round")
            offset(r=expansion)
                children();

        else if (corner == "chamfer")
            offset(delta=expansion, chamfer=true)
                children();

        else
            offset(delta=expansion)
                children();
    }



    if (thickness > 0)
        difference()
        {
            expand(thickness=thickness, corner=corner)
                process_children(expansion=expansion, corner=corner)
                children();
            process_children(expansion=expansion, corner=corner)
                children();
        }
    
    else if (thickness < 0)
        difference()
        {
            process_children(expansion=expansion, corner=corner)
                children();
            expand(thickness=thickness, corner=corner)
                process_children(expansion=expansion, corner=corner)
                children();
        }
    
    else
    {
        children();
    }
}



//----------------------------------------------------------------------------
// Test code
echo("EnvelopeTools: If this message is showing up in your model, you need to <use> the library rather than <include> it");

include<../test/_test_grid.scad>

2d_Model_File = "../test/test.svg";
Cell_Size = [75, 75];

labels = 
[
    "original", 
    "border(2)", "border(2, 0, \"round\")", "border(2, 0, \"chamfer\")", 
    "border(-2)", "border(-2, 0, \"round\")", "border(-2, 0, \"chamfer\")",
    "border(2, 2)", "border(2, 2, \"round\")", "border(2, 2, \"chamfer\")", 
    "border(2, -2)", "border(2, -2, \"round\")", "border(2, -2, \"chamfer\")", 
];

_envelope_tools_grid_layout(Cell_Size, labels=labels)
{
    _envelope_tools_row_layout(Cell_Size, 2d_Model_File)
    {
        import(2d_Model_File);
        group() {border(2) import(2d_Model_File);}
        group() {border(2, 0, "round") import(2d_Model_File);}
        group() {border(2, 0, "chamfer") import(2d_Model_File);}
        
        group() {border(-2) import(2d_Model_File);}
        group() {border(-2, 0, "round") import(2d_Model_File);}
        group() {border(-2, 0, "chamfer") import(2d_Model_File);}

        group() {border(2, 2) import(2d_Model_File);}
        group() {border(2, 2, "round") import(2d_Model_File);}
        group() {border(2, 2, "chamfer") import(2d_Model_File);}

        group() {border(2, -2) import(2d_Model_File);}
        group() {border(2, -2, "round") import(2d_Model_File);}
        group() {border(2, -2, "chamfer") import(2d_Model_File);}
    }
}
