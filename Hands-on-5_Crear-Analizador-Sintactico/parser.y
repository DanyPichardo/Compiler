%{
#include <stdio.h>
#include <stdlib.h>

// Declaramos las funciones externas
extern int yylex();
extern int yylineno; // Número de línea
extern char *yytext; // Texto que ocasionó el error

void yyerror(const char *s);
%}

/* Definición de Tokens (Deben coincidir con lo que retorna el Lexer) */
%token KW_INT KW_FLOAT KW_VOID KW_RETURN
%token PREPROC_INCLUDE PREPROC_DEFINE
%token ID NUMBER
%token OP_ASSIGN OP_PLUS OP_MINUS OP_MULT OP_DIV
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA

/* Precedencia de operadores (para evitar conflictos y ambigüedad) */
%left OP_PLUS OP_MINUS
%left OP_MULT OP_DIV

/* Token inicial de la gramática */
%start program

%%

/* --- REGLAS GRAMATICALES (CFG) --- */

program:
    declaration_list
    ;

declaration_list:
    declaration_list declaration
    | declaration
    ;

declaration:
    var_declaration
    | fun_declaration
    | preprocessor_directive
    ;

preprocessor_directive:
    PREPROC_INCLUDE
    | PREPROC_DEFINE ID NUMBER
    ;

var_declaration:
    type_specifier ID SEMICOLON
    | type_specifier ID OP_ASSIGN expression SEMICOLON
    ;

fun_declaration:
    type_specifier ID LPAREN params RPAREN block
    ;

type_specifier:
    KW_INT
    | KW_FLOAT
    | KW_VOID
    ;

params:
    param_list
    | /* vacio */
    ;

param_list:
    param_list COMMA param
    | param
    ;

param:
    type_specifier ID
    ;

block:
    LBRACE statement_list RBRACE
    ;

statement_list:
    statement_list statement
    | /* vacio */
    ;

statement:
    var_declaration
    | assignment
    | return_stmt
    | function_call_stmt
    | block
    ;

assignment:
    ID OP_ASSIGN expression SEMICOLON
    ;

return_stmt:
    KW_RETURN expression SEMICOLON
    | KW_RETURN SEMICOLON
    ;

function_call_stmt:
    ID LPAREN args RPAREN SEMICOLON
    ;

function_call_expr:
    ID LPAREN args RPAREN
    ;

args:
    arg_list
    | /* vacio */
    ;

arg_list:
    arg_list COMMA expression
    | expression
    ;

expression:
    expression OP_PLUS expression
    | expression OP_MINUS expression
    | expression OP_MULT expression
    | expression OP_DIV expression
    | LPAREN expression RPAREN
    | ID
    | NUMBER
    | function_call_expr
    ;

%%

/* --- FEEDBACK PARA USUARIO --- */

void yyerror(const char *s) {
    fprintf(stderr, "Error sintactico en la linea %d: %s. Token inesperado: '%s'\n", yylineno, s, yytext);
}

int main(int argc, char **argv) {
    extern FILE *yyin;
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Error al abrir el archivo");
            return 1;
        }
    }

    if (yyparse() == 0) {
        printf("\n Analisis Sintactico Completado Exitosamente. No se encontraron errores.\n");
    }

    return 0;
}
