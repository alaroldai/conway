#Conway's game of life
Conway's game of life for Mac OS, implemented in Objective-C++ (actually just C++ with some handy structs from Core Graphics…). 

###Description
An implementation of [Conway's game of life](http://en.wikipedia.org/wiki/Conway%27s_game_of_life), at one pixel per cell. Runs on four threads at 648x480 resolution by default, with a maximum frame rate of 30 fps.

###Building
Build with SCons from the root directory. You'll need Python and SCons installed - if you need to install SCons, you can find installation instructions at [the SCons website](http://www.scons.org)

###Configuring
The resolution, number of threads, and target frame rate can be modified by editing the main source file (conway.mm).