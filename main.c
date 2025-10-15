#include <stdio.h>

extern int yylex(void);
extern FILE* yyin;

extern int count_rules;
extern int count_properties;
extern int longest_selector_len;
extern char longest_selector[];

int main(int argc, char** argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Error al abrir el archivo");
            return 1;
        }
    }
    else {
        yyin = stdin;
    }

    printf("Comprobando el archivo CSS...\n");
    yylex();

    printf("Reglas: %d\n", count_rules);
    printf("Propiedades: %d\n", count_properties);
    printf("Selector mas largo (%d): %s\n", longest_selector_len, longest_selector_len ? longest_selector : "");
    printf("Comprobacion terminada jeje.\n");

    return 0;
}
