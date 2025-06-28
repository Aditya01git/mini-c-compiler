#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define MAX_SYMBOLS 100
#define MAX_DIMS 10 /* Max dimensions for arrays */

typedef struct {
    char *name;         /* Variable name */
    char *type;         /* Type (int, float, char) */
    int size;           /* Size in bytes (4 for int/float, 1 for char) */
    int line_count;     /* Lines Used */
    int last_line;      /* Last line used */
    int decl_line;      /* Line of declaration */
    int dimensions;     /* Number of dimensions (0 for scalar, 1 for 1D, etc.) */
    int *dim_sizes;     /* Array of dimension sizes (e.g., [10][5] → {10, 5}) */
    unsigned long address; /* Simulated memory address */
    char *value;        /* Initial value as string (e.g., "5", "3.14", "'a'") */
} Symbol;

extern Symbol symbol_table[];
extern int symbol_count;

void init_symbol_table();
void insert_symbol(char *name, char *type, int line, int dimensions, int *dim_sizes, char *value);
void update_line_count(char *name, int line);
void print_symbol_table();

#endif