%{
#include <stdio.h>

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    EXP = 258,
    SOMA = 259,
    SUB = 260,
    EQ = 261,
    FIM_LINHA = 262,
    MULT = 263,
    DIV = 264
  };
#endif
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

int main()
{
	yylex();
	printf("processando lex");
}

int yywrap() {}