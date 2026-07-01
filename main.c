#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

extern int yyparse();
extern FILE *yyin;
extern No *root;          /* <-- extern, não definição */

FILE *saida;

int main(int argc, char **argv)
{
    if (argc < 3) {
        fprintf(stderr, "Uso: %s <entrada.obsact> <saida.py>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Erro ao abrir arquivo de entrada");
        return 1;
    }

    saida = fopen(argv[2], "w");
    if (!saida) {
        perror("Erro ao abrir arquivo de saida");
        fclose(yyin);
        return 1;
    }

    yyparse();

    fclose(yyin);
    fclose(saida);
    return 0;
}
