%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

%union{
    char *str;
}

%token <str> ID NUM STRING BOOL

%token DISPOSITIVO
%token SET

%token SE ENTAO SENAO

%token LIGAR
%token DESLIGAR
%token VERIFICAR

%token ENVIAR ALERTA
%token PARA TODOS

%token GT LT GE LE EQ NE
%token AND

%%

programa
    : devices comandos
    ;

devices
    : devices device
    | device
    ;

device
    : DISPOSITIVO ':' '{' ID '}'
        {
        }
    | DISPOSITIVO ':' '{' ID ',' ID '}'
        {
            emit("%s = 0\n", $5);
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
            emit("%s = %s\n", $2, $4);
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
    ;

condicional
    : SE obs ENTAO acao '.'
        {
        }
    ;

obs
    : ID GT NUM
        {
            emit("if %s > %s:\n    ",
                 $1,
                 $3);
        }
    | ID LT NUM
        {
            emit("if %s < %s:\n    ",
                 $1,
                 $3);
        }
    | ID EQ NUM
        {
            emit("if %s == %s:\n    ",
                 $1,
                 $3);
        }
    ;

%%

void yyerror(const char *s)
{
    printf("Erro sintatico: %s\n",s);
}

int main(int argc,char **argv)
{
    if(argc < 2)
    {
        printf("uso: ./parser arquivo.obs\n");
        return 1;
    }

    yyin = fopen(argv[1],"r");

    saida = fopen("output.py","w");

    fprintf(saida,
"def ligar(device):\n"
"    print(device + \" ligado!\")\n"
"    return 1\n\n"

"def desligar(device):\n"
"    print(device + \" desligado!\")\n"
"    return 0\n\n"

"def verificar(device):\n"
"    print(device + \" esta ligado\")\n"
"    return 1\n\n"

"def alerta(device,msg):\n"
"    print(device + \" recebeu alerta:\")\n"
"    print(msg)\n\n");

    yyparse();

    fclose(saida);

    return 0;
}
