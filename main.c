#include <stdio.h>
#include "symbol_table.h"

// Declare the new functions from semantics.c
void open_tac_file();
void close_tac_file();

FILE *token_file;  // NEW global for token.txt
extern FILE *yyin;
extern int yyparse();

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        fprintf(stderr, "Cannot open file %s\n", argv[1]);
        return 1;
    }

    // Initialize symbol table
    init_symbol_table();

    // Open output files
    token_file = fopen("token.txt", "w");
    open_tac_file();

    yyin = input;

    if (yyparse() == 0) {
        printf("Parsing successful!\n");
        print_symbol_table();
    } else {
        printf("Parsing failed.\n");
    }

    // Close all files
    close_tac_file();
    fclose(token_file);
    fclose(input);

    return 0;
}
