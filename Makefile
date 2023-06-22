all:
	yasm -f elf64 -o ./build/hello_world.o ./src/hello_world.asm
	yasm -f elf64 -g dwarf2 -o ./build/guessing_game.o ./src/guessing_game.asm
	ld -o ./build/hello_world ./build/hello_world.o
	ld -o ./build/guessing_game ./build/guessing_game.o

clean:
	rm hello_world.o
	rm guessing_game.o