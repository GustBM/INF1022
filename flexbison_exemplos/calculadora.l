%{
#include <stdio.h>
#include "calculadora.tab.h"
%}

%%

[0-9]+  { printf("lido %s\n",yytext);yylval=atoi(yytext); return(EXP); }
\n      return(FIM_LINHA);
"+"     return(SOMA);
"-"     return(SUB);
"*"	 	return(MULT);
"/"	 	return(DIV);
"="     return(EQ);
fim    return(0);
.       ;

%%

/* descomente caso queira usar o lex sem o yacc
int main()
{
	yylex();
	printf("processando lex");
}
*/

int yywrap() {}