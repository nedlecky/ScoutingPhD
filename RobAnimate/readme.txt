README.TXT

This is the README file for CYLNDBOT.EXE and 2LINKBOT.EXE.

******** PROGRAMMER *************

	JAKE GALBREATH

******** VERSION ****************

	1.0	-Released May 04, 2000

********  DESCRIPTION  ***********
These programs enable simple 3D animations of computer simulated 
robot motions. The cylndbot program uses a cylindrical robot
model, while the 2linkbot program uses a  planar 2-link 'arm' model.

********  USE  *********
loads time and position data from the first four
columns of a LEmatrix stored in a comma delimited file.
If the name of the file is not passed as a command line 
parameter, the opening file is hardwired to sim_result.csv,
where sim_result.csv must be in the same directory as the 
executable.  
 
For the current version of cylndbot.exe, the robot model uses 
maximum values of 8 for the arm elevation and extension.  The
 next revision of this program should query max position values 
and possibly origin values.  Both programs expect angular data 
in radians.


********  INSTRUCTIONS  **********
-Press and hold 't' to run through the animation in true time.
-Press 'f' to step forward through each frame of the animation.
-Press 'r' to step backwards through each frame of the animation.
-Press the left key to rotate the viewing angle to the left.
-Press the right key to rotate the viewing angle to the right.
-Press ESC to exit.\n");

********  TRUE TIME ANIMATION ***********
When pressing t and running through the animation, it is necessary to 
hold down t continuously.  If the the t button is pressed intermittently,
the animation will skip forward to the true position based on the time 
passed from the first pressing of t.  Once f or r is pressed, the true time
"clock" is reset, waiting for the next press of t.


*******   ASSOCIATING THE EXECUTABLES WITH THE CSV FILETYPE  *******
For ease of use, I reccomend adding another 
associated action type to the .csv filetype. 
  
To do this, first open a file browsing window and click on
	
	VIEW -> FOLDER OPTIONS
  
Then click on the tab marked FILE TYPES

Scroll Down and select 
	
	MICROSOFT EXCEL COMMA SEPERATED VALUES

Once selected, click the edit button to the right.
		
Click New and type in a suitable action name in the 
ACTION field, such as CYL_ROBOT_ANIMATE or 2LINK-ANIM.

Hit browse to locate the desired executable.
The field marked APPLICATION USED TO PERFORM ACTION
should now contain the path and filename of the 
executable.  Append the following string to this .exe path.
(including quotation marks)

		"%1"

The entire string should look like this ->

c:\somedir\anotherdir\cylndbot.exe "%1"

Click OK OK OK.

Now, to animate a simulation, right click on a desired
csv file and click on the action you have just defined.
i.e. CYL_ROBOT_ANIMATE.

******** QUESTIONS, COMMENTS  ***************

email me at jgalbrea@zoo.uvm.edu

******* CREDIT WHERE CREDIT IS DUE ***********
Matt Gibbs - thanks for the win32 advice.

Both of these programs are currently designed to read
"LEmatrix" matrices.  All of the LEmatrix utilities are written by 
my EE295 prof. - Dr. John (Ned) Lecky.  If you want to learn
more about Dr. Lecky's utilities, or just want to check out the 
EE295 class, go to 

	http://www.ee295.com

Also, I got the idea for the 2Link Program from an SGI  OPENGL 
programming example.  I used their code as a jumping off point,
so I'm including their copyright info below.


 * Copyright (c) 1993-1997, Silicon Graphics, Inc.
 * ALL RIGHTS RESERVED 
 * Permission to use, copy, modify, and distribute this software for 
 * any purpose and without fee is hereby granted, provided that the above
 * copyright notice appear in all copies and that both the copyright notice
 * and this permission notice appear in supporting documentation, and that 
 * the name of Silicon Graphics, Inc. not be used in advertising
 * or publicity pertaining to distribution of the software without specific,
 * written prior permission. 
 *
 * THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
 * AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL SILICON
 * GRAPHICS, INC.  BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT,
 * SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY
 * KIND, OR ANY DAMAGES WHATSOEVER, INCLUDING WITHOUT LIMITATION,
 * LOSS OF PROFIT, LOSS OF USE, SAVINGS OR REVENUE, OR THE CLAIMS OF
 * THIRD PARTIES, WHETHER OR NOT SILICON GRAPHICS, INC.  HAS BEEN
 * ADVISED OF THE POSSIBILITY OF SUCH LOSS, HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE
 * POSSESSION, USE OR PERFORMANCE OF THIS SOFTWARE.
 * 
 * US Government Users Restricted Rights 
 * Use, duplication, or disclosure by the Government is subject to
 * restrictions set forth in FAR 52.227.19(c)(2) or subparagraph
 * (c)(1)(ii) of the Rights in Technical Data and Computer Software
 * clause at DFARS 252.227-7013 and/or in similar or successor
 * clauses in the FAR or the DOD or NASA FAR Supplement.
 * Unpublished-- rights reserved under the copyright laws of the
 * United States.  Contractor/manufacturer is Silicon Graphics,
 * Inc., 2011 N.  Shoreline Blvd., Mountain View, CA 94039-7311.
 *
 * OpenGL(R) is a registered trademark of Silicon Graphics, Inc.
/

