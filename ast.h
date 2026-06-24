#ifndef AST_H
#define AST_H

typedef enum {
    N_PROG,
    N_LISTA,
    N_SET,
    N_ACAO,
    N_ALERTA,
    N_IF,
    N_COND
} TipoNo;

typedef struct No {
    TipoNo tipo;
    char *val;

    struct No *a;
    struct No *b;
    struct No *c;
} No;

No* novoNo(TipoNo t, char *v, No *a, No *b, No *c);

void gerar(No *n);

#endif