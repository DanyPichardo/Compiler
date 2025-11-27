#include <stdlib.h>
#define SCALE_FACTOR 2

int globalA;
int globalB;

int addValues(int first, int second){
    int resultLocal;
    resultLocal = first + second;
    return resultLocal;
}

int processValue (int value){
    int temporaryVal;
    temporaryVal = value * SCALE_FACTOR;
    {  // Bloque Anidado
        int innerResult;
        innerResult = temporaryVal + 5;
        printf(innerResult);
    }

    return temporaryVal;
}

int main(){
    int resultMain;
    int auxValue;

    globalA = 3;
    globalB = 4;

    resultMain = addValues(globalA, globalB);
    printf(resultMain);

    auxValue = processValue(resultMain);
    printf(auxValue);

    { /* Bloque Anidado */
        int finalOutput;
        finalOutput = auxValue + resultMain;
        printf(finalOutput);
    }

    return 0;
}
