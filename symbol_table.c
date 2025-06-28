#include "symbol_table.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

Symbol symbol_table[MAX_SYMBOLS];
int symbol_count = 0;
static unsigned long next_address = 1000; /* Start addresses at 1000 */

void init_symbol_table() {
    symbol_count = 0;
    next_address = 1000; /* Reset address counter */
}

void insert_symbol(char *name, char *type, int line, int dimensions, int *dim_sizes, char *value) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            free(symbol_table[i].type);
            free(symbol_table[i].dim_sizes);
            free(symbol_table[i].value);
            symbol_table[i].type = strdup(type);
            symbol_table[i].line_count = 1;
            symbol_table[i].last_line = line;
            symbol_table[i].decl_line = line;
            symbol_table[i].dimensions = dimensions;
            symbol_table[i].dim_sizes = dim_sizes ? malloc(dimensions * sizeof(int)) : NULL;
            if (dim_sizes && dimensions > 0) {
                memcpy(symbol_table[i].dim_sizes, dim_sizes, dimensions * sizeof(int));
            }
            symbol_table[i].value = value ? strdup(value) : NULL;
            return;
        }
    }
    if (symbol_count < MAX_SYMBOLS) {
        symbol_table[symbol_count].name = strdup(name);
        symbol_table[symbol_count].type = strdup(type);
        symbol_table[symbol_count].line_count = 1;
        symbol_table[symbol_count].last_line = line;
        symbol_table[symbol_count].decl_line = line;
        symbol_table[symbol_count].dimensions = dimensions;
        symbol_table[symbol_count].dim_sizes = dim_sizes ? malloc(dimensions * sizeof(int)) : NULL;
        if (dim_sizes && dimensions > 0) {
            memcpy(symbol_table[symbol_count].dim_sizes, dim_sizes, dimensions * sizeof(int));
        }
        /* Calculate size */
        int total_size = 0;
        if (strcmp(type, "int") == 0) {
            total_size = 4;
        } else if (strcmp(type, "float") == 0) {
            total_size = 4;
        } else if (strcmp(type, "char") == 0) {
            total_size = 1;
        }
        if (dimensions > 0) {
            for (int i = 0; i < dimensions; i++) {
                total_size *= dim_sizes[i];
            }
        }
        symbol_table[symbol_count].size = total_size;
        symbol_table[symbol_count].address = next_address;
        next_address += total_size; /* Increment address by size */
        symbol_table[symbol_count].value = value ? strdup(value) : NULL;
        symbol_count++;
    } else {
        printf("Symbol table overflow\n");
    }
}

void update_line_count(char *name, int line) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            symbol_table[i].line_count++;
            symbol_table[i].last_line = line;
            return;
        }
    }
}

void print_symbol_table() {
    printf("\nSymbol Table:\n");
    printf("---------------------------------------------------------------\n");
    printf("%-6s%-7s%-6s%-11s%-4s%-12s%-9s%-10s%-10s\n",
           "Name", "Type", "Size", "Decl Line", "Dim", "Dim Sizes", "Address", "Value", "Lines Used");
    for (int i = 0; i < symbol_count; i++) {
        printf("%-6s%-7s%-6d%-11d%2dD  ", 
               symbol_table[i].name,
               symbol_table[i].type,
               symbol_table[i].size,
               symbol_table[i].decl_line,
               symbol_table[i].dimensions);
        char dim_buf[32] = "[]";
        if (symbol_table[i].dimensions > 0) {
            snprintf(dim_buf, sizeof(dim_buf), "[");
            for (int j = 0; j < symbol_table[i].dimensions; j++) {
                char num[10];
                snprintf(num, sizeof(num), "%d", symbol_table[i].dim_sizes[j]);
                strncat(dim_buf, num, sizeof(dim_buf) - strlen(dim_buf) - 1);
                if (j < symbol_table[i].dimensions - 1) {
                    strncat(dim_buf, ",", sizeof(dim_buf) - strlen(dim_buf) - 1);
                }
            }
            strncat(dim_buf, "]", sizeof(dim_buf) - strlen(dim_buf) - 1);
        }
        printf("%-12s%-9lu", dim_buf, symbol_table[i].address);
        if (symbol_table[i].value) {
            if (strcmp(symbol_table[i].type, "float") == 0) {
                char buf[32];
                snprintf(buf, sizeof(buf), "%.2f", atof(symbol_table[i].value));
                printf("%-10s", buf);
            } else {
                printf("%-10s", symbol_table[i].value);
            }
        } else {
            printf("%-10s", "none");
        }
        printf("%-10d\n", symbol_table[i].line_count);
    }
}
