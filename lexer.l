/**

 * Fichero:     lexer.l
 * Autor:       Enrique González
 * Descripción: Analizador léxico para hojas de estilo CSS, implementado con Flex.
 * Definimos las reglas para identificar y contar diferentes
 * elementos de un archivo CSS, como reglas, propiedades, márgenes,
 * URLs y colores (formato HEX y  nombre).
 */

%option noyywrap
%option yylineno

%{

#define _CRT_SECURE_NO_WARNINGS // Desactivo advertencias de seguridad de MSVC.
#include <stdio.h>
#include <string.h>

//  Variables Globales
int count_rules = 0;        // Nº total de reglas (bloques {}).
int count_properties = 0;   // Nº total de propiedades (declaraciones ;).
int count_margins = 0;      // Nº de propiedades de tipo 'margin'.
int count_urls = 0;         // Nº de valores que contienen 'url('.
int count_colors = 0;       // Nº de colores (HEX o por nombre).

//  Buffers y banderas de estado 
int in_rule = 0;        // Bandera: 1 si estamos dentro de una regla {}, 0 si no.
int after_colon = 0;    // Bandera: 1 si estamos leyendo el valor de una propiedad.

//  Lógica del selector más Largo 
char selector_buf[4096] = {0};      // Buffer temporal para el selector actual.
int selector_len = 0;               // Longitud del selector en el buffer.
int longest_selector_len = 0;       // Longitud del selector más largo encontrado.
char longest_selector[4096] = {0};  // Texto del selector más largo.
char last_prop[128] = {0};          // Nombre de la última propiedad leída.

//  Lógica para el valor de propiedad más Largo 
char longest_value_prop[128] = {0};     // Nombre de la propiedad con el valor más largo.
char longest_value_text[4096] = {0};    // Texto del valor más largo.
int longest_value_len = -1;             // Longitud del valor más largo.
char current_value_buf[4096] = {0};     // Buffer para el valor actual.
int current_value_len = 0;              // Longitud del valor actual.

/**
 * @brief Procesa y guarda el selector más largo encontrado hasta el momento.
 * Limpia los espacios en blanco al inicio y al final del selector.
 */
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
    selector_len = 0; // Resetea el buffer para el siguiente selector.
}

/**
 * @brief Comprueba si una cadena de texto corresponde a un color CSS por nombre.
 * @param s La cadena a comprobar.
 * @return 1 si es un color por nombre, 0 en caso contrario.
 */
static int is_named_color(const char* s) {
    const char* colors[] = {
        "black", "gray", "silver", "white", "maroon", "red", "purple", "green",
        "lime", "olive", "yellow", "navy", "blue", "teal", "aqua", "orange", NULL
    };
    for (int i = 0; colors[i] != NULL; i++) {
        if (strcmp(s, colors[i]) == 0) {
            return 1;
        }
    }
    return 0;
}

%}

/*  Definiciones Regulares de Flex  */
HEX_COLOR       #([a-fA-F0-9]{3}|[a-fA-F0-9]{6}|[a-fA-F0-9]{8})
IDENT           [a-zA-Z_][a-zA-Z0-9_-]*
COMMENT         (\/\*([^*]|\*+[^*/])*\*+\/)
WS              [ \t\r\n]+

/*  Reglas de Flex  */
%%

{COMMENT}   { /* Ignorar comentarios */ }

"{"         { finalize_selector(); in_rule = 1; after_colon = 0; count_rules++; }
"}"         { in_rule = 0; after_colon = 0; }

";"         {
                if(in_rule){
                    count_properties++;
                    if (strncmp(last_prop, "margin", 6) == 0) {
                        count_margins++;
                    }
                    if (current_value_len > longest_value_len) {
                        longest_value_len = current_value_len;
                        strncpy(longest_value_prop, last_prop, sizeof(longest_value_prop) - 1);
                        strncpy(longest_value_text, current_value_buf, sizeof(longest_value_text) - 1);
                    }
                    after_colon = 0;
                    last_prop[0] = '\0';
                }
            }

":"         {
                if(in_rule) {
                    after_colon = 1;
                    current_value_len = 0;
                    current_value_buf[0] = '\0';
                } else {
                    if (selector_len < (int)sizeof(selector_buf) - 1) selector_buf[selector_len++] = ':';
                }
            }

{HEX_COLOR} {
                if(in_rule && after_colon) {
                    count_colors++;
                    if (current_value_len + yyleng < sizeof(current_value_buf) - 1) {
                        memcpy(current_value_buf + current_value_len, yytext, yyleng);
                        current_value_len += yyleng;
                    }
                }
            }

"url("      {
                if(in_rule && after_colon) {
                    count_urls++;
                    const char* text = "url(";
                    if (current_value_len + 4 < sizeof(current_value_buf) -1) {
                        memcpy(current_value_buf + current_value_len, text, 4);
                        current_value_len += 4;
                    }
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
                } else if (in_rule && after_colon) {
                    if(is_named_color(yytext)) {
                        count_colors++;
                    }
                    if (current_value_len + yyleng < sizeof(current_value_buf) - 1) {
                        memcpy(current_value_buf + current_value_len, yytext, yyleng);
                        current_value_len += yyleng;
                    }
                } else if (!in_rule) {
                    if (selector_len + yyleng < sizeof(selector_buf) - 1) {
                        memcpy(selector_buf + selector_len, yytext, yyleng);
                        selector_len += yyleng;
                    }
                }
            }

{WS}        {
                if (!in_rule) {
                    if (selector_len < sizeof(selector_buf) - 1) selector_buf[selector_len++] = ' ';
                } else if (in_rule && after_colon) {
                    if (current_value_len < sizeof(current_value_buf) - 1) {
                       current_value_buf[current_value_len++] = ' ';
                    }
                }
            }

.           {
                if (!in_rule) {
                    if (selector_len < sizeof(selector_buf) - 1) {
                       selector_buf[selector_len++] = yytext[0];
                    }
                } else if (in_rule && after_colon) {
                    if (current_value_len < sizeof(current_value_buf) - 1) {
                       current_value_buf[current_value_len++] = yytext[0];
                    }
                }
            }

%%
