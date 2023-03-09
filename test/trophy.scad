Base_Size = 50;
Base_Height = 20;
Inscription_Depth = 1;

Inscription = "A Long Line of Text";
Model = "praying hands.stl";


use<envelope_tools/envelope_tools.scad>



difference()
{
    // Generate the basic base
    linear_extrude(Base_Height)
        square([Base_Size, Base_Size], center=true);

    // Carve the text in the front of the base
    translate([0, -Base_Size/2, Base_Height/2])
        rotate([90, 0, 0])
        mirror([0, 0, 1])
        linear_extrude(Inscription_Depth*2, center=true)
        square_resize([Base_Size - Inscription_Depth*2, Base_Height - Inscription_Depth*2])
        text(Inscription, halign="center", valign="center");
}

// Add the model on top of the base
translate([0, 0, Base_Height])
    prism_resize([Base_Size, Base_Size], 3d=true)
    import(Model);
