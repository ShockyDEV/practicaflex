%option noyywrap
%option yylineno

%{
#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <string.h>

int count_rules = 0;
int count_properties = 0;
int count_margins = 0;
int count_urls = 0;

int in_rule = 0;
int after_colon = 0;
char selector_buf[4096] = {0};
int selector_len = 0;
int longest_selector_len = 0;
char longest_selector[4096] = {0};
char last_prop[128] = {0};

static void finalize_selector() {
    if (selector_len == 0) return;
    int start = 0;
    while (start < selector_len && (selector_buf[start] == ' ' || selector_buf[start] == '\t' || selector_buf[start] == '\n')) start++;
    int end = selector_len;
    while (end > start && (selector_buf[end - 1] == ' ' || selector_buf[end - 1] == '\t' || selector_buf[end - 1] == '\n')) end--;
    int current_len = end - start;
    if (current_len > longest_selector_len) {
        longest_selector_len = current_len;
        if (longest_selector_len >= (int)sizeof(longest_selector)) {
            longest_selector_len = (int)sizeof(longest_selector) - 1;
        }
        memcpy(longest_selector, selector_buf + start, longest_selector_len);
        longest_selector[longest_selector_len] = '\0';
    }
    selector_len = 0;
}
%}

IDENT   [a-zA-Z_][a-zA-Z0-9_-]*
COMMENT (\/\*([^*]|\*+[^*/])*\*+\/)
WS      [ \t\r\n]+

%%

{COMMENT}   { }

"{"         { finalize_selector(); in_rule = 1; after_colon = 0; count_rules++; }
"}"         { in_rule = 0; after_colon = 0; }

";"         {
                if(in_rule){
                    count_properties++;
                    if (strncmp(last_prop, "margin", 6) == 0) {
                        count_margins++;
                    }
                    after_colon = 0;
                    last_prop[0] = '\0';
                }
            }

":"         {
                if(in_rule) {
                    after_colon = 1;
                } else {
                    if (selector_len < (int)sizeof(selector_buf) - 1) selector_buf[selector_len++] = ':';
                }
            }

"url("      {
                if(in_rule && after_colon) {
                    count_urls++;
                } else if (!in_rule) {
                    const char* text = "url(";
                    if (selector_len + 4 < sizeof(selector_buf) -1) {
                        memcpy(selector_buf + selector_len, text, 4);
                        selector_len += 4;
                    }
                }
            }

{IDENT}     {
                if (in_rule && !after_colon) {
                    strncpy(last_prop, yytext, sizeof(last_prop) - 1);
                } else if (!in_rule) {
                    if (selector_len + yyleng < sizeof(selector_buf) - 1) {
                        memcpy(selector_buf + selector_len, yytext, yyleng);
                        selector_len += yyleng;
                    }
                }
            }

{WS}        {
                if (!in_rule) {
                    if (selector_len < sizeof(selector_buf) - 1) {
                       selector_buf[selector_len++] = ' ';
                    }
                }
            }

.           {
                if (!in_rule) {
                    if (selector_len < sizeof(selector_buf) - 1) {
                       selector_buf[selector_len++] = yytext[0];
                    }
                }
            }

%%
