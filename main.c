#include <stdio.h>


extern int yylex(void);
extern FILE* yyin;

extern int count_rules;
extern int count_properties;
extern int count_margins;
extern int count_urls; 
extern int longest_selector_len;
extern char longest_selector[];

int main(int argc, char** argv) {
    
    if (argc > 1) {
        
        if (fopen_s(&yyin, argv[1], "r") != 0) {
            perror("Error al abrir el archivo");
            return 1;
        }
    }
    else {
        
        yyin = stdin;
    }

    printf("Comprobando el archivo CSS...\n");

    
    yylex();

    

    printf("Resultados del analisis:\n");
    printf("Reglas encontradas: %d\n", count_rules);
    printf("Propiedades totales: %d\n", count_properties);
    printf("Propiedades de margen: %d\n", count_margins);
    printf("Propiedades de tipo URL: %d\n", count_urls);
    printf("Selector mas largo (%d caracteres): %s\n", longest_selector_len, longest_selector_len ? longest_selector : "N/A");
    printf("Comprobacion terminada jeje.\n");

    if (yyin != stdin) {
        fclose(yyin);
    }

    return 0;
}

