%{
#include <stdio.h>

float val=0;
int yylex();

void yyerror(const char *s){
	fprintf(stderr, "%s\n", s);
};

 void exibir(int valor)
{
    printf("val=%d\n", valor);
}
%}

%token EXP
%token SOMA
%token SUB
%token EQ
%token FIM_LINHA
%token MULT
%token DIV

%start comandos

%%
comandos : comando
	| comando comandos
    ;
comando  : FIM_LINHA
    | exps FIM_LINHA { exibir(val); }
    ;
exps : EXP 	{ val += $1; }
	| exps SOMA EXP  { val += $3; }
	| exps SUB EXP 	{ val -= $3; }
	| exps MULT EXP  { val *= $3; }
	| exps DIV EXP 	{ val /= $3; }
	| exps EQ EXP 	{ val = $3; }
	;
%%

int main(int argc, char *argv[])
{
    yyparse();
    return(0);
}
