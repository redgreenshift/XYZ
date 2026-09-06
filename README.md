# XYZ

XYZ is a 3D graphing utility originally written in 1998 using Turbo Pascal. It was designed to render mathematical surfaces within a DOS environment.

## How it Works
The utility allows users to enter standard mathematical equations. To optimize performance and increase rendering speed, XYZ internally converts these equations into Reverse Polish Notation (RPN). By evaluating the graphs using an RPN stack, the program minimizes parsing overhead during the rendering loop, allowing for faster 3D visualization.

## Visuals & Rendering
The project utilizes a **wireframe rendering** style with a built-in **perspective projection** to create a sense of depth. To enhance the 3D effect, it employs depth-based shading:
* **Foreground:** Objects closer to the viewer are rendered larger and in a lighter gray.
* **Background:** Objects further away are rendered smaller and in a darker gray.

## Technical Specifications
* **Language:** Turbo Pascal
* **Environment:** DOS
* **Input:** Standard algebraic equations (converted to RPN internally)
* **Rendering:** Wireframe with perspective projection and depth cueing

## Running the Code
Because this project was written for a DOS environment, you will likely need a legacy compiler or an emulator such as **DOSBox** to compile and run the source code on modern hardware.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
