%{

#include <stdio.h>
#include <string.h>
#include "c_flexbison.tab.h"
void showError();
%}

numbers     ([0-9])+
alpha       ([a-zA-Z])+

%%

"+"    { return ADD; }
"-"    { return SUB; }
"*"    { return MUL; }
"/"    { return DIV; }
"int" {return INT;}
{alpha}		{sscanf(yytext, "%s", yylval.name); return (STRING);}
{numbers}	{yylval.number = atoi(yytext); return (NUM);}
";"		{return (SEMICOLON);}
.		{showError(); return(OTHER);}

%%


void showError(){
    printf("Other input");
}
