# 🚀 Mini Compiler Project

A **Mini Compiler Project** for **Compiler Design (CD)** implementing the **first four phases of a compiler:**

✅ **Lexical Analysis** (using Flex)  
✅ **Syntax Analysis** (using Bison)  
✅ **Symbol Table Management**  
✅ **Intermediate Code Generation**

---

## ✨ Features

- Token generation using a lexer
- Parsing using a grammar with Bison
- Symbol table creation and lookup
- Intermediate code generation for expressions and statements

---

## 🛠️ Prerequisites

- **Flex** (Lexical Analyzer Generator)
- **Bison** (Parser Generator)
- **GCC** (GNU Compiler Collection)

Install on Linux using:
```bash
sudo apt-get install flex bison gcc
---

## 📂 Project Structure

.
├── lexer.l # Flex file for lexical analysis
├── parser.y # Bison file for syntax analysis
├── symbol_table.c # Symbol table management
├── semantics.c # Intermediate code generation
├── symbol_table.h
├── semantics.h
├── main.c # Main driver
├── input.c # Sample input code

---
Follow these steps in your terminal:

1️⃣ **Generate parser files using Bison:**
```bash
bison -d parser.y

2️⃣  **Generate lexer files using Flex:**
```bash
flex lexer.l

3️⃣ **Compile the project using GCC:**
```bash
gcc -Wall -o compiler lex.yy.c parser.tab.c symbol_table.c semantics.c main.c

4️⃣  **Run the compiler with an input file:**
```bash
./compiler input.c

---
