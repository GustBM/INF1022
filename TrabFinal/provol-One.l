%{
  #include <string.h>
  #include "provol-One.tab.h"

  void showError();

%}
%option noyywrap
%%
ENTRADA         { return ENTRADA; }
SAIDA           { return SAIDA; }
FIM             { return FIM; }
FACA            { return FACA; }
ENQUANTO        { return ENQUANTO; }
SE              { return SE; }
ENTAO           { return ENTAO; }
SENAO           { return SENAO; }
INC             { return INC; }
ZERA            { return ZERA; }
[a-zA-Z]+       { return ID; }
\=              { return EQ; }
.               { showError();};
%%

void showError(){
    printf("Other input");
}