#include <stdio.h>
#include "ast.h"

extern int yyparse();
extern FILE *saida;

FILE *saida;
No *root;

int main()
{
    saida = fopen("saida.py","w");

    yyparse();

    fclose(saida);
    return 0;
}