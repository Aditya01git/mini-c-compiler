#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>  // ✅ REQUIRED for va_list, va_start, va_end

#include "symbol_table.h"

/* Global TAC file pointer */
FILE *tac_file = NULL;

/* Temp variable counter */
static int temp_count = 0;

/* Generate new temp name */
char* new_temp() {
    char buf[10];
    sprintf(buf, "t%d", temp_count++);
    return strdup(buf);
}

/* Open TAC output file */
void open_tac_file() {
    tac_file = fopen("tac.txt", "w");
    if (!tac_file) {
        perror("Unable to open tac.txt");
        exit(1);
    }
}

/* Close TAC file */
void close_tac_file() {
    if (tac_file) {
        fclose(tac_file);
        tac_file = NULL;
    }
}

/* Emit a line to both console and tac.txt */
void emit(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vprintf(fmt, args);      // to console
    printf("\n");
    if (tac_file) {
        vfprintf(tac_file, fmt, args);  // to file
        fprintf(tac_file, "\n");
    }
    va_end(args);
}

/* Lookup type from symbol table */
char* lookup_type(char *name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return symbol_table[i].type;
        }
    }
    return "unknown";
}

/* Type compatibility check */
int type_compatible(char *t1, char *t2) {
    if (strcmp(t1, t2) == 0) return 1;
    if ((strcmp(t1, "int") == 0 && strcmp(t2, "float") == 0) ||
        (strcmp(t1, "float") == 0 && strcmp(t2, "int") == 0))
        return 1;
    return 0;
}

/* Common type for promotion */
char* common_type(char *t1, char *t2) {
    if (strcmp(t1, "float") == 0 || strcmp(t2, "float") == 0) return "float";
    return "int";
}
