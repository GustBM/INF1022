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

%start program
%%

program: ENTRADA varlist SAIDA varlist cmds FIM 
{
    printf("1\n");
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

varlist: varlist ID {
    printf("2\n");
    char buffer[100];
        snprintf(buffer, 100, "%s %s", $1, $2);
        $$ = buffer;
} 
    | ID {$$ = $1;}
    ;

cmds: cmds cmd {
    printf("3\n");
}
    | cmd { $$ = $1; }
    ;

cmd: ENQUANTO ID FACA cmds FIM {
    printf("4\n");
	fprintf(outFile, "while (%s > 0) {\n", $2);
	
	fprintf(outFile, "}\n");

   }
   | ID IGUAL ID { 
        printf("5\n");
	fprintf(outFile, "%s = %s;\n", $1, $3);
   }
   |INC ABREPAR ID FECHAPAR{
       printf("6\n");
   	fprintf(outFile, "%s++;\n",$3);
   }
   |ZERA ABREPAR ID FECHAPAR { 
       printf("7\n");
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
    if (argc != 5) {
        printf("provol-One: <Arquivo de Entrada> <Arquivo de Saida> <valor 1> <valor 2>");
        exit(-1);
    }
    printf("Programa iniciado \n");

    printf("Abrindo arquivo %s...", argv[1]);
    FILE *arquivoEntrada = fopen(argv[1], "r");
    if (arquivoEntrada == NULL) {
        printf("Erro abrindo arquivo de entrada\n");
        exit(-1);
    }

    printf("Arquivo %s aberto \n", argv[1]);
    printf("Abrindo arquivo %s...", argv[2]);
    outFile = fopen(argv[2], "w");
    if (outFile == NULL) {
        printf("Erro abrindo arquivo de saída\n");
        exit(-1);
    }
    printf("Arquivo %s aberto \n", argv[2]);

    varArray[0] = argv[3];
    varArray[1] = argv[4];

    yyin = arquivoEntrada;

    printf("Iniciando yyparse \n");
    yyparse();

    fclose(arquivoEntrada);
    printf("Fechando Arquivo de entrada \n");
    fclose(outFile);
    printf("Fechando Arquivo de entrada \n");
    return 0;
}
