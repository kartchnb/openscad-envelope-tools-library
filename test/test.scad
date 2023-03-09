use<../axis_projection.scad>

/* [Model Parameters] */
Model_File = "test.stl"; // ["test.stl", "test.svg"]
Bounding_Box = [50, 100];
Border = [0, 0];

module test_any_projection()
{
    #children();

    any_projection()
        children();
}



module test_axis_projection()
{
    axes=[1, 1, 1];

    axis_projection(axes, thickness=10, solid=true)
        children();

    #children();
}



test_axis_projection()
    import(Model_File);
