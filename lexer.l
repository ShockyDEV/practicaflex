%option noyywrap
%option yylineno

%{
#include <stdio.h>
#include <string.h>

int count_rules = 0;
int count_properties = 0;

int in_rule = 0;

char selector_buf[4096];
int selector_len = 0;

int longest_selector_len = 0;
char longest_selector[4096];

static void finalize_selector() {
    int start = 0;
    while (start < selector_len && (selector_buf[start] == ' ' || selector_buf[start] == '\t')) start++;
    int end = selector_len;
    while (end > start && (selector_buf[end-1] == ' ' || selector_buf[end-1] == '\t')) end--;
    int len = end - start;
    if (len > 0) {
        if (len > longest_selector_len) {
            if (len > (int)sizeof(longest_selector)-1) len = (int)sizeof(longest_selector)-1;
            memcpy(longest_selector, selector_buf + start, len);
            longest_selector[len] = '\0';
            longest_selector_len = len;
        }
    }
    selector_len = 0;
}
%}

IDENT   [a-zA-Z_][a-zA-Z0-9_-]*
COMMENT (\/\*([^*]|\*+[^*/])*\*+\/)
WS      [ \t\r\n]+

%%

{COMMENT}               ;
{WS}                    { if(!in_rule){ if(selector_len < (int)sizeof(selector_buf)-1) selector_buf[selector_len++]=' '; } }

"{"                     { finalize_selector(); in_rule = 1; count_rules++; }
"}"                     { in_rule = 0; }

";"                     { if(in_rule) count_properties++; }
":"                     ;

{IDENT}                 { if(!in_rule){ int n=yyleng; if(selector_len + n < (int)sizeof(selector_buf)-1){ memcpy(selector_buf+selector_len, yytext, n); selector_len += n; } } }

[^{}\n;]+               { if(!in_rule){ int n=yyleng; if(selector_len + n < (int)sizeof(selector_buf)-1){ memcpy(selector_buf+selector_len, yytext, n); selector_len += n; } } }

.                       ;

%%
