%option noyywrap
%option yylineno

%{
#include <stdio.h>
%}

%%

.|\n    {  }

%%
