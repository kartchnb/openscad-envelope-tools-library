/* [Test Parameters] */
// The size of each test cell
Cell_Size = 250;
// The 2D model file
Model_File_2D = "../test/test.svg";
// The render quality
Render_Quality = 32;

/* [Test Code] */
$fn = $fn != 0 ? $fn : Render_Quality;
include<../test/_test_grid.scad>

labels = 
[
    "original", 
    "outline(20)", "outline(20, 30)", "outline(20, -30)",
    "outline(20, 0, \"external\")", "outline(20, 0, \"internal\")",
    "outline(20, 0, \"external\", \"round\")", "outline(20, 0, \"internal\", \"chamfer\")",
];

_envelope_tools_grid_layout([Cell_Size, Cell_Size], labels=labels)
{
    _envelope_tools_row_layout([Cell_Size, Cell_Size], Model_File_2D)
    {
        import(Model_File_2D);

        group() {outline(20) import(Model_File_2D); #import(Model_File_2D);}
        group() {outline(20, 30) import(Model_File_2D); #import(Model_File_2D);}
        group() {outline(20, -30) import(Model_File_2D); #import(Model_File_2D);}

        group() {outline(20, 0, "external") import(Model_File_2D); #import(Model_File_2D);}
        group() {outline(20, 0, "internal") import(Model_File_2D); #import(Model_File_2D);}

        group() {outline(20, 0, "center", "round") import(Model_File_2D); #import(Model_File_2D);}
        group() {outline(20, 0, "center", "chamfer") import(Model_File_2D); #import(Model_File_2D);}
    }
}



// Generate an outline of the underlying geometry
//
// parameters:
//  thickness - the thickness of the outline to generate
//  expansion - the amount to expand the outline from the edges of the child geometry
//      (may be positive or negative)
//  align - how to align the outline to the edges of the child geometry (defaults to "center")
//      "center" centers the outline on the bounds of the child geometry
//      "external" expands the outline outwards
//      "internal" creates an outline entirely within the bounds of the child geometry
//  style - the style of outline to generate (defaults to "standard")
//      "standard" follows the outline of the child geometry exactly
//      "round" rounds off corners of the child geometry
//      "chamfer" chamfers corners of the child geometry
module outline(thickness=1, expansion=0, align="center", style="standard")
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



    outer_offset = 
        align == "external" ? expansion + thickness :
        align == "internal" ? expansion :
        expansion + thickness/2;

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
