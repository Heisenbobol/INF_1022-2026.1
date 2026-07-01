%code requires {
    #include "ast.h"
}
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"  


extern int yylex();

No *root;

void yyerror(const char *s);
%}

%union {
    char *str;
    No *node;
}

%token <str> ID NUM STRING BOOL
%token DISPOSITIVO SET SE ENTAO SENAO
%token LIGAR DESLIGAR VERIFICAR
%token ENVIAR ALERTA PARA TODOS
%token GT LT GE LE EQ NE AND

%type <node> programa comandos comando
%type <node> atribuicao acao alerta condicional
%type <str> valor condicao lista_ids

%left AND

%%

programa
    : dispositivos comandos
        {
            root = novoNo(N_PROG, NULL, $2, NULL, NULL);
            gerar(root);
        }
    ;

dispositivos
    : dispositivos dispositivo
    | dispositivo
    ;

dispositivo
    : DISPOSITIVO ':' '{' ID '}'
    | DISPOSITIVO ':' '{' ID ',' ID '}'
    ;

comandos
    : comandos comando
        { $$ = novoNo(N_LISTA, NULL, $1, $2, NULL); }
    | comando
        { $$ = $1; }
    ;

comando
    : atribuicao '.'
        { $$ = $1; }
    | acao '.'
        { $$ = $1; }
    | alerta '.'
        { $$ = $1; }
    | condicional '.'                       /* <-- FIX #4: exige '.' no fim */
        { $$ = $1; }
    ;

atribuicao
    : SET ID '=' valor
        {
            char buf[256];
            sprintf(buf, "%s = %s", $2, $4);
            $$ = novoNo(N_SET, buf, NULL, NULL, NULL);
        }
    | SET ID '=' VERIFICAR '(' ID ')'
        {
            char buf[256];
            sprintf(buf, "%s = verificar(\"%s\")", $2, $6);
            $$ = novoNo(N_SET, buf, NULL, NULL, NULL);
        }
    ;

acao
    : LIGAR ID
        {
            char buf[256];
            sprintf(buf, "ligar(\"%s\")", $2);
            $$ = novoNo(N_ACAO, buf, NULL, NULL, NULL);
        }
    | DESLIGAR ID
        {
            char buf[256];
            sprintf(buf, "desligar(\"%s\")", $2);
            $$ = novoNo(N_ACAO, buf, NULL, NULL, NULL);
        }
    | VERIFICAR '(' ID ')'
        {
            char buf[256];
            sprintf(buf, "verificar(\"%s\")", $3);
            $$ = novoNo(N_ACAO, buf, NULL, NULL, NULL);
        }
    ;

alerta
    /* enviar alerta (msg) namedevice */
    : ENVIAR ALERTA '(' STRING ')' ID
        {
            char buf[256];
            sprintf(buf, "alerta(\"%s\", %s)", $6, $4);
            $$ = novoNo(N_ALERTA, buf, NULL, NULL, NULL);
        }

    /* FIX #2: enviar alerta (msg, observation) namedevice */
    | ENVIAR ALERTA '(' STRING ',' ID ')' ID
        {
            char buf[300];
            sprintf(buf, "alerta(\"%s\", %s, %s)", $8, $4, $6);
            $$ = novoNo(N_ALERTA, buf, NULL, NULL, NULL);
        }

    /* FIX #1 e #3: enviar alerta (msg) para todos: dev1, dev2, ... */
    | ENVIAR ALERTA '(' STRING ')' PARA TODOS ':' lista_ids
        {
            char buf[512];
            sprintf(buf, "alerta_broadcast(%s, [%s])", $4, $9);
            $$ = novoNo(N_ALERTA, buf, NULL, NULL, NULL);
        }
    ;

lista_ids
    : lista_ids ',' ID
        {
            char *t = malloc(strlen($1) + strlen($3) + 8);
            sprintf(t, "%s, \"%s\"", $1, $3);
            $$ = t;
        }
    | ID
        {
            char *t = malloc(strlen($1) + 8);
            sprintf(t, "\"%s\"", $1);
            $$ = t;
        }
    ;

condicional
    : SE condicao ENTAO comandos
        {
            $$ = novoNo(N_IF, $2, $4, NULL, NULL);
        }
    | SE condicao ENTAO comandos SENAO comandos
        {
            $$ = novoNo(N_IF, $2, $4, $6, NULL);
        }
    ;

condicao
    : ID GT valor { char *t = malloc(256); sprintf(t, "%s > %s", $1, $3);  $$ = t; }
    | ID LT valor { char *t = malloc(256); sprintf(t, "%s < %s", $1, $3);  $$ = t; }
    | ID GE valor { char *t = malloc(256); sprintf(t, "%s >= %s", $1, $3); $$ = t; }
    | ID LE valor { char *t = malloc(256); sprintf(t, "%s <= %s", $1, $3); $$ = t; }
    | ID EQ valor { char *t = malloc(256); sprintf(t, "%s == %s", $1, $3); $$ = t; }
    | ID NE valor { char *t = malloc(256); sprintf(t, "%s != %s", $1, $3); $$ = t; }
    | condicao AND condicao
        { char *t = malloc(512); sprintf(t, "(%s) and (%s)", $1, $3); $$ = t; }
    ;

valor
    : NUM  { $$ = $1; }
    | BOOL { $$ = $1; }
    | ID   { $$ = $1; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}
