Mini Compiler Project
This is a Mini Compiler Project for Compiler Design (CD), implementing the first four phases of a compiler:

✅ Lexical Analysis (using Flex)
✅ Syntax Analysis (using Bison)
✅ Symbol Table Management
✅ Intermediate Code Generation

Features
    => Token generation using a lexer
    => Parsing using a grammar with Bison
    => Symbol table creation and lookup
    => Intermediate code generation for expressions and statements

Prerequisites
    => Flex (Lexical Analyzer Generator)
    => Bison (Parser Generator)
    => GCC (GNU Compiler Collection)

You can install them on Linux using:
      =>  sudo apt-get install flex bison gcc

Project Structure
.
├── lexer.l              # Flex file for lexical analysis
├── parser.y             # Bison file for syntax analysis
├── symbol_table.c       # Symbol table management
├── semantics.c          # Intermediate code generation
├── symbol_table.h
├── semantics.h
├── main.c               # Main driver
├── input.c              # Sample input code


How to Build and Run
1️⃣ Generate parser files:
                      bison -d parser.y
2️⃣ Generate lexer files:
                      flex lexer.l
3️⃣ Compile the project:
                      gcc -Wall -o compiler lex.yy.c parser.tab.c symbol_table.c semantics.c main.c
4️⃣ Run the compiler with an input file:
                      ./compiler input.c

Sample Input
=> int main() {
    int a = 5;
    int b = 10;
    int c = a + b;
    return c;
}

Sample Output
Tokens identified by the lexer
Parse tree construction messages
Symbol table with identifiers
Intermediate code (e.g., three-address code) 


also the tac will be generated in tac.txt and token are in token.txt


                
