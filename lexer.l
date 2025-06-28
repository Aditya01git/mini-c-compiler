%{
#include "parser.tab.h"
#include "symbol_table.h"
#include <stdio.h>
#include <string.h>

void install_id(char *text, int line);

extern FILE *token_file;  // Only declare!
%}

%option noyywrap
%option nounput
%option noinput
%option yylineno

DIGIT       [0-9]
LETTER      [a-zA-Z]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT})*
INTEGER     {DIGIT}+
FLOAT       {DIGIT}+\.{DIGIT}*
CHAR        '([^\']|\\.)'
WHITESPACE  [ \t\n]+

%%

"int"       { fprintf(token_file, "INT\n"); return INT; }
"float"     { fprintf(token_file, "FLOAT\n"); return FLOAT; }
"char"      { fprintf(token_file, "CHAR\n"); return CHAR; }
"if"        { fprintf(token_file, "IF\n"); return IF; }
"else"      { fprintf(token_file, "ELSE\n"); return ELSE; }
"while"     { fprintf(token_file, "WHILE\n"); return WHILE; }
"return"    { fprintf(token_file, "RETURN\n"); return RETURN; }
"void"      { fprintf(token_file, "VOID\n"); return VOID; }
"main"      { fprintf(token_file, "MAIN\n"); return MAIN; }
"break"     { fprintf(token_file, "BREAK\n"); return BREAK; }
"continue"  { fprintf(token_file, "CONTINUE\n"); return CONTINUE; }

{IDENTIFIER} {
    install_id(yytext, yylineno);
    fprintf(token_file, "IDENT(%s)\n", yytext);
    return IDENTIFIER;
}
{INTEGER} {
    yylval.ival = atoi(yytext);
    fprintf(token_file, "INTEGER(%s)\n", yytext);
    return INTEGER;
}
{FLOAT} {
    yylval.fval = atof(yytext);
    fprintf(token_file, "FLOAT(%s)\n", yytext);
    return NUMBER;
}
{CHAR} {
    yylval.sval = strdup(yytext);
    fprintf(token_file, "CHAR(%s)\n", yytext);
    return CHAR_LIT;
}

"==" { fprintf(token_file, "EQ\n"); return EQ; }
"!=" { fprintf(token_file, "NE\n"); return NE; }
"<=" { fprintf(token_file, "LE\n"); return LE; }
">=" { fprintf(token_file, "GE\n"); return GE; }
"<"  { fprintf(token_file, "<\n"); return '<'; }
">"  { fprintf(token_file, ">\n"); return '>'; }
"="  { fprintf(token_file, "=\n"); return '='; }
"+"  { fprintf(token_file, "+\n"); return '+'; }
"-"  { fprintf(token_file, "-\n"); return '-'; }
"*"  { fprintf(token_file, "*\n"); return '*'; }
"/"  { fprintf(token_file, "/\n"); return '/'; }
"("  { fprintf(token_file, "(\n"); return '('; }
")"  { fprintf(token_file, ")\n"); return ')'; }
"{"  { fprintf(token_file, "{\n"); return '{'; }
"}"  { fprintf(token_file, "}\n"); return '}'; }
";"  { fprintf(token_file, ";\n"); return ';'; }
","  { fprintf(token_file, ",\n"); return ','; }
"["  { fprintf(token_file, "[\n"); return '['; }
"]"  { fprintf(token_file, "]\n"); return ']'; }

{WHITESPACE} { /* ignore */ }
. { printf("Unknown character: %s\n", yytext); }

%%

void install_id(char *text, int line) {
    yylval.sval = strdup(text);
}
