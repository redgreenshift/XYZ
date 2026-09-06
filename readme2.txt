3D Graphing Utility
      v?.à
by, Jared Ivey



I don't know what revision number this is since I haven't numbered my revisions, but I'll try to quickly explain the keys you can use.

You can type equations in standard form (y=x+z) or RPN (y=xz+)

Note: to exit the program you need to clear the input field and press enter.
      you can do this quickly by pressing Ctrl+BkSpace.


End               Move to end of line
Home              Move to beginning of line
right             Move right 1 character
left              Move left 1 character
Ctrl+left         Move left to previous number/variable
Ctrl+right        Move right to next number/variable
Shift+2           square character (ý)
Alt+2             square root 	(û)
Alt+p             Pi character	(ã)
Ctrl+BkSpace      Clear input field
Enter             Graph equation, or exit if no equation entered
Tab               Debug toggle
Esc               Graph negative (a way to easily complete the sphere or torus,
                                  if center is at origin, otherwise it may look funny.
				just plots y=-<eqn> )

   These type in functions quickly so that I could test them without
   having to retype them every time, over and over...
F5                sin sum   y=50*(sin(ã*x/120)+sin(ã*z/120))
F6                sphere    y=û(40500-xý-zý)
F7                dome      y=û(30000-(x/1.5)ý-zý)
F8                torus     y=û(5000-(200-û(xý+zý))ý)
F9                sin prod  y=75*(sin(ã*x/120)*sin(ã*z/120))
F10               sin quot  y=4*(sin(ã*x/120)/sin(ã*z/120))
F4                infinite  y=û(3000-(û(xý+(abs(z)-100)ý)-100)ý)



available unary operators:

    Note: the parenthesis are required since I treat the opening parenthesis as part of the operator

abs()
sin()
cos()
tan()
arcsin()
arccos()
arctan()
ln()


I probably left some stuff out, but I'm going to completely rewrite this program in Visual C++, using DirectX, in 4 dimensions, as a screensaver.  Now that I've looked at DirectX stuff, I may wait and attempt 3dfx or OpenGL first...


Any questions or comments, send to [REDACTED]
