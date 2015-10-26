For project 2, we randomly chose the samples from the musics pieces in the computers.
The program shows a rectangular white scene. Four lines are put on the scene with four sliders moving on them independently from the left to the right of the scene. 

The looping playback engine has three functions.
First, it plays four pieces of music independently. The moving sliders show the current frames that are being played of each song. 
Second, when each slider reaches the end of the scene, indicating the corresponding song is finished, the slider will move back to the left independently and the song starts playing from the very beginning again. The samples and sliders do not affect each other. 
Third, clicking on a certain region of the  scene will move the slider of that region to the corresponding  place of the mouse. By doing this, you can play that song from any frame you want.

About codes
It is a big-bang program made of several functions. It uses a few lines to define the constants in the program, to read the samples from the file and to create the two structures. One structure is the engine holding the four playheads and the endtime of the chunk. One is the playhead holding the sound and the current frame of the sound. Two functions are defined to decide when to place the next chunk of the songs and to check if it is time to place them. The world state is changed by adding the next chunk. A mouse handler is made to move the sliders to set the new playhead of each song. When the mouse clicks, the program checks where and when to place the next chunk of the corresponding song. The to-draw function creates the rectangular scene and put the lines and sliders in the proper places. 
