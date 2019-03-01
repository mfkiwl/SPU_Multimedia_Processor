#ifndef SORT_H
#define SORT_H

/* 
 * Details: Comparater function used for qsort and bsearch.
 * Compares the String Instructions names in the isa_instr table.
 * 
 * Parameter(s):
 *  - p1: Pointer to 1st parameter being compared
 *  - p2: Pointer to 2nd parameter being compared
*/
int 
cmp(const void *p1, const void *p2);

/*
 * Details: Sort the Instructions array according to their names.
*/
void
sort_instr();

#endif /* SORT_H */