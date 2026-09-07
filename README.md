# XYZ

[![Platform: DOS](https://img.shields.io/badge/Platform-DOS-708090)](https://en.wikipedia.org/wiki/MS-DOS)
[![Language: Turbo Pascal](https://img.shields.io/badge/Language-Turbo%20Pascal-0000AA)](https://en.wikipedia.org/wiki/Turbo_Pascal)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

XYZ is a 3D graphing utility originally written in 1998 using Turbo Pascal. It was designed to render mathematical surfaces within a DOS environment.

![Screenshot of XYZ 3D Graphing Utility](infinite3d2.gif)

## How it Works
The utility allows users to enter standard mathematical equations. To optimize performance and increase rendering speed, XYZ internally converts these equations into [Reverse Polish Notation (RPN)](https://en.wikipedia.org/wiki/Reverse_Polish_notation). By evaluating the graphs using an RPN stack, the program minimizes parsing overhead during the rendering loop, allowing for faster 3D visualization.

XYZ achieves its 3D visualization through the coordination of three primary components:

* **Main Engine (`XYZ.pas`):** Handles the user interface, the main rendering loop, and the final output to the screen.
* **RPN Library (`RPN.pas`):** To maximize rendering speed, the utility converts standard mathematical equations into Reverse Polish Notation. This allows the program to evaluate the graph points rapidly using a stack-based approach, avoiding the overhead of repeated expression parsing.
* **Matrivex Library (`Matrivex.pas`):** A custom matrix and vector math library that handles the heavy lifting of 3D linear algebra. This library is responsible for the 3D rotations and the perspective scaling that creates the illusion of depth.

## Visuals & Rendering
The project utilizes a **wireframe rendering** style with a built-in **perspective projection** to create a sense of depth. To enhance the 3D effect, it employs depth-based shading:
* **Foreground:** Objects closer to the viewer are rendered larger and in a lighter gray.
* **Background:** Objects further away are rendered smaller and in a darker gray.

## Technical Specifications
* **Language:** Turbo Pascal
* **Environment:** DOS
* **Input:** Standard algebraic equations (converted to RPN internally)
* **Rendering:** Wireframe with perspective projection and depth cueing (shading based on distance).
* **Key Components:** 
    * **Matrivex:** Custom library for 3D rotations and perspective projections.
    * **RPN Evaluator:** Custom implementation for high-speed equation processing.

> [!IMPORTANT]
> ## Developer's Note
> This project was pushed to the limits of the Turbo Pascal memory model. Due to the recursive nature of the RPN evaluation and the complexity of the 3D rendering, the default stack sizes (8KB and 16KB) resulted in stack overflows. The code was ultimately configured to use the largest stack size permitted by the compiler to ensure stability.

## Running the Code
Because this project was written for a DOS environment, you will likely need a legacy compiler or an emulator such as **DOSBox** to compile and run the source code on modern hardware.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
