%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h" /* Archivo generado por Bison que contiene los tokens */

/* Configuración para Windows */
#include <io.h>
#define isatty _isatty
#define YY_NO_UNISTD_H
%}

%option yylineno
%x COMENTARIO_BLOQUE

%%

    /* 1. Comentarios (Los ignoramos, no retornan nada) */
"//".* { /* Ignorar comentario linea */ }
"/*"                { BEGIN(COMENTARIO_BLOQUE); }
<COMENTARIO_BLOQUE>"*/" { BEGIN(INITIAL); }
<COMENTARIO_BLOQUE>(.|\n) { /* Ignorar contenido */ }

    /* 2. Preprocesador */
"#include".* { return PREPROC_INCLUDE; }
"#define"           { return PREPROC_DEFINE; }

    /* 3. Palabras Reservadas */
"int"               { return KW_INT; }
"float"             { return KW_FLOAT; }
"void"              { return KW_VOID; }
"return"            { return KW_RETURN; }

    /* 4. Identificadores y Números */
[a-zA-Z_][a-zA-Z0-9_]* { return ID; }
[0-9]+(\.[0-9]+)?       { return NUMBER; }

    /* 5. Operadores */
"+"                 { return OP_PLUS; }
"-"                 { return OP_MINUS; }
"*"                 { return OP_MULT; }
"/"                 { return OP_DIV; }
"="                 { return OP_ASSIGN; }

    /* 6. Delimitadores */
"("                 { return LPAREN; }
")"                 { return RPAREN; }
"{"                 { return LBRACE; }
"}"                 { return RBRACE; }
";"                 { return SEMICOLON; }
","                 { return COMMA; }

    /* 7. Ignorar espacios y saltos (Flex cuenta lineas con yylineno solo) */
[ \t\n]+            { /* Ignorar */ }

    /* 8. Error */
.                   { printf("Error lexico en linea %d: Caracter invalido '%s'\n", yylineno, yytext); }

%%

int yywrap() {
    return 1;
}
