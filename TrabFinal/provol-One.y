%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int yylex();
    int yyerror(char *s);
    extern FILE *yyin;
    extern int yyparse();   
    FILE *outFile;
    char* varArray[2];
%}

%union{
    char name[20];
    int number;
    char* content;
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
%token IGUAL
%token ABREPAR
%token FECHAPAR

%token <name> ID
%type <number> program
%type <content> varlist
%type <content> cmds
%type <content> cmd

%%

program: ENTRADA varlist SAIDA varlist cmds FIM 
{
	char* entradas= $2;
	char* saidas = $4;
	char* varEntrada = strtok(entradas, " ");
	int i=0;
	while (varEntrada != NULL) {
        fprintf(outFile, "int %s;\n", varEntrada);                   
        fprintf(outFile, "int %s = %s", varEntrada, varArray[i]);
        i++;
        varEntrada = strtok(NULL, " ");
    }
	char* varSaida = strtok(saidas, " ");
	int j=0;
    while (varSaida != NULL) {
        fprintf(outFile, "int %s = 0;\n", varSaida);
        j++;
        varSaida = strtok(NULL, " ");               
    }
};

varlist: varlist ID {} 
    | ID {$$ = $1;}
    ;

cmds: cmds cmd {}
    | cmd { $$ = $1; }
    ;

cmd: ENQUANTO ID FACA cmds FIM {
	fprintf(outFile, "while (%s > 0) {\n", $2);
	
	fprintf(outFile, "}\n");

   }
   | ID IGUAL ID { 
        
	fprintf(outFile, "%s = %s;\n", $1, $3);
   }
   |INC ABREPAR ID FECHAPAR{
   	fprintf(outFile, "%s++;\n",$3);
   }
   |ZERA ABREPAR ID FECHAPAR { 
        fprintf(outFile, "%s=0;\n",$3);
   }
;
%%



int yyerror(char *s)
{
	printf("Syntax Error on line %s\n", s);
	return 0;
}

int main(int argc, char **argv)
{
    if (argc != 4) {
        printf("provol-One: <Arquivo de Entrada> <Arquivo de Saida> <valor 1> <valor 2>");
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

    varArray[0] = argv[3];
    varArray[1] = argv[4];

    yyparse();

    fclose(arquivoEntrada);
    fclose(arquivoSaida);
    return 0;
}
