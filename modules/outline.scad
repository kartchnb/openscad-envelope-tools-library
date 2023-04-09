// Generate an outline of the underlying geometry
//
// parameters:
//  thickness - the thickness of the outline to generate
//  expansion - the amount to expand the outline from the edges of the child geometry
//      (may be positive or negative)
//  align - how to align the outline to the edges of the child geometry (defaults to "external")
//      "external" expands the outline outwards
//      "internal" creates an outline entirely within the bounds of the child geometry
//      "center" centers the outline on the bounds of the child geometry
//  style - the style of outline to generate (defaults to "standard")
//      "standard" follows the outline of the child geometry exactly
//      "round" rounds off corners of the child geometry
//      "chamfer" chamfers corners of the child geometry
module outline(thickness=1, expansion=0, align="external", style="standard")
{
    module generate_outline(offset, style)
    {
        if (style == "round")
            offset(r=offset)
                children();
        
        else if (style == "chamfer")
            offset(delta=offset, chamfer=true)
                children();

        else
            offset(delta=offset)
                children();
    }



    outer_offset = expansion + 
        (
            align == "internal" ? -thickness :
            align == "center" ? thickness/2 :
            thickness
        );

    inner_offset = outer_offset - thickness;

    if (thickness != 0)
    {
        difference()
        {
            generate_outline(offset=outer_offset, style=style)
                children();
            generate_outline(offset=inner_offset, style=style)
                children();
        }
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
    "outline(2)", "outline(2, 2)", "outline(2, -2)",
    "outline(2, 0, \"external\"", "outline(2, 0, \"internal\"",
    "outline(2, 0, \"external\" \"round\"", "outline(2, 0, \"internal\" \"chamfer\"",
];

_envelope_tools_grid_layout(Cell_Size, labels=labels)
{
    _envelope_tools_row_layout(Cell_Size, 2d_Model_File)
    {
        import(2d_Model_File);

        group() {outline(2) import(2d_Model_File); %import(2d_Model_File);}
        group() {outline(2, 2) import(2d_Model_File); %import(2d_Model_File);}
        group() {outline(2, -2) import(2d_Model_File); %import(2d_Model_File);}

        group() {outline(2, 0, "external") import(2d_Model_File); %import(2d_Model_File);}
        group() {outline(2, 0, "internal") import(2d_Model_File); %import(2d_Model_File);}

        group() {outline(2, 0, "center", "round") import(2d_Model_File); %import(2d_Model_File);}
        group() {outline(2, 0, "center", "chamfer") import(2d_Model_File); %import(2d_Model_File);}
    }
}
