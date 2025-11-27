# Analizador Léxico

**Daniel Pichardo Sánchez**

## Descripción
Este analizador es capaz de reconocer:

* Comentarios, tanto de línea como de bloque.
* Palabras reservadas, ya sean tipos de datos, sentencias del lenguaje o directivas del procesador.
* Identificadores válidos de variables y funciones.
* Literales numéricos.
* Operadores aritméticos, de asignación y de incremento/decremento.
* Símbolos y delimitadores

Además, ignora los espacios, tabulaciones y saltos de línea. 

En caso de no reconocer un carácter, lo reporta como un error.

## Compilación y ejecución

### Requisitos

* Flex
* GCC u otro compilador de C

### Compilación

Ejecutar en consola lo siguiente:

1. flex lexer.l
2. gcc lex.yy.c -o lexer

Esto generará el archivo lexer.exe

### Ejecución

En la consola ejecuter el siguiente comando:

./lexer.exe input.c
