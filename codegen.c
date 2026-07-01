#include <stdio.h>
#include "ast.h"

extern FILE *saida;

int tab = 0;

void ind()
{
    for(int i=0;i<tab;i++)
        fprintf(saida,"    ");
}

void gerar(No *n)
{
    if(!n) return;

    switch(n->tipo)
    {
        case N_PROG:
            gerar(n->a);
            break;

        case N_LISTA:
            gerar(n->a);
            gerar(n->b);
            break;

        case N_SET:
            ind();
            fprintf(saida,"%s\n", n->val);
            break;

        case N_ACAO:
        case N_ALERTA:
            ind();
            fprintf(saida,"%s\n", n->val);
            break;

        case N_IF:
            ind();
            fprintf(saida,"if %s:\n", n->val);

            tab++;
            gerar(n->a);

            if(n->b)
            {
                tab--;
                ind();
                fprintf(saida,"else:\n");
                tab++;
                gerar(n->b);
            }

            tab--;
            break;
    }
}
