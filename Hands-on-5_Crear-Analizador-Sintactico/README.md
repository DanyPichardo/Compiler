# Analizador Sintáctico

**Daniel Pichardo Sánchez**

## Descripción
El **Analizador Sintáctico** *(Parser)* es una extensión del **Analizador Léxico** *(Lexer)*.

Este analizador es capaz de:

* Reconocer directivas del preprocesador.
* Validar declaraciones de variables.
* Validar la definición de las funciones.
* Reconocer asignaciones, sentencias, llamadas de función.
* Reconocer la anidación por bloques.
* Reconocer expresiones aritméticas.
* Ignora los espacios, tabulaciones y saltos de línea. 

En caso de detectar un error, muestra al usuario un mensaje detallado sobre el error, incluyendo el número de línea donde se encuentra, descripción corta del problema y el token causante.

Además, confirma visualmente si el análisis se realizó con éxito.

## Compilación y ejecución

### Requisitos

* Flex
* Bison
* GCC u otro compilador de C

### Compilación

Ejecutar en consola lo siguiente:

1. bison -d parser.y
2. flex lexer.l
3. gcc parser.tab.c lex.yy.c -o parser.exe

Esto generará el archivo parser.exe

### Ejecución

En la consola ejecuter el siguiente comando:

./parser.exe input.c
