all: rm kilo

rm:
	@rm -f kilo

kilo: kilo.c
	$(CC) -o kilo kilo.c -Wall -W -pedantic -std=c99 -Llua -Llua -Ilua  -llua -lm

clean:
	rm kilo
