
module _envelope_tools_row_layout(cell_size, label="", extrusion=undef)
{
    module optional_extrusion(extrusion)
    {
        if (is_undef(extrusion)) children();
        else linear_extrude(extrusion) children();
    }

    text_size = cell_size.y * .5;
    translate([-cell_size.x, 0])
        optional_extrusion(extrusion)
        text(label, size=text_size, halign="right", valign="center");
        
    for (i = [0: $children - 1])
        translate([cell_size.x*i, 0])
        children(i);
}



module _envelope_tools_grid_layout(cell_size, labels=[], extrusion=undef)
{
    module optional_extrusion(extrusion)
    {
        if (is_undef(extrusion)) children();
        else linear_extrude(extrusion) children();
    }

    text_size = cell_size.x * .5;
    for (i = [0: len(labels) - 1])
        translate([cell_size.x*i, -cell_size.y])
        rotate([0, 0, 90])
        optional_extrusion(extrusion)
        text(labels[i], size=text_size, halign="right", valign="center");

    for (i = [0: $children - 1])
        translate([0, cell_size.x*i, 0])
        children(i);
}
