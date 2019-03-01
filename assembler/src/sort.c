#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "isa.h"

/* 
 * Details: Comparater function used for qsort and bsearch.
 * Compares the String Instructions names in the isa_instr table.
 * 
 * Parameter(s):
 *  - p1: Pointer to 1st parameter being compared
 *  - p2: Pointer to 2nd parameter being compared
*/
int 
cmp(const void *p1, const void *p2) {
    return strcmp(((isa *)p1)->instr_name, ((isa *)p2)->instr_name);
}

/*
 * Details: Sort the Instructions array according to their names.
*/
void
sort_instr() {
    qsort(isa_instr, TOTAL_INSR, sizeof(isa), cmp);
}