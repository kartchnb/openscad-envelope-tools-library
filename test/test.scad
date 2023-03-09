use<../envelope_tools.scad>

Text = "I";
Square_Space = [100, 100];

square_resize(Square_Space)
    text(Text, valign="center", halign="center");

#square(Square_Space, center=true);
