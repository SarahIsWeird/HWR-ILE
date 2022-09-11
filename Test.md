# imgfilter

imgfilter applies various filters to an image. Currently, it's CLI-based and supplies five filters. This is going to change soon!
When you run it, a window will open, showing the current state of the transformed image. After it's done, it will save the transformed image to a (new) file!

If you have any ideas on what filters I could add, please let me know! Also, I'm planning on adding a nice GUI to this. We'll see :D

## Compiling

You need `make` and [SFML](https://sfml-dev.org). Then just clone the directory and run `make`!

## Usage

The basic usage is as follows: `imgfilter <image> <operation> [..operation args]`. Different filters require a different amount of arguments.

This image of me is the input for all the examples!

![Example image](https://egirl.rip/jZheaydaF8.jpg?key=imgfilter)

### `bw`

Turns an image black and white. Takes no arguments.

![Example image](https://egirl.rip/1ApXSyT9eq.png?key=imgfilter)

### `isolate <r|g|b>`

Isolates a color channel from a picture. In effect, it only outputs the red, green or blue parts of the image.

![Example image](https://egirl.rip/UuivHrNo79.png?key=imgfilter)

### `reduce <r> <g> <b>`

Reduces the "available" colors in the picture. The arguments govern how many colors are available. The colors are evenly spaced apart.
For example: Setting r to 4 would allow five values in the red channel: 0, 63, 127, 191 and 255. This example was generated with `3 4 3`.

![Example image](https://egirl.rip/yXhtDuaMss.png?key=imgfilter)

### `reducebw <gray>`

Works in the exact same way as `reduce`, but only allows gray values. The argument works the same way, too. This example was generated with `8`.

![Example image](https://egirl.rip/ErrGrJQ3pu.png?key=imgfilter)

### `threshold <r> <g> <b>`

This filter only allows eight colours: A channel can either be fully red/green/blue or black. The arguments govern at what value the channel will
become fully turned on. This example was generated with `192 128 64`.

![Example image](https://egirl.rip/3HUShJNbGJ.png?key=imgfilter)
