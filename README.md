# envelope_tools
One of the great strengths of OpenSCAD is the ability to develop parametric models that can be modified easily using the OpenSCAD customizer.  The end user of a well-written model does not need to understand OpenSCAD code to develop their own customized model.

One of the greatest weaknesses of OpenSCAD is that it does not provide a way to query the dimensions of geometry.  This means, for instance, that allowing the user to enter arbitrary text to be incorporated into the model can be difficult since there is no way to tell how wide the text will be and to ensure it can be scaled correctly.  The designer must determine whether to fit the text to the width of the space, the height of the space, or provide an additional option for the user to select which.

Well, I wasn't satisifed, so I wrote this library to work around this weakness in some situations.  It allows 2-dimensional geometry to be scaled to fit a given space without distortion.  If it's too wide for the space, it will be scaled to fit the width, otherwise it will fit the height.

For example, this code was used to generate the following image (the red square shows the area being scaled to).  Note that the string is scaled to fit the width of the square:

```
use<envelope_tools/envelope_tools.scad> // Be sure to "use" rather than "include"

Text = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
Square_Space = [100, 100];

square_resize(Square_Space)
    text(Text, valign="center", halign="center");

#square(Square_Space, center=true);
```

![image](https://user-images.githubusercontent.com/54730012/223909135-b176139a-d0ae-40ac-9791-14aa5842281e.png)

And, a simple change to the Text string, as shown, will result in the following picture.  Note that the letter "I" is scaled to fit the height of the square:

```
use<envelope_tools/envelope_tools.scad> // Be sure to "use" rather than "include"

Text = "I";
Square_Space = [100, 100];

square_resize(Square_Space)
    text(Text, valign="center", halign="center");

#square(Square_Space, center=true);
```

![image](https://user-images.githubusercontent.com/54730012/223909746-06f66e2a-2b2d-48e7-90e7-d134864c1e4a.png)

Additionally, rectangular or circular "envelopes" can be created for any geometry.  These "envelopes" will outline the child geometry, matching its width and height.  For example, the following code will create a rectangular "envelope" around the text that will be updated if the text is changed

```
use<../envelope_tools.scad>

Text = "Envelope";

square_envelope()
    text(Text);
#text(Text);
```

![image](https://user-images.githubusercontent.com/54730012/227684923-538df0d6-3198-47d1-bbe0-1ab4d0081a78.png)


Support for 3-dimensional geometry is still a work in progress.  It mostly works... mostly.  A simple example of using this library for both 2D and 3D geometry can be found in the "test" directory in the file "trophy.scad".

To use, simply install the library into your OpenSCAD library folder.  

Note that this library abuses OpenSCAD a bit to achieve this, so you may notice some visual glitches when previewing models in OpenSCAD.  So far, everything I've designed with this library has worked just fine when rendered and printed.

Also note that the library should be added to your project with the use<> command rather than include<>, or you will get unwanted test renders in your model.  This is because each file contains test code.  The upshot is that you can open each library file in OpenSCAD to see a sample of what the functions in that file do.

I'm still working on documenting this library.  Right now, it's a bit difficult to understand and use.  Hopefully, I'll find time to fix that.
