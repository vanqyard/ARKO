#!/bin/sh
java -jar Mars_4_2.jar mips.asm
mkdir test0
mv mapa.bmp test0
mv przekroj.bmp test0

java -jar Mars_4_2.jar mips.asm
python test1.py
mkdir test1
mv mapa.bmp test1
mv przekroj.bmp test1

java -jar Mars_4_2.jar mips.asm
python test2.py
mkdir test2
mv mapa.bmp test2
mv przekroj.bmp test2

java -jar Mars_4_2.jar mips.asm
python test3.py
mkdir test3
mv mapa.bmp test3
mv przekroj.bmp test3

java -jar Mars_4_2.jar mips.asm
python test4.py
mkdir test4
mv mapa.bmp test4
mv przekroj.bmp test4
