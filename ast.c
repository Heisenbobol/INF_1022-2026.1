#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

extern FILE *saida;

No* novoNo(TipoNo t, char *v, No *a, No *b, No *c)
{
    No *n = malloc(sizeof(No));
    n->tipo = t;
    n->val = v ? strdup(v) : NULL;
    n->a = a;
    n->b = b;
    n->c = c;
    return n;
}