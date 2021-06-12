CC = gcc
CFLAGS = -Wall -m64 -no-pie 
LIB = -lallegro -lallegro_dialog -lallegro_image 

all: main.o bezier_func.o
	$(CC) $(CFLAGS) main.o bezier_func.o -o bezier $(LIB) 
main.o: main.c
	$(CC) $(CFLAGS) -c main.c -o main.o

bezier_func.o: bezier_func.s
	nasm -f elf64 -g bezier_func.s

clean:
	rm -f *.o bezier
