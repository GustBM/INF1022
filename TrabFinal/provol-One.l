%option yywrap
    #include <stdio.h>
    #include "y.tab.h"
%%

ENTRADA     return (ENTRADA);
SAIDA       return (SAIDA);
FACA        return (FACA);
INC         return (INC);
ZERA        return (ZERA);
FIM         return (FIM);
VEZES       return (VEZES);
SE          return (SE);
SENAO       return (SENAO);
ENQUANTO    return (ENQUANTO);
"("         return (ABREPAR);
")"         return (FECHAPAR);
"="         return (IGUAL);
#.*         {showError();}
[a-zA-Z]    {yylval.sval =strdup(yytext); return (ID);}
[ /t]       {}

%%

void showError(){
  printf("Other input\n");
}
