#include <stdio.h>

extern int yylex(void);
extern FILE* yyin;

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

    printf("Comprobacion terminada jeje.\n");
    return 0;
}
