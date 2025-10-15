/**
 * Fichero:     main.c
 * Autor:       Enrique González
 * Descripción: Programa principal para el analizador léxico de archivos CSS.
 * Este programa inicializa el analizador generado por Flex, le pasa
 * un archivo CSS (o la entrada estándar) y muestra las estadísticas
 * recopiladas al finalizar.

 */

#include <stdio.h>

 //  Declaraciones Externas 
 // 
 // 
 // Variables globales definidas y gestionadas en el fichero 'analizador.l'.
 // Flex las hace accesibles para que el programa principal pueda usarlas.

extern int yylex(void); // función principal del analizador, generada por Flex.
extern FILE* yyin;     // punntero al fichero de entradaa 

// contadores de estadísticass
extern int count_rules;
extern int count_properties;
extern int count_margins;
extern int count_urls;
extern int count_colors;

// Variables para el selector más largdo
extern int longest_selector_len;
extern char longest_selector[];

// vARriables para la propiedad con el valor más largo 
extern int longest_value_len;
extern char longest_value_prop[];
extern char longest_value_text[];


int main(int argc, char** argv) {
    // entrada 
    // 
    // 
    // determino si se debe leer desde un fichero pasado como argumento
    // o desde la entrada estándar (stdin).
    if (argc > 1) {
        if (fopen_s(&yyin, argv[1], "r") != 0) {
            perror("Error al abrir el archivo");
            return 1; // acaba si el fichero no se puede abrir.
        }
    }
    else {
        yyin = stdin;
    }

    printf("Comprobando el archivo CSS...\n");

    //  Ejecución del analisis
    // llamo a la función yylex() para que comience a procesar la entrada.

    yylex();

    //  print de resultados
    // muestro todas las estadísticas recopiladas por el analizador.
    printf("Resultados del analisis:\n");
    printf("Reglas encontradas: %d\n", count_rules);
    printf("Propiedades totales: %d\n", count_properties);
    printf("Propiedades de margen: %d\n", count_margins);
    printf("Propiedades de tipo URL: %d\n", count_urls);
    printf("Especificaciones de color: %d\n", count_colors);
    printf("Selector mas largo (%d caracteres): %s\n", longest_selector_len, longest_selector_len ? longest_selector : "N/A");

    if (longest_value_len > 0) {
        printf("Propiedad con valor mas largo (%d caracteres):\n", longest_value_len);
        printf("  - Propiedad: %s\n", longest_value_prop);
        printf("  - Valor: %s;\n", longest_value_text);
    }
    else {
        printf("Propiedad con valor mas largo: N/A\n");
    }

    printf("Comprobacion terminada jeje.\n");

    if (yyin != stdin) {
        fclose(yyin);
    }

    return 0;
}

