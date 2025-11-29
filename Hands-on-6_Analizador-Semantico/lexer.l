%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h" //Archivo de tokens

/* --- WINDOWS CONFIG --- */
#include <io.h>           /* Necesario para isatty en Windows */
#define isatty _isatty    /* Mapear isatty a _isatty */
#define YY_NO_UNISTD_H    /* Evitar buscar unistd.h */
/* ---------------------------------------- */

%}

%option yylineno

/* Declaración de estados para manejar comentarios de bloque */
%x COMENTARIO_BLOQUE

%%

    /* 1. Comentarios */
"//".* { /* Se ignora el contenido del comentario */ }

"/*"                { BEGIN(COMENTARIO_BLOQUE); }
<COMENTARIO_BLOQUE>"*/" { BEGIN(INITIAL); }
<COMENTARIO_BLOQUE>(.|\n) { /* Ignorar contenido del comentario */ }

    /* 2. Palabras Reservadas del Preprocesador */
"#include".*        { return PREPROC_INCLUDE; }
"#define"           { return PREPROC_DEFINE; }

    /* 3. Palabras reservadas del Sistema */
"int"               { return KW_INT; }
"float"             { return KW_FLOAT; }
"void"              { return KW_VOID; }
"return"            { return KW_RETURN; }

    /* 4. Identificadores (Variables, funciones) */
[a-zA-Z_][a-zA-Z0-9_]* { yylval.sval = _strdup(yytext); return ID; }

    /* 5. Números */
[0-9]+(\.[0-9]+)?       { return NUMBER; }

    /* 6. Operadores */
"+"                 { return OP_PLUS; }
"-"                 { return OP_MINUS; }
"*"                 { return OP_MULT; }
"/"                 { return OP_DIV; }
"="                 { return OP_ASSIGN; }

    /* 7. Delimitadores y Simbolos Especiales */
"("                 { return LPAREN; }
")"                 { return RPAREN; }
"{"                 { return LBRACE; }
"}"                 { return RBRACE; }
";"                 { return SEMICOLON; }
","                 { return COMMA; }

    /* 8. Ignorar espacios en blanco, tabuladores y saltos de linea */
[ \t\n]+            { /* Ignorar */ }

    /* 9. Error: Carácter no reconocido */
.                   { printf("Error lexico en linea %d: Caracter invalido '%s'\n", yylineno, yytext); }

%%

int yywrap() {
    return 1;
}
