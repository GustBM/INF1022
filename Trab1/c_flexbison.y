%{
#include <stdio.h>

int yylex();
int yyerror(char *s);

%}

%token STRING NUM 
%token ADD SUB MUL DIV ABS
%token SEMICOLON
%token INT
%token OTHER 

%type <name> STRING
%type <number> NUM

%union{
	  char name[20];
    int number;
}

%%

exp: factor       { $$ = $1;}
 | exp ADD factor { $$ = $1 + $3; }
 | exp SUB factor { $$ = $1 - $3; }
 ;

factor: term       { $$ = $1;} 
 | factor MUL term { $$ = $1 * $3; }
 | factor DIV term { $$ = $1 / $3; }
 ;

term: NUMBER  { $$ = $1;} 
 | ABS term   { $$ = $2 >= 0? $2 : - $2; }
;

COMANDO = ...
|...
| INT IDENT = exp ; 

prog:
  stmts
;

stmts:
		| stmt SEMICOLON stmts

stmt:
		

%%

int yyerror(char *s)
{
	printf("Syntax Error on line %s\n", s);
	return 0;
}

int main()
{
    yyparse();
    return 0;
}
