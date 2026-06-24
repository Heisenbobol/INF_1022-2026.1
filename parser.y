%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

extern int yylex();
extern FILE *yyin;

void yyerror(const char *s);

FILE *saida;

void emit(const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    vfprintf(saida, fmt, args);
    va_end(args);
}
%}
%union {
    char *str;
}
%token <str> ID
%token <str> NUM
%token <str> STRING
%token <str> BOOL

%token DISPOSITIVO
%token SET

%token SE
%token ENTAO
%token SENAO

%token LIGAR
%token DESLIGAR
%token VERIFICAR

%token ENVIAR
%token ALERTA

%token PARA
%token TODOS

%token GT LT GE LE EQ NE
%token AND
%type <str> valor
%type <str> expressao
%type <str> condicao
%%

lista_dispositivos
    : ID
    | lista_dispositivos ',' ID
    ;

programa
    : dispositivos comandos
    ;

dispositivos
    : dispositivos dispositivo
    | dispositivo
    ;

dispositivo
    : DISPOSITIVO ':' '{' ID '}'
        {
        }

    | DISPOSITIVO ':' '{' ID ',' ID '}'
        {
            emit("%s = 0\n",$5);
        }
    ;

comandos
    : comandos comando
    | comando
    ;

comando
    : atribuicao '.'
    | acao '.'
    | alerta '.'
    | condicional
    ;

atribuicao
    : SET ID '=' valor
        {
            emit("%s = %s\n",$2,$4);
        }
    ;

valor
    : NUM
        {
            $$ = $1;
        }

    | BOOL
        {
            $$ = $1;
        }

    | ID
        {
            $$ = $1;
        }
    ;

acao
    : LIGAR ID
        {
            emit("ligar(\"%s\")\n",$2);
        }

    | DESLIGAR ID
        {
            emit("desligar(\"%s\")\n",$2);
        }

    | VERIFICAR '(' ID ')'
        {
            emit("verificar(\"%s\")\n",$3);
        }
    ;

alerta
    : ENVIAR ALERTA '(' STRING ')' ID
        {
            emit(
                "alerta(\"%s\", %s)\n",
                $6,
                $4
            );
        }

    | ENVIAR ALERTA '(' STRING ',' ID ')' ID
        {
            emit(
                "alerta_var(\"%s\", %s, %s)\n",
                $8,
                $4,
                $6
            );
        }
alerta
    :
      ...
    | ENVIAR ALERTA '(' STRING ')' PARA TODOS ':'
      lista_dispositivos
      {
      }

condicao
    : ID GT valor
        {
            char *tmp = malloc(256);
            sprintf(tmp,"%s > %s",$1,$3);
            $$ = tmp;
        }

    | ID LT valor
        {
            char *tmp = malloc(256);
            sprintf(tmp,"%s < %s",$1,$3);
            $$ = tmp;
        }

    | ID GE valor
        {
            char *tmp = malloc(256);
            sprintf(tmp,"%s >= %s",$1,$3);
            $$ = tmp;
        }

    | ID LE valor
        {
            char *tmp = malloc(256);
            sprintf(tmp,"%s <= %s",$1,$3);
            $$ = tmp;
        }

    | ID EQ valor
        {
            char *tmp = malloc(256);
            sprintf(tmp,"%s == %s",$1,$3);
            $$ = tmp;
        }

    | ID NE valor
        {
            char *tmp = malloc(256);
            sprintf(tmp,"%s != %s",$1,$3);
            $$ = tmp;
        }
    ;
condicao
    : condicao AND condicao
        {
            char *tmp = malloc(512);

            sprintf(
                tmp,
                "(%s) and (%s)",
                $1,
                $3
            );

            $$ = tmp;
        }
condicional
    : SE condicao ENTAO acao '.'
        {
            emit(
                "if %s:\n",
                $2
            );
        }
condicional
    : SE condicao ENTAO acao
      SENAO acao '.'
        {
            emit(
                "if %s:\n"
                "    ...\n"
                "else:\n"
                "    ...\n",
                $2
            );
        }
%%

void yyerror(const char *s)
{
    fprintf(stderr,"Erro: %s\n",s);
}
