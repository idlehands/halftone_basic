halftone_basic
==============

Basic class to make svg halftones from a png. Utilizes chunky_png.
This can be seen in action at http://xylotones.com.

The algorithm breaks the image into square blocks, based off of a user parameter, analyzes the pixels in that block,
determining the average color for the block, and assigns a gray value to it. The block's x-coordinate, y-coordinate, and
gray value are returned. There is a simple method that then writes an svg file from that, using the gray value to 
determine the circle's radius.

#to-do
- ~~interface with image, using chunky_png~~
- ~~break down image into square "chunks" based on a parameter~~
- ~~process each chunk, find a corresponding gray and return chunk coordinates and gray value~~
- CONVERT to a module
- provide options for output format
- optimize algorithm
- add offset for every other row
