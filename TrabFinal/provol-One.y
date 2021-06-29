%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int yylex();
    int yyerror(char *s);
    extern FILE *yyin;
    extern int yyparse();   
    FILE *outFile;
%}

%union{
	char name[20];
    int number;
}

%token ENTRADA
%token SAIDA
%token FIM
%token FACA
%token ENQUANTO
%token SE
%token ENTAO
%token SENAO
%token INC
%token ZERA
%token EQ

%token <name> ID
%type <number> program
%type <number> varlist
%type <number> cmds
%type <number> cmd

%%

program : ENTRADA varlist SAIDA varlist cmds FIM 
{

};

varlist : varlist ID {} 
    | ID {$$ = $1;}
    ;

cmds : cmds cmd {}
    | cmd { $$ = $1; }
    ;

cmd : ENQUANTO ID FACA cmds FIM {};

%%

int yyerror(char *s)
{
	printf("Syntax Error on line %s\n", s);
	return 0;
}

int main(int argc, char **argv)
{
    if (argc != 2) {
        printf("provol-One: <Arquivo de Entrada> <Arquivo de Saida>");
        exit(-1);
    }

    FILE *arquivoEntrada = fopen(argv[1], "r");
    if (arquivoEntrada == NULL) {
        printf("Erro abrindo arquivo de entrada\n");
        exit(-1);
    }

    FILE *arquivoSaida = fopen(argv[2], "w");
    if (arquivoSaida == NULL) {
        printf("Erro abrindo arquivo de saída\n");
        exit(-1);
    }

    fprintf(fileC, "teste\n");

    yyparse();

    fclose(arquivoEntrada);
    fclose(arquivoSaida);
    return 0;
}