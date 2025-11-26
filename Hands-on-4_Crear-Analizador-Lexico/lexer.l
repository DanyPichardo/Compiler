%{
#include <stdio.h>
#include <stdlib.h>

/* --- BLOQUE DE COMPATIBILIDAD WINDOWS --- */
#include <io.h>           /* Necesario para isatty en Windows */
#define isatty _isatty    /* Mapear isatty a _isatty */
#define YY_NO_UNISTD_H    /* Evitar buscar unistd.h */
/* ---------------------------------------- */

%}

/* Declaración de estados para manejar comentarios de bloque */
%x COMENTARIO_BLOQUE

%%

    /* 1. Comentarios */
"//".* { printf("COMENTARIO_LINEA: %s\n", yytext); }

"/*"                { BEGIN(COMENTARIO_BLOQUE); printf("INICIO_COMENTARIO: /*\n"); }
<COMENTARIO_BLOQUE>"*/" { BEGIN(INITIAL); printf("FIN_COMENTARIO: */\n"); }
<COMENTARIO_BLOQUE>(.|\n) { /* Ignorar contenido dentro del comentario */ }

    /* 2. Palabras Reservadas del Sistema y Preprocesador */
"include"|"define"  { printf("PREPROCESADOR_KW: %s\n", yytext); }
"int"|"float"|"double"|"char"|"void"|"short"|"return" { printf("PALABRA_RESERVADA: %s\n", yytext); }

    /* 3. Identificadores (Variables, funciones) */
[a-zA-Z_][a-zA-Z0-9_]* { printf("IDENTIFICADOR: %s\n", yytext); }

    /* 4. Literales Numéricos */
[0-9]+              { printf("ENTERO: %s\n", yytext); }
[0-9]*\.[0-9]+      { printf("FLOTANTE: %s\n", yytext); }

    /* 5. Operadores */
"++"                { printf("OPERADOR_INCREMENTO: %s\n", yytext); }
"+"                 { printf("OPERADOR_SUMA: %s\n", yytext); }
"-"                 { printf("OPERADOR_RESTA: %s\n", yytext); }
"*"                 { printf("OPERADOR_MULT: %s\n", yytext); }
"/"                 { printf("OPERADOR_DIV: %s\n", yytext); }
"="                 { printf("OPERADOR_ASIG: %s\n", yytext); }

    /* 6. Delimitadores y Simbolos Especiales */
"("                 { printf("PARENTESIS_IZQ: %s\n", yytext); }
")"                 { printf("PARENTESIS_DER: %s\n", yytext); }
"{"                 { printf("LLAVE_IZQ: %s\n", yytext); }
"}"                 { printf("LLAVE_DER: %s\n", yytext); }
";"                 { printf("PUNTO_Y_COMA: %s\n", yytext); }
","                 { printf("COMA: %s\n", yytext); }
"#"                 { printf("HASH: %s\n", yytext); }
"<"                 { printf("MENOR_QUE: %s\n", yytext); }
">"                 { printf("MAYOR_QUE: %s\n", yytext); }

    /* 7. Ignorar espacios en blanco, tabuladores y saltos de linea */
[ \t\n]+            { /* Ignorar */ }

    /* 8. Manejo de errores (caracteres no reconocidos) */
.                   { printf("ERROR_LEXICO: %s\n", yytext); }

%%

/* Código de usuario C necesario para correr el programa */
int yywrap() {
    return 1;
}

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Error abriendo el archivo");
            return 1;
        }
    }
    yylex();
    return 0;
}
