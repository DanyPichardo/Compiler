%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// FUNCIONES EXTERNAS
extern int yylex();
extern int yylineno; // Número de línea
extern char *yytext; // Texto que ocasionó el error

void yyerror(const char *s);

/* --- ESTRUCTURA DE DATOS PARA LA TABLA DE SIMBOLOS --- */
struct Symbol {
    char *name;
    char *type;
    int scope_level;
    struct Symbol *next;
};

struct Symbol *symbol_table = NULL;
int current_scope = 0; // 0 = Global, 1 = Local
int semantic_errors = 0;

/* -- FUNCIONES DE LA TABLA DE SIMBOLOS -- */

// Insertar un símbolo (Variable o Función)
void insert_symbol(char *name, char *type) {
    // Verifica si hay redeclaracion
    struct Symbol *temp = symbol_table;
    while (temp != NULL) {
        if (strcmp(temp->name, name) == 0 && temp->scope_level == current_scope) {
            printf("ERROR SEMANTICO (Linea %d): Redeclaracion de variable '%s' en el mismo scope.\n", yylineno, name);
            semantic_errors++;
            return; // No lo agregamos si ya existe
        }
        temp = temp->next;
    }

    // Si no hay redeclaracion, agrega a la lista
    struct Symbol *new_node = (struct Symbol *)malloc(sizeof(struct Symbol));
    new_node->name = strdup(name);
    new_node->type = strdup(type);
    new_node->scope_level = current_scope;
    new_node->next = symbol_table;
    symbol_table = new_node;

    printf("-> Declarada variable '%s' (Scope: %d)\n", name, current_scope);
}

// Busca declaracion antes de ser usado
void check_undeclared(char *name) {
    struct Symbol *temp = symbol_table;
    int found = 0;

    // Buscamos desde el scope actual hacia afuera
    while (temp != NULL) {
        if (strcmp(temp->name, name) == 0) {
            // Regla de visibilidad: debe estar en scope actual o superior (menor número)
            if (temp->scope_level <= current_scope) {
                found = 1;
                break;
            }
        }
        temp = temp->next;
    }

    if (!found) {
        printf("ERROR SEMANTICO (Linea %d): Variable '%s' no declarada.\n", yylineno, name);
        semantic_errors++;
    }
}

// SCOPES
void increase_scope() {
    current_scope++;
}

void decrease_scope() {
    // Al salir de un scope, eliminamos las variables de ese scope (limpieza)
    struct Symbol *temp = symbol_table;
    struct Symbol *prev = NULL;

    while (temp != NULL) {
        if (temp->scope_level == current_scope) {
            // Eliminar nodo
            struct Symbol *to_delete = temp;
            if (prev == NULL) {
                symbol_table = temp->next;
                temp = symbol_table;
            } else {
                prev->next = temp->next;
                temp = temp->next;
            }
            // free(to_delete->name); // Opcional liberar memoria
            // free(to_delete);
        } else {
            prev = temp;
            temp = temp->next;
        }
    }
    current_scope--;
}

%}

/* Union para nombres de variables como strings */
%union {
    char *sval;
    int ival;
}

/* Definición de Tokens (Deben coincidir con lo que retorna el Lexer) */
%token <sval> ID
%token NUMBER
%token KW_INT KW_FLOAT KW_VOID KW_RETURN
%token PREPROC_INCLUDE PREPROC_DEFINE
%token OP_ASSIGN OP_PLUS OP_MINUS OP_MULT OP_DIV
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA

/* Precedencia de operadores */
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
    | PREPROC_DEFINE ID NUMBER {
        insert_symbol($2, "const");
    }
    ;

var_declaration:
    type_specifier ID SEMICOLON {
        insert_symbol($2, "int"); // Inserta en Tabla
    }
    | type_specifier ID OP_ASSIGN expression SEMICOLON {
        insert_symbol($2, "int"); // Inserta en Tabla
    }
    ;

fun_declaration:
    type_specifier ID {
        insert_symbol($2, "func");
    } LPAREN {
        increase_scope();
    } params RPAREN block_content
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
    type_specifier ID {
        insert_symbol($2, "param"); // Parametros son locales
    }
    ;

block:
    LBRACE {
        increase_scope();
    } statement_list RBRACE {
        decrease_scope();
    }
    ;

block_content:
    LBRACE statement_list RBRACE {
        decrease_scope();
    }
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
    ID OP_ASSIGN expression SEMICOLON {
        check_undeclared($1); // Verifica la existencia del ID
    }
    ;

return_stmt:
    KW_RETURN expression SEMICOLON
    | KW_RETURN SEMICOLON
    ;

function_call_stmt:
    ID LPAREN args RPAREN SEMICOLON {
        check_undeclared($1); // Verifica la existencia de la funcion
    }
    ;

function_call_expr:
    ID LPAREN args RPAREN {
        check_undeclared($1);
    }
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
    | ID { check_undeclared($1); }
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
    insert_symbol("printf", "func");

    printf("--- ANALISIS SEMANTICO ---");
    if (yyparse() > 0) {
        printf("\n Analisis Semántico completado con %d errores.\n, semantic_errors");
    }else{
        printf("\n Analisis Semántico completado exitosamente. No se encontraron errores.\n");
    }
    printf("--- FIN DEL ANALISIS ---");
    return 0;
}
