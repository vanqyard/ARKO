#!/usr/bin/env python
import sys
import random
import math

s="";
r=100;
t=4;
file = open('mapa.txt','w')
for i in range(0,201):
	for j in range(0,201):
		tmp = (i-100)*(i-100)+(j-100)*(j-100);				# tmp = (x-x0)^2 + (y-y0)^2
		d = math.sqrt(tmp);
		
		if( tmp<r*r ) :
		    s+=str( t*(r - int(math.floor(d))) ) + ' ';
		else :
		    s+=str(4);
		    if(j!=200) : 
			  s+=' ';
		    else :
			  s+='\n';
		    
file.write(s)
file.close()

