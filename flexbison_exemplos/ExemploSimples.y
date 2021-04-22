%{
  #include <stdio.h>
  #include <stdlib.h>
  int yyparse();
  int yylex();
  void yyerror( char * mes );
%}

%start line
%token CHAR
%token COMMA
%token FLOAT
%token ID
%token INT
%token SEMI

%%

line : type ID list
   { printf("Compilou !!!!\n"); } ;
list :COMMA ID list | SEMI ;
type : CHAR | FLOAT;

%%

int main() {
    yyparse();
}

void yyerror(char *mes) {
    printf( "%s\n", mes );
}