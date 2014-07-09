#!/usr/bin/env python
import sys
import random
import math

s="";
file = open('mapa.txt','w')
for i in range(0,201):
	for j in range(0,201):
		    s+=str(100);
		    if(j!=200) : 
			  s+=' ';
		    else :
			  s+='\n';
		    
file.write(s)
file.close()

