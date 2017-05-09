#include <stdio.h>
#include <string.h> 
#include <stdlib.h> 
#include <openssl/bn.h>
#include "types.h"


// takes a mint and an int (0 or 1), 
// returning val for idx 0 and mod for idx 1
// void *access_mint(struct mint* m, int index)	{
void *access_mint(struct mint m, int index)	{

	if(index == 0) { return m.val; }
	return m.mod;
}



void *access_curve(struct curve* c, int index)	{
	
	if(index < 2) {
		return access_mint(c->a, index);
	}
	else {
		return access_mint(c->b, index-2);
	}

}

void *access_point(struct point* p, int index)	{

	if(index < 4)	{
		return access_curve(&(p->E), index);
	}
	else	{
		if(index == 4) {
			return p->x;
		}
	}
	return p->y;
}




