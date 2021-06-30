%{
  #include <stdio.h>
  #include "provol-One.tab.h"

  void showError();

%}
%option noyywrap
%%
ENTRADA         { return ENTRADA;}
SAIDA           { return SAIDA; }
FIM             { return FIM; }
FACA            { return FACA; }
ENQUANTO        { return ENQUANTO; }
SE              { return SE; }
ENTAO           { return ENTAO; }
SENAO           { return SENAO; }
INC             { return INC; }
ZERA            { return ZERA; }
ABREPAR         { return ABREPAR; }
FECHAPAR        { return FECHAPAR; }
[a-zA-Z]+       { yylval.content=strdup(yytext); return ID;}
"="             { return IGUAL;}
.               { showError();}
%%

void showError(){
  printf("Other input\n");
}