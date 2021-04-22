%{
  #include <stdio.h>
  #include "ExemploSimples.tab.h"

%}
  
id        [_a-zA-Z][_a-zA-Z0-9]*
wspc      [ \t\n]+
semi      [;]
comma     [,]

%%

int       { return INT; }
char      { return CHAR; }
float     { return FLOAT; }
{comma}   { return COMMA; }
{semi}    { return SEMI; }
{id}      { return ID; }
{wspc}    {;}

%%
/* descomente caso queira usar o lex sem o yacc
int main()
{
	yylex();
	printf("processando lex");
}
*/

int yywrap() {}