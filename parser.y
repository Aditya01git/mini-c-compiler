%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"
#include "semantics.h"

extern int yylex();
extern FILE *yyin;
extern int yylineno;
void yyerror(const char *s);
%}

%union {
    int ival;
    float fval;
    char *sval;
    char *type;
    struct {
        int dimensions;
        int *dim_sizes;
    } array_info;
    struct {
        char *place;    // for TAC
        char *type;     // type info
        char *literal;  // NEW: real literal
    } expr_attr;
}

%define parse.error verbose

%token INT FLOAT CHAR IF ELSE WHILE RETURN VOID MAIN BREAK CONTINUE
%token <sval> IDENTIFIER
%token <ival> INTEGER
%token <fval> NUMBER
%token <sval> CHAR_LIT
%token EQ NE LE GE

%left '+' '-'
%left '*' '/'
%nonassoc EQ NE '<' '>' LE GE
%nonassoc IFX
%nonassoc ELSE

%type <type> type
%type <array_info> array_dims dim_list
%type <expr_attr> expression add_expr mul_expr rel_expr primary_expr

%start program

%%

program:
    function_list
    ;

function_list:
    function
    | function_list function
    ;

function:
    type IDENTIFIER '(' params ')' '{' statements '}'
    | VOID IDENTIFIER '(' params ')' '{' statements '}'
    | type MAIN '(' ')' '{' statements '}'
    ;

type:
    INT     { $$ = "int"; }
    | FLOAT { $$ = "float"; }
    | CHAR  { $$ = "char"; }
    ;

params:
    /* empty */
    | param_list
    ;

param_list:
    type IDENTIFIER array_dims { insert_symbol($2, $1, yylineno, $3.dimensions, $3.dim_sizes, NULL); }
    | param_list ',' type IDENTIFIER array_dims { insert_symbol($4, $3, yylineno, $5.dimensions, $5.dim_sizes, NULL); }
    ;

statements:
    /* empty */
    | statements statement
    ;

statement:
    declaration ';'
    | assignment ';'
    | if_statement
    | while_statement
    | RETURN expression ';' { emit("return %s", $2.place); }
    | BREAK ';' { emit("break"); }
    | CONTINUE ';' { emit("continue"); }
    | '{' statements '}'
    ;

declaration:
    type IDENTIFIER array_dims { 
        insert_symbol($2, $1, yylineno, $3.dimensions, $3.dim_sizes, NULL); 
    }
    | type IDENTIFIER array_dims '=' expression {
        if (!type_compatible($1, $5.type)) {
            yyerror("Type mismatch in initialization");
        }
        insert_symbol($2, $1, yylineno, $3.dimensions, $3.dim_sizes, $5.literal);  // ✅ use literal
        emit("%s = %s", $2, $5.place);
    }
    ;

array_dims:
    /* empty */ { $$.dimensions = 0; $$.dim_sizes = NULL; }
    | '[' dim_list ']' { $$ = $2; }
    ;

dim_list:
    INTEGER {
        $$.dimensions = 1;
        $$.dim_sizes = malloc(sizeof(int));
        $$.dim_sizes[0] = $1;
    }
    | dim_list ']' '[' INTEGER {
        $$.dimensions = $1.dimensions + 1;
        $$.dim_sizes = realloc($1.dim_sizes, $$.dimensions * sizeof(int));
        $$.dim_sizes[$$.dimensions - 1] = $4;
    }
    ;

if_statement:
    IF '(' expression ')' statement %prec IFX
    | IF '(' expression ')' statement ELSE statement
    ;

while_statement:
    WHILE '(' expression ')' statement
    ;

assignment:
    IDENTIFIER '=' expression {
        char *lhs_type = lookup_type($1);
        if (!type_compatible(lhs_type, $3.type)) {
            yyerror("Type mismatch in assignment");
        }
        emit("%s = %s", $1, $3.place);
        update_value($1, $3.literal);   // ✅ update real value
    }
    ;

expression:
    add_expr { $$ = $1; }
    ;

add_expr:
    mul_expr { $$ = $1; }
    | add_expr '+' mul_expr {
        if (!type_compatible($1.type, $3.type)) {
            yyerror("Type mismatch in addition");
        }
        $$.place = new_temp();
        emit("%s = %s + %s", $$.place, $1.place, $3.place);
        $$.type = common_type($1.type, $3.type);
        $$.literal = NULL;  // expression result: not a literal constant
    }
    | add_expr '-' mul_expr {
        if (!type_compatible($1.type, $3.type)) {
            yyerror("Type mismatch in subtraction");
        }
        $$.place = new_temp();
        emit("%s = %s - %s", $$.place, $1.place, $3.place);
        $$.type = common_type($1.type, $3.type);
        $$.literal = NULL;
    }
    ;

mul_expr:
    rel_expr { $$ = $1; }
    | mul_expr '*' rel_expr {
        if (!type_compatible($1.type, $3.type)) {
            yyerror("Type mismatch in multiplication");
        }
        $$.place = new_temp();
        emit("%s = %s * %s", $$.place, $1.place, $3.place);
        $$.type = common_type($1.type, $3.type);
        $$.literal = NULL;
    }
    | mul_expr '/' rel_expr {
        if (!type_compatible($1.type, $3.type)) {
            yyerror("Type mismatch in division");
        }
        $$.place = new_temp();
        emit("%s = %s / %s", $$.place, $1.place, $3.place);
        $$.type = common_type($1.type, $3.type);
        $$.literal = NULL;
    }
    ;

rel_expr:
    primary_expr { $$ = $1; }
    | primary_expr EQ primary_expr {
        $$.place = new_temp();
        emit("%s = %s == %s", $$.place, $1.place, $3.place);
        $$.type = "int";
        $$.literal = NULL;
    }
    | primary_expr NE primary_expr {
        $$.place = new_temp();
        emit("%s = %s != %s", $$.place, $1.place, $3.place);
        $$.type = "int";
        $$.literal = NULL;
    }
    | primary_expr '<' primary_expr {
        $$.place = new_temp();
        emit("%s = %s < %s", $$.place, $1.place, $3.place);
        $$.type = "int";
        $$.literal = NULL;
    }
    | primary_expr '>' primary_expr {
        $$.place = new_temp();
        emit("%s = %s > %s", $$.place, $1.place, $3.place);
        $$.type = "int";
        $$.literal = NULL;
    }
    | primary_expr LE primary_expr {
        $$.place = new_temp();
        emit("%s = %s <= %s", $$.place, $1.place, $3.place);
        $$.type = "int";
        $$.literal = NULL;
    }
    | primary_expr GE primary_expr {
        $$.place = new_temp();
        emit("%s = %s >= %s", $$.place, $1.place, $3.place);
        $$.type = "int";
        $$.literal = NULL;
    }
    ;

primary_expr:
    INTEGER {
        $$.place = new_temp();
        emit("%s = %d", $$.place, $1);
        $$.type = "int";

        char buf[32];
        sprintf(buf, "%d", $1);
        $$.literal = strdup(buf);
    }
    | NUMBER {
        $$.place = new_temp();
        emit("%s = %f", $$.place, $1);
        $$.type = "float";

        char buf[32];
        sprintf(buf, "%f", $1);
        $$.literal = strdup(buf);
    }
    | CHAR_LIT {
        $$.place = new_temp();
        emit("%s = %s", $$.place, $1);
        $$.type = "char";

        $$.literal = strdup($1);
    }
    | IDENTIFIER {
        update_line_count($1, yylineno);
        $$.place = $1;
        $$.type = lookup_type($1);
        $$.literal = NULL;   // variable: value in symbol table
    }
    | '(' expression ')' {
        $$.place = $2.place;
        $$.type = $2.type;
        $$.literal = NULL;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax/Semantic error on line %d: %s\n", yylineno, s);
}
