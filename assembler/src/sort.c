#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "isa.h"
#include "assembler.h"

/*
 * Details: Sort the Instructions array according to their names.
*/
void
sort_instr() {
    qsort(isa_instr, TOTAL_INSTR, sizeof(isa), cmp);
}