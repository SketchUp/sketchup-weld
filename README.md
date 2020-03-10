# Example Extension for testing SketchUp's Weld

This expose `Sketchup::Entities#weld` to the SketchUp UI via a context menu
if the user has edges selected.

## Debugging Tools

A set of debugging tools is found under `Extensions > Weld Debug`.

### Count Curves

Counts the number of curves found in the current context.

### Colorize Curves

Assigns a unique color to each curve for easier visual identification.

### Mark Curve Endpoints

Adds guide points and guide lines at the start and end of curves.

For open ended curves the start will be marked with a guide line with long
dashes. The end will have dots.

For closed curves the start and end is the same point and marked with a guide
line with dashes and dots.

### Validate Model

Triggers the Check Validity of the model. (With the mac build of SketchUp this
will open the `Model Info > Statistics` dialog and `Fix Problems` must be
invoked manually.)
