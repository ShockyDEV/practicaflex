%option noyywrap
%option yylineno

%{
#include <stdio.h>
%}



IDENTIFICADOR   [a-zA-Z_][a-zA-Z0-9_-]*
COMENTARIO      (\/\*([^*]|\*+[^*/])*\*+\/)
ESPACIOS        [ \t\r\n]+

%%

{COMENTARIO}              ;
{ESPACIOS}                ;
"{"                       { printf("TOKEN: { APERTURA_LLAVE }\n"); }
"}"                       { printf("TOKEN: { CIERRE_LLAVE }\n"); }
":"                       { printf("TOKEN: { DOS_PUNTOS }\n"); }
";"                       { printf("TOKEN: { PUNTOYCOMA }\n"); }
{IDENTIFICADOR}           { printf("TOKEN: { IDENTIFICADOR } -> %s\n", yytext); }
.                         ;

%%
