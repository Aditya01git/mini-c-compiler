#ifndef SEMANTICS_H
#define SEMANTICS_H

void open_tac_file();
void close_tac_file();
void emit(const char *fmt, ...);

char* new_temp();
char* lookup_type(char *name);
int type_compatible(char *t1, char *t2);
char* common_type(char *t1, char *t2);

#endif
