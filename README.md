# Advanced Programming Concepts - X86-64 Assembly
By: Stijn Stroeve and Stephan Windemuller

## Building the applications
The applications can be assembled and linked using the `make` command. Running this command will use the `Makefile` to assemble and link both applications included in this project. 

Before you build the applications, make sure you have `yasm` installed. You can do this using the `sudo apt-get install yasm` command.

## Debugging the applications
The applications in this project can be debugged using `gdb`. You can do this manually by calling the `gdb` command, or you can use the `./debug.sh` command included in this program to debug the Guessing Game application.

## Running the applications
The assembled applications can be found in the `/build` directory. So you can run an application by using the `./build/APP_NAME` command. 

## Applications
For this project we have made two seperate applications. 

### Hello World application
The first application we made is a simple hello world program. We used this program to check out the basics of x86-64 assembly.


The source can be found in the `src/hello_world.asm` file.

### Guessing Game application
The second application we wrote is a guessing game application. When you start the application, it will think of a random number between 1 and 128. You then need to guess that number. The only hint the computer will give is whether the guessed number is higher or lower than the correct one.


The source can be found in the `src/guessing_game.asm` file.
