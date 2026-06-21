%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

int linha = 1;
%}

%option noyywrap

DIGITO      [0-9]
LETRA       [a-zA-Z]
ID          {LETRA}({LETRA}|{DIGITO}|_)*
NUMERO      {DIGITO}+
STRING      \"([^\"\n]|\\\")*\"

%%

"dispositivo"          { return DISPOSITIVO; }

"set"                  { return SET; }

"se"                   { return SE; }
"entao"                { return ENTAO; }
"senao"                { return SENAO; }

"ligar"                { return LIGAR; }
"desligar"             { return DESLIGAR; }
"verificar"            { return VERIFICAR; }

"enviar"               { return ENVIAR; }
"alerta"               { return ALERTA; }

"para"                 { return PARA; }
"todos"                { return TODOS; }

"True"                 {
                            yylval.str = strdup("True");
                            return BOOL;
                        }

"False"                {
                            yylval.str = strdup("False");
                            return BOOL;
                        }

"&&"                   { return AND; }

">="                   { return GE; }
"<="                   { return LE; }
"=="                   { return EQ; }
"!="                   { return NE; }
">"                    { return GT; }
"<"                    { return LT; }

"="                    { return '='; }

":"                    { return ':'; }
","                    { return ','; }
"."                    { return '.'; }

"("                    { return '('; }
")"                    { return ')'; }

"{"                    { return '{'; }
"}"                    { return '}'; }

{NUMERO}               {
                            yylval.str = strdup(yytext);
                            return NUM;
                        }

{STRING}               {
                            yylval.str = strdup(yytext);
                            return STRING;
                        }

{ID}                   {
                            yylval.str = strdup(yytext);
                            return ID;
                        }

[ \t\r]+               ;

\n                     { linha++; }

.                      {
                            printf(
                                "Erro lexico na linha %d: caractere '%s'\n",
                                linha,
                                yytext
                            );
                        }

%%
